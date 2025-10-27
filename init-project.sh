#!/bin/bash

# ====================================================================
# WordPress Standards Configuration & Formatting Script
# ====================================================================
# Detecta, configura y formatea código WordPress automáticamente
# ====================================================================

set -e
set -o pipefail

# Colores
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; MAGENTA='\033[0;35m'; NC='\033[0m'

# Print functions are now defined in the Error Handling module below

validate_slug() {
    [ -z "$1" ] && { print_error "Slug vacío"; return 1; }
    [[ ! "$1" =~ ^[a-z0-9-]+$ ]] && { print_error "Slug inválido"; return 1; }
    return 0
}

generate_namespace() {
    echo "$1" | awk -F'-' '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1' OFS=''
}

generate_constant() {
    echo "$1" | tr '[:lower:]' '[:upper:]' | tr '-' '_'
}

detect_wordpress_structure() {
    [ -d "wordpress/wp-content" ] && { WP_CONTENT_DIR="wordpress/wp-content"; return 0; }
    [ -d "wp-content" ] && { WP_CONTENT_DIR="wp-content"; return 0; }
    return 1
}

detect_custom_plugins() {
    local plugins_dir="$WP_CONTENT_DIR/plugins"
    [ ! -d "$plugins_dir" ] && { echo ""; return; }
    
    local -a custom_plugins=()
    local exclude="akismet|hello|wordpress-importer|classic-editor|classic-widgets"
    
    for plugin_dir in "$plugins_dir"/*; do
        [ ! -d "$plugin_dir" ] && continue
        local name=$(basename "$plugin_dir")
        [[ "$name" =~ $exclude ]] && continue
        [ -n "$(find "$plugin_dir" -maxdepth 2 -name "*.php" 2>/dev/null)" ] && custom_plugins+=("$name")
    done
    
    echo "${custom_plugins[@]}"
}

detect_custom_themes() {
    local themes_dir="$WP_CONTENT_DIR/themes"
    [ ! -d "$themes_dir" ] && { echo ""; return; }
    
    local -a custom_themes=()
    local exclude="twenty"
    
    for theme_dir in "$themes_dir"/*; do
        [ ! -d "$theme_dir" ] && continue
        local name=$(basename "$theme_dir")
        [[ "$name" =~ $exclude ]] && continue
        { [ -f "$theme_dir/style.css" ] || [ -f "$theme_dir/functions.php" ]; } && custom_themes+=("$name")
    done
    
    echo "${custom_themes[@]}"
}

detect_custom_mu_plugins() {
    local mu_dir="$WP_CONTENT_DIR/mu-plugins"
    [ ! -d "$mu_dir" ] && { echo ""; return; }
    
    local -a mu_plugins=()
    for item in "$mu_dir"/*; do
        [ -d "$item" ] || continue  # Solo directorios
        local name=$(basename "$item")
        # Excluir directorios especiales
        [[ "$name" == "."* ]] || [[ "$name" == "index.php" ]] && continue
        mu_plugins+=("$name")
    done
    
    echo "${mu_plugins[@]}"
}

# ====================================================================
# Error Handling and Validation Module
# ====================================================================

# Global variables for error tracking and logging
BACKUP_DIR=""
COPIED_FILES=()
FAILED_OPERATIONS=()
LOG_FILE=""
VALIDATION_ERRORS=0

# Initialize logging
init_logging() {
    LOG_FILE="./init-project-$(date +%Y%m%d-%H%M%S).log"
    echo "=== WordPress Init Project Script Log ===" > "$LOG_FILE"
    echo "Started: $(date)" >> "$LOG_FILE"
    echo "Working Directory: $(pwd)" >> "$LOG_FILE"
    echo "User: $(whoami)" >> "$LOG_FILE"
    echo "=========================================" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"
}

# Logging functions
log_info() {
    local message="$1"
    echo "[INFO] $(date '+%H:%M:%S') $message" >> "$LOG_FILE"
}

log_warning() {
    local message="$1"
    echo "[WARN] $(date '+%H:%M:%S') $message" >> "$LOG_FILE"
}

log_error() {
    local message="$1"
    echo "[ERROR] $(date '+%H:%M:%S') $message" >> "$LOG_FILE"
}

log_success() {
    local message="$1"
    echo "[SUCCESS] $(date '+%H:%M:%S') $message" >> "$LOG_FILE"
}

# Enhanced print functions with logging
print_success() { 
    echo -e "${GREEN}✅ $1${NC}"
    log_success "$1"
}

print_error() { 
    echo -e "${RED}❌ $1${NC}"
    log_error "$1"
}

print_warning() { 
    echo -e "${YELLOW}⚠️  $1${NC}"
    log_warning "$1"
}

print_info() { 
    echo -e "${BLUE}ℹ️  $1${NC}"
    log_info "$1"
}

# Progress indicator function
show_progress() {
    local current="$1"
    local total="$2"
    local task="$3"
    local percentage=$((current * 100 / total))
    local bar_length=30
    local filled_length=$((percentage * bar_length / 100))
    
    printf "\r${BLUE}[%3d%%]${NC} " "$percentage"
    printf "["
    for ((i=0; i<filled_length; i++)); do printf "█"; done
    for ((i=filled_length; i<bar_length; i++)); do printf "░"; done
    printf "] %s" "$task"
    
    if [ "$current" -eq "$total" ]; then
        echo ""
    fi
}

# Comprehensive validation function
validate_file_operations() {
    local errors=0
    
    print_info "Performing pre-execution validation checks..."
    log_info "Starting validation checks"
    
    # Check if we're in a valid WordPress project
    if ! detect_wordpress_structure; then
        print_error "Not a valid WordPress project structure"
        log_error "WordPress structure validation failed"
        ((errors++))
    else
        log_info "WordPress structure detected: $WP_CONTENT_DIR"
    fi
    
    # Check write permissions in current directory
    if [ ! -w "." ]; then
        print_error "No write permissions in current directory: $(pwd)"
        log_error "Write permission check failed for current directory"
        ((errors++))
    else
        log_info "Write permissions verified for current directory"
    fi
    
    # Check disk space (minimum 100MB)
    local available_space
    if command -v df >/dev/null 2>&1; then
        available_space=$(df . | tail -1 | awk '{print $4}')
        if [ "$available_space" -lt 102400 ]; then  # 100MB in KB
            print_warning "Low disk space: $(($available_space / 1024))MB available"
            log_warning "Low disk space detected: ${available_space}KB available"
        else
            log_info "Disk space check passed: ${available_space}KB available"
        fi
    fi
    
    # Check for required template files in configuration mode
    if [ "$CONFIGURE_PROJECT" = true ]; then
        local required_templates=(
            ".gitignore.template"
            "bitbucket-pipelines.yml"
            "commitlint.config.cjs"
            "lighthouserc.js"
            "Makefile"
            "verify-template.sh"
            "wp.code-workspace"
        )
        
        local missing_templates=0
        for template in "${required_templates[@]}"; do
            if [ ! -f "$template" ]; then
                print_warning "Template file not found: $template"
                log_warning "Missing template file: $template"
                ((missing_templates++))
            else
                log_info "Template file found: $template"
            fi
        done
        
        if [ "$missing_templates" -gt 0 ]; then
            print_warning "$missing_templates template file(s) missing - some features may be skipped"
            log_warning "$missing_templates template files missing"
        fi
    fi
    
    # Validate selected components exist
    if [ "$CONFIGURE_PROJECT" = true ] || [ "$FORMAT_CODE" = true ]; then
        local component_errors=0
        
        for plugin in "${SELECTED_PLUGINS[@]}"; do
            if [ ! -d "$WP_CONTENT_DIR/plugins/$plugin" ]; then
                print_error "Selected plugin directory not found: $WP_CONTENT_DIR/plugins/$plugin"
                log_error "Plugin directory missing: $WP_CONTENT_DIR/plugins/$plugin"
                ((component_errors++))
            else
                log_info "Plugin directory verified: $WP_CONTENT_DIR/plugins/$plugin"
            fi
        done
        
        for theme in "${SELECTED_THEMES[@]}"; do
            if [ ! -d "$WP_CONTENT_DIR/themes/$theme" ]; then
                print_error "Selected theme directory not found: $WP_CONTENT_DIR/themes/$theme"
                log_error "Theme directory missing: $WP_CONTENT_DIR/themes/$theme"
                ((component_errors++))
            else
                log_info "Theme directory verified: $WP_CONTENT_DIR/themes/$theme"
            fi
        done
        
        for mu_plugin in "${SELECTED_MU_PLUGINS[@]}"; do
            if [ ! -d "$WP_CONTENT_DIR/mu-plugins/$mu_plugin" ]; then
                print_error "Selected mu-plugin directory not found: $WP_CONTENT_DIR/mu-plugins/$mu_plugin"
                log_error "MU-plugin directory missing: $WP_CONTENT_DIR/mu-plugins/$mu_plugin"
                ((component_errors++))
            else
                log_info "MU-plugin directory verified: $WP_CONTENT_DIR/mu-plugins/$mu_plugin"
            fi
        done
        
        errors=$((errors + component_errors))
    fi
    
    # Check for required tools
    local tool_errors=0
    
    if [ "$CONFIGURE_PROJECT" = true ]; then
        if [ ! -f "package.json" ] && ! command -v npm >/dev/null 2>&1; then
            print_warning "npm not available - JavaScript configuration may be limited"
            log_warning "npm not available"
        else
            log_info "npm available for JavaScript configuration"
        fi
        
        if [ ! -f "composer.json" ] && ! command -v composer >/dev/null 2>&1; then
            print_warning "Composer not available - PHP configuration may be limited"
            log_warning "Composer not available"
        else
            log_info "Composer available for PHP configuration"
        fi
    fi
    
    if [ "$FORMAT_CODE" = true ]; then
        if [ ! -f "vendor/bin/phpcbf" ] && [ ! -f "composer.json" ]; then
            print_warning "PHPCBF not available - PHP formatting will be skipped"
            log_warning "PHPCBF not available for formatting"
        fi
        
        if [ ! -f "node_modules/.bin/eslint" ] && [ ! -f "package.json" ]; then
            print_warning "ESLint not available - JavaScript formatting will be skipped"
            log_warning "ESLint not available for formatting"
        fi
    fi
    
    # Validate project slug if provided
    if [ -n "$PROJECT_SLUG" ]; then
        if ! validate_slug "$PROJECT_SLUG"; then
            print_error "Invalid project slug: $PROJECT_SLUG"
            log_error "Project slug validation failed: $PROJECT_SLUG"
            ((errors++))
        else
            log_info "Project slug validated: $PROJECT_SLUG"
        fi
    fi
    
    VALIDATION_ERRORS=$errors
    
    if [ "$errors" -gt 0 ]; then
        print_error "Validation failed with $errors error(s)"
        log_error "Validation completed with $errors errors"
        return 1
    else
        print_success "All validation checks passed"
        log_success "Validation completed successfully"
        return 0
    fi
}

# Enhanced backup function with error handling
create_backup() {
    local file="$1"
    
    if [ ! -f "$file" ]; then
        log_warning "Backup requested for non-existent file: $file"
        return 1
    fi
    
    # Initialize backup directory if needed
    if [ -z "$BACKUP_DIR" ]; then
        BACKUP_DIR="./backup-$(date +%Y%m%d-%H%M%S)"
    fi
    
    # Create backup directory if it doesn't exist
    if [ ! -d "$BACKUP_DIR" ]; then
        if ! mkdir -p "$BACKUP_DIR"; then
            print_error "Failed to create backup directory: $BACKUP_DIR"
            log_error "Backup directory creation failed: $BACKUP_DIR"
            return 1
        fi
        log_info "Created backup directory: $BACKUP_DIR"
    fi
    
    # Copy file to backup
    if cp "$file" "$BACKUP_DIR/"; then
        print_info "Backup created: $BACKUP_DIR/$(basename "$file")"
        log_success "File backed up: $file -> $BACKUP_DIR/$(basename "$file")"
        COPIED_FILES+=("$file")
        return 0
    else
        print_error "Failed to backup file: $file"
        log_error "Backup failed for file: $file"
        FAILED_OPERATIONS+=("backup:$file")
        return 1
    fi
}

# Enhanced file operation with error handling
safe_file_operation() {
    local operation="$1"
    local source="$2"
    local target="$3"
    
    case "$operation" in
        "copy")
            if [ ! -f "$source" ]; then
                print_error "Source file not found: $source"
                log_error "Copy operation failed - source not found: $source"
                FAILED_OPERATIONS+=("copy:$source->$target")
                return 1
            fi
            
            # Create target directory if needed
            local target_dir
            target_dir=$(dirname "$target")
            if [ ! -d "$target_dir" ] && [ "$target_dir" != "." ]; then
                if ! mkdir -p "$target_dir"; then
                    print_error "Failed to create target directory: $target_dir"
                    log_error "Directory creation failed: $target_dir"
                    FAILED_OPERATIONS+=("mkdir:$target_dir")
                    return 1
                fi
                log_info "Created directory: $target_dir"
            fi
            
            # Perform copy operation
            if cp "$source" "$target"; then
                log_success "File copied: $source -> $target"
                COPIED_FILES+=("$target")
                return 0
            else
                print_error "Failed to copy file: $source -> $target"
                log_error "Copy operation failed: $source -> $target"
                FAILED_OPERATIONS+=("copy:$source->$target")
                return 1
            fi
            ;;
        "write")
            # For write operations, source is the content, target is the file
            local content="$source"
            local file="$target"
            
            # Create target directory if needed
            local target_dir
            target_dir=$(dirname "$file")
            if [ ! -d "$target_dir" ] && [ "$target_dir" != "." ]; then
                if ! mkdir -p "$target_dir"; then
                    print_error "Failed to create target directory: $target_dir"
                    log_error "Directory creation failed: $target_dir"
                    FAILED_OPERATIONS+=("mkdir:$target_dir")
                    return 1
                fi
                log_info "Created directory: $target_dir"
            fi
            
            # Write content to file
            if echo "$content" > "$file"; then
                log_success "File written: $file"
                COPIED_FILES+=("$file")
                return 0
            else
                print_error "Failed to write file: $file"
                log_error "Write operation failed: $file"
                FAILED_OPERATIONS+=("write:$file")
                return 1
            fi
            ;;
        *)
            print_error "Unknown file operation: $operation"
            log_error "Unknown file operation requested: $operation"
            return 1
            ;;
    esac
}

# Function to display operation summary
show_operation_summary() {
    echo ""
    echo "══════════════════════════════════════════════════════════════"
    echo "  Operation Summary"
    echo "══════════════════════════════════════════════════════════════"
    echo ""
    
    if [ ${#COPIED_FILES[@]} -gt 0 ]; then
        print_success "Successfully processed ${#COPIED_FILES[@]} file(s)"
        log_info "Operation summary - Success: ${#COPIED_FILES[@]} files"
    fi
    
    if [ ${#FAILED_OPERATIONS[@]} -gt 0 ]; then
        print_warning "Failed operations: ${#FAILED_OPERATIONS[@]}"
        for failed in "${FAILED_OPERATIONS[@]}"; do
            echo "  ❌ $failed"
        done
        log_warning "Operation summary - Failed: ${#FAILED_OPERATIONS[@]} operations"
        echo ""
    fi
    
    if [ -n "$BACKUP_DIR" ] && [ -d "$BACKUP_DIR" ]; then
        print_info "Backup directory: $BACKUP_DIR"
        log_info "Backup directory created: $BACKUP_DIR"
    fi
    
    if [ -n "$LOG_FILE" ] && [ -f "$LOG_FILE" ]; then
        print_info "Detailed log: $LOG_FILE"
        echo "Log file created: $LOG_FILE" >> "$LOG_FILE"
    fi
}

# ====================================================================
# File Operations Module for Template Adaptation
# ====================================================================

# ====================================================================
# Workspace Generation Module
# ====================================================================

extract_workspace_settings() {
    local template_file="wp.code-workspace"
    
    if [ ! -f "$template_file" ]; then
        print_warning "Template workspace file not found: $template_file"
        # Return default settings
        echo '  "settings": {
    "editor.rulers": [120],
    "phpsab.snifferMode": "onType",
    "phpsab.snifferShowSources": true,
    "[php]": {
      "editor.formatOnSave": true,
      "editor.defaultFormatter": "valeryanm.vscode-phpsab"
    },
    "[json]": {
      "editor.formatOnSave": true,
      "editor.defaultFormatter": "esbenp.prettier-vscode"
    },
    "[javascript]": {
      "editor.formatOnSave": true,
      "editor.defaultFormatter": "esbenp.prettier-vscode"
    },
    "[markdown]": {
      "editor.formatOnSave": true,
      "editor.defaultFormatter": "esbenp.prettier-vscode"
    }
  }'
        return
    fi
    
    # Extract settings section from template workspace file
    # This preserves all editor settings, extensions, and other configurations
    local settings_section
    settings_section=$(sed -n '/^[[:space:]]*"settings":/,/^[[:space:]]*}[[:space:]]*$/p' "$template_file" | head -n -1)
    
    # If no settings found, extract everything after folders array
    if [ -z "$settings_section" ]; then
        settings_section=$(sed -n '/^[[:space:]]*]/,$ p' "$template_file" | tail -n +2 | head -n -1)
    fi
    
    echo "$settings_section"
}

generate_workspace_file() {
    local workspace_file="wp.code-workspace"
    
    print_info "Generating workspace file: $workspace_file"
    
    # Create backup if file exists
    if [ -f "$workspace_file" ]; then
        create_backup "$workspace_file"
    fi
    
    # Start building workspace content
    local workspace_content='{'
    workspace_content+='\n  "folders": ['
    workspace_content+='\n    {'
    workspace_content+='\n      "path": "."'
    workspace_content+='\n    }'
    
    # Add selected plugin paths
    for plugin in "${SELECTED_PLUGINS[@]}"; do
        if [ -d "$WP_CONTENT_DIR/plugins/$plugin" ]; then
            workspace_content+=',\n    {\n      "path": "'
            workspace_content+="$WP_CONTENT_DIR/plugins/$plugin"
            workspace_content+='"\n    }'
        else
            print_warning "Plugin directory not found: $WP_CONTENT_DIR/plugins/$plugin"
        fi
    done
    
    # Add selected theme paths
    for theme in "${SELECTED_THEMES[@]}"; do
        if [ -d "$WP_CONTENT_DIR/themes/$theme" ]; then
            workspace_content+=',\n    {\n      "path": "'
            workspace_content+="$WP_CONTENT_DIR/themes/$theme"
            workspace_content+='"\n    }'
        else
            print_warning "Theme directory not found: $WP_CONTENT_DIR/themes/$theme"
        fi
    done
    
    # Add selected mu-plugin paths
    for mu_plugin in "${SELECTED_MU_PLUGINS[@]}"; do
        if [ -d "$WP_CONTENT_DIR/mu-plugins/$mu_plugin" ]; then
            workspace_content+=',\n    {\n      "path": "'
            workspace_content+="$WP_CONTENT_DIR/mu-plugins/$mu_plugin"
            workspace_content+='"\n    }'
        else
            print_warning "MU-Plugin directory not found: $WP_CONTENT_DIR/mu-plugins/$mu_plugin"
        fi
    done
    
    # Close folders array
    workspace_content+='\n  ],'
    
    # Add settings from template
    workspace_content+='\n'
    workspace_content+="$(extract_workspace_settings)"
    workspace_content+='\n}'
    
    # Write workspace file
    echo -e "$workspace_content" > "$workspace_file"
    
    print_success "Generated $workspace_file with ${#SELECTED_PLUGINS[@]} plugins, ${#SELECTED_THEMES[@]} themes, ${#SELECTED_MU_PLUGINS[@]} mu-plugins"
}

# ====================================================================
# JavaScript Path Management Module
# ====================================================================

build_js_paths_for_formatting() {
    local -a js_paths=()
    
    # Only include selected components that actually exist
    for plugin in "${SELECTED_PLUGINS[@]}"; do
        if [ -d "$WP_CONTENT_DIR/plugins/$plugin" ]; then
            js_paths+=("$WP_CONTENT_DIR/plugins/$plugin/**/*.{js,jsx,ts,tsx}")
        else
            print_warning "Plugin directory not found: $WP_CONTENT_DIR/plugins/$plugin"
        fi
    done
    
    for theme in "${SELECTED_THEMES[@]}"; do
        if [ -d "$WP_CONTENT_DIR/themes/$theme" ]; then
            js_paths+=("$WP_CONTENT_DIR/themes/$theme/**/*.{js,jsx,ts,tsx}")
        else
            print_warning "Theme directory not found: $WP_CONTENT_DIR/themes/$theme"
        fi
    done
    
    for mu_plugin in "${SELECTED_MU_PLUGINS[@]}"; do
        if [ -d "$WP_CONTENT_DIR/mu-plugins/$mu_plugin" ]; then
            js_paths+=("$WP_CONTENT_DIR/mu-plugins/$mu_plugin/**/*.{js,jsx,ts,tsx}")
        else
            print_warning "MU-Plugin directory not found: $WP_CONTENT_DIR/mu-plugins/$mu_plugin"
        fi
    done
    
    echo "${js_paths[@]}"
}

create_backup() {
    local file="$1"
    if [ -f "$file" ]; then
        [ -z "$BACKUP_DIR" ] && BACKUP_DIR="./backup-$(date +%Y%m%d-%H%M%S)"
        [ ! -d "$BACKUP_DIR" ] && mkdir -p "$BACKUP_DIR"
        cp "$file" "$BACKUP_DIR/"
        print_info "Backup creado: $BACKUP_DIR/$(basename "$file")"
    fi
}

adapt_template_variables() {
    local source="$1"
    local target="$2"
    
    log_info "Adapting template variables: $source -> $target"
    
    # Validate inputs
    if [ ! -f "$source" ]; then
        log_error "Source template file not found: $source"
        return 1
    fi
    
    if [ -z "$PROJECT_SLUG" ]; then
        log_error "PROJECT_SLUG not set for template adaptation"
        return 1
    fi
    
    # Replace template variables with project-specific values
    if sed -e "s/MyProject/$PROJECT_SLUG/g" \
           -e "s/my-project/$PROJECT_SLUG/g" \
           -e "s/MY_PROJECT/$PROJECT_CONSTANT/g" \
           -e "s|wordpress/wp-content|$WP_CONTENT_DIR|g" \
           "$source" > "$target"; then
        log_success "Template variables adapted successfully: $target"
        return 0
    else
        log_error "Failed to adapt template variables: $source -> $target"
        return 1
    fi
}

generate_gitignore_from_template() {
    local source="$1"
    local target="$2"
    
    log_info "Generating .gitignore from template: $source"
    
    # Start with template content
    if ! adapt_template_variables "$source" "$target"; then
        log_error "Failed to adapt template variables for .gitignore"
        return 1
    fi
    
    # Add project-specific ignores based on selected components
    if ! {
        echo ""
        echo "# Project-specific ignores for ${PROJECT_SLUG}"
        echo ""
        
        # Plugin-specific ignores
        if [ ${#SELECTED_PLUGINS[@]} -gt 0 ]; then
            echo "# Plugin build and dependency directories"
            for plugin in "${SELECTED_PLUGINS[@]}"; do
                echo "${WP_CONTENT_DIR}/plugins/${plugin}/build/"
                echo "${WP_CONTENT_DIR}/plugins/${plugin}/dist/"
                echo "${WP_CONTENT_DIR}/plugins/${plugin}/node_modules/"
                echo "${WP_CONTENT_DIR}/plugins/${plugin}/vendor/"
                echo "${WP_CONTENT_DIR}/plugins/${plugin}/.eslintcache"
                echo "${WP_CONTENT_DIR}/plugins/${plugin}/.stylelintcache"
            done
            echo ""
        fi
        
        # Theme-specific ignores
        if [ ${#SELECTED_THEMES[@]} -gt 0 ]; then
            echo "# Theme build and dependency directories"
            for theme in "${SELECTED_THEMES[@]}"; do
                echo "${WP_CONTENT_DIR}/themes/${theme}/assets/build/"
                echo "${WP_CONTENT_DIR}/themes/${theme}/assets/dist/"
                echo "${WP_CONTENT_DIR}/themes/${theme}/build/"
                echo "${WP_CONTENT_DIR}/themes/${theme}/dist/"
                echo "${WP_CONTENT_DIR}/themes/${theme}/node_modules/"
                echo "${WP_CONTENT_DIR}/themes/${theme}/vendor/"
                echo "${WP_CONTENT_DIR}/themes/${theme}/.eslintcache"
                echo "${WP_CONTENT_DIR}/themes/${theme}/.stylelintcache"
            done
            echo ""
        fi
        
        # MU-Plugin-specific ignores
        if [ ${#SELECTED_MU_PLUGINS[@]} -gt 0 ]; then
            echo "# MU-Plugin build and dependency directories"
            for mu_plugin in "${SELECTED_MU_PLUGINS[@]}"; do
                echo "${WP_CONTENT_DIR}/mu-plugins/${mu_plugin}/build/"
                echo "${WP_CONTENT_DIR}/mu-plugins/${mu_plugin}/dist/"
                echo "${WP_CONTENT_DIR}/mu-plugins/${mu_plugin}/node_modules/"
                echo "${WP_CONTENT_DIR}/mu-plugins/${mu_plugin}/vendor/"
                echo "${WP_CONTENT_DIR}/mu-plugins/${mu_plugin}/.eslintcache"
                echo "${WP_CONTENT_DIR}/mu-plugins/${mu_plugin}/.stylelintcache"
            done
            echo ""
        fi
        
        # Project-specific backup and temporary files
        echo "# Project-specific temporary files"
        echo "backup-*/"
        echo "${PROJECT_SLUG}-backup-*/"
        echo "*.${PROJECT_SLUG}.tmp"
        echo ".${PROJECT_SLUG}-cache/"
        
    } >> "$target"; then
        log_error "Failed to append project-specific ignores to .gitignore"
        return 1
    fi
    
    log_success "Generated .gitignore with project-specific ignores"
    return 0
}

add_component_build_steps() {
    local target="$1"
    
    log_info "Adding component-specific build steps to pipeline: $target"
    
    if [ ! -f "$target" ]; then
        log_error "Pipeline target file not found: $target"
        return 1
    fi
    
    # Add component-specific build steps to pipeline
    local build_steps=""
    
    # Add theme build steps
    for theme in "${SELECTED_THEMES[@]}"; do
        build_steps+="                  - cd ${WP_CONTENT_DIR}/themes/${theme} && npm ci && npm run build\n"
    done
    
    # Add plugin build steps
    for plugin in "${SELECTED_PLUGINS[@]}"; do
        build_steps+="                  - cd ${WP_CONTENT_DIR}/plugins/${plugin} && npm ci && npm run build\n"
    done
    
    # Add mu-plugin build steps
    for mu_plugin in "${SELECTED_MU_PLUGINS[@]}"; do
        build_steps+="                  - cd ${WP_CONTENT_DIR}/mu-plugins/${mu_plugin} && npm ci && npm run build\n"
    done
    
    if [ -n "$build_steps" ]; then
        # Replace placeholder build steps with actual component builds
        if sed -i.bak "s|cd wordpress/wp-content/themes/my-project-theme && npm ci|${build_steps%\\n}|g" "$target" &&
           sed -i.bak "s|cd ../../../.. && cd wordpress/wp-content/themes/flat101-starter-theme && npm ci||g" "$target" &&
           sed -i.bak "s|cd ../../../.. && cd wordpress/wp-content/plugins/my-project-custom-blocks && npm ci||g" "$target"; then
            rm -f "${target}.bak"
            log_success "Component build steps added to pipeline"
            return 0
        else
            log_error "Failed to update pipeline with component build steps"
            # Restore backup if it exists
            [ -f "${target}.bak" ] && mv "${target}.bak" "$target"
            return 1
        fi
    else
        log_info "No component build steps to add"
        return 0
    fi
}

generate_pipeline_from_template() {
    local source="$1"
    local target="$2"
    
    log_info "Generating pipeline configuration from template: $source"
    
    # Replace project-specific variables in pipeline
    if ! adapt_template_variables "$source" "$target"; then
        log_error "Failed to adapt template variables for pipeline"
        return 1
    fi
    
    # Add component-specific build steps
    if ! add_component_build_steps "$target"; then
        log_warning "Failed to add component build steps to pipeline (continuing anyway)"
        # Don't fail the entire operation for this
    fi
    
    log_success "Generated pipeline configuration"
    return 0
}

generate_lighthouse_config() {
    local source="$1"
    local target="$2"
    
    log_info "Generating Lighthouse configuration from template: $source"
    
    # Generate lighthouse config with project-specific URLs
    local local_url="https://local.${PROJECT_SLUG}.com/"
    local preprod_url="https://dev.${PROJECT_SLUG}.levelstage.com/"
    
    # Replace URLs and project variables
    if ! sed -e "s|https://local.MyProject.com/|$local_url|g" \
             -e "s|https://dev.MyProject.levelstage.com/|$preprod_url|g" \
             -e "s/MyProject/$PROJECT_SLUG/g" \
             -e "s/my-project/$PROJECT_SLUG/g" \
             -e "s|wordpress/wp-content|$WP_CONTENT_DIR|g" \
             "$source" > "$target"; then
        log_error "Failed to generate Lighthouse configuration"
        return 1
    fi
    
    # Add project-specific test URLs if needed
    if ! add_lighthouse_test_urls "$target"; then
        log_warning "Failed to add test URLs to Lighthouse config (continuing anyway)"
        # Don't fail the entire operation for this
    fi
    
    log_success "Generated Lighthouse configuration"
    return 0
}

add_lighthouse_test_urls() {
    local target="$1"
    
    log_info "Adding test URLs to Lighthouse configuration: $target"
    
    if [ ! -f "$target" ]; then
        log_error "Lighthouse target file not found: $target"
        return 1
    fi
    
    # Add common WordPress pages for testing
    local additional_urls=""
    additional_urls+=", 'https://local.${PROJECT_SLUG}.com/about/'"
    additional_urls+=", 'https://local.${PROJECT_SLUG}.com/contact/'"
    additional_urls+=", 'https://local.${PROJECT_SLUG}.com/blog/'"
    
    # Replace the URL array to include additional test URLs
    if sed -i.bak "s|'https://local.${PROJECT_SLUG}.com/'|'https://local.${PROJECT_SLUG}.com/'${additional_urls}|g" "$target"; then
        rm -f "${target}.bak"
        log_success "Test URLs added to Lighthouse configuration"
        return 0
    else
        log_error "Failed to add test URLs to Lighthouse configuration"
        # Restore backup if it exists
        [ -f "${target}.bak" ] && mv "${target}.bak" "$target"
        return 1
    fi
}

add_makefile_component_targets() {
    local target="$1"
    
    # Add component-specific targets to Makefile
    local component_targets=""
    
    # Add theme-specific targets
    for theme in "${SELECTED_THEMES[@]}"; do
        component_targets+="\n# === ${theme} THEME TARGETS ===\n"
        component_targets+="dev-${theme}: ## 🎨 Development for ${theme} theme\n"
        component_targets+="\t@echo \"🎨 Starting ${theme} theme development...\"\n"
        component_targets+="\t@cd ${WP_CONTENT_DIR}/themes/${theme} && npm run dev\n\n"
        component_targets+="build-${theme}: ## 📦 Build ${theme} theme assets\n"
        component_targets+="\t@echo \"📦 Building ${theme} theme assets...\"\n"
        component_targets+="\t@cd ${WP_CONTENT_DIR}/themes/${theme} && npm run build\n\n"
    done
    
    # Add plugin-specific targets
    for plugin in "${SELECTED_PLUGINS[@]}"; do
        component_targets+="\n# === ${plugin} PLUGIN TARGETS ===\n"
        component_targets+="dev-${plugin}: ## 🧩 Development for ${plugin} plugin\n"
        component_targets+="\t@echo \"🧩 Starting ${plugin} plugin development...\"\n"
        component_targets+="\t@cd ${WP_CONTENT_DIR}/plugins/${plugin} && npm run dev\n\n"
        component_targets+="build-${plugin}: ## 📦 Build ${plugin} plugin assets\n"
        component_targets+="\t@echo \"📦 Building ${plugin} plugin assets...\"\n"
        component_targets+="\t@cd ${WP_CONTENT_DIR}/plugins/${plugin} && npm run build\n\n"
    done
    
    # Add mu-plugin-specific targets
    for mu_plugin in "${SELECTED_MU_PLUGINS[@]}"; do
        component_targets+="\n# === ${mu_plugin} MU-PLUGIN TARGETS ===\n"
        component_targets+="dev-${mu_plugin}: ## 🔌 Development for ${mu_plugin} mu-plugin\n"
        component_targets+="\t@echo \"🔌 Starting ${mu_plugin} mu-plugin development...\"\n"
        component_targets+="\t@cd ${WP_CONTENT_DIR}/mu-plugins/${mu_plugin} && npm run dev\n\n"
        component_targets+="build-${mu_plugin}: ## 📦 Build ${mu_plugin} mu-plugin assets\n"
        component_targets+="\t@echo \"📦 Building ${mu_plugin} mu-plugin assets...\"\n"
        component_targets+="\t@cd ${WP_CONTENT_DIR}/mu-plugins/${mu_plugin} && npm run build\n\n"
    done
    
    if [ -n "$component_targets" ]; then
        # Add component targets before the CI/CD section
        echo -e "$component_targets" >> "$target"
    fi
}

generate_makefile_from_template() {
    local source="$1"
    local target="$2"
    
    log_info "Generating Makefile from template: $source"
    
    # Replace project variables in Makefile
    if ! adapt_template_variables "$source" "$target"; then
        log_error "Failed to adapt template variables for Makefile"
        return 1
    fi
    
    # Add component-specific targets
    if ! add_makefile_component_targets "$target"; then
        log_warning "Failed to add component targets to Makefile (continuing anyway)"
        # Don't fail the entire operation for this
    fi
    
    log_success "Generated Makefile"
    return 0
}

generate_adapted_file() {
    local source="$1"
    local target="$2"
    
    log_info "Processing template file: $source -> $target"
    
    if [ ! -f "$source" ]; then
        print_warning "Template file $source not found"
        log_warning "Template file not found: $source"
        FAILED_OPERATIONS+=("template_missing:$source")
        return 1
    fi
    
    # Create backup if target exists
    if [ -f "$target" ]; then
        if ! create_backup "$target"; then
            print_warning "Failed to backup $target, continuing anyway..."
            log_warning "Backup failed for $target but continuing"
        fi
    fi
    
    # Adapt file content based on project configuration
    local success=true
    case "$source" in
        ".gitignore.template")
            if ! generate_gitignore_from_template "$source" "$target"; then
                success=false
            fi
            ;;
        "bitbucket-pipelines.yml")
            if ! generate_pipeline_from_template "$source" "$target"; then
                success=false
            fi
            ;;
        "lighthouserc.js")
            if ! generate_lighthouse_config "$source" "$target"; then
                success=false
            fi
            ;;
        "Makefile")
            if ! generate_makefile_from_template "$source" "$target"; then
                success=false
            fi
            ;;
        *)
            # For files that need simple variable replacement
            if ! adapt_template_variables "$source" "$target"; then
                success=false
            fi
            ;;
    esac
    
    if [ "$success" = true ]; then
        print_success "Generated $target from $source template"
        log_success "Template processed successfully: $source -> $target"
        COPIED_FILES+=("$target")
        return 0
    else
        print_error "Failed to generate $target from $source template"
        log_error "Template processing failed: $source -> $target"
        FAILED_OPERATIONS+=("template_generation:$source->$target")
        return 1
    fi
}

generate_project_files() {
    local template_files=(
        ".gitignore.template:.gitignore"
        "bitbucket-pipelines.yml:bitbucket-pipelines.yml"
        "commitlint.config.cjs:commitlint.config.cjs"
        "lighthouserc.js:lighthouserc.js"
        "Makefile:Makefile"
        "verify-template.sh:verify-template.sh"
    )
    
    print_info "Generating project files from templates..."
    log_info "Starting template file generation process"
    echo ""
    
    local total_files=${#template_files[@]}
    local current_file=0
    local successful_files=0
    local failed_files=0
    
    for file_mapping in "${template_files[@]}"; do
        local source="${file_mapping%:*}"
        local target="${file_mapping#*:}"
        
        ((current_file++))
        show_progress "$current_file" "$total_files" "Processing $source"
        
        if generate_adapted_file "$source" "$target"; then
            ((successful_files++))
        else
            ((failed_files++))
        fi
    done
    
    echo ""
    
    if [ "$failed_files" -eq 0 ]; then
        print_success "All $successful_files template files processed successfully"
        log_success "Template file generation completed: $successful_files/$total_files successful"
    elif [ "$successful_files" -gt 0 ]; then
        print_warning "$successful_files/$total_files template files processed ($failed_files failed)"
        log_warning "Template file generation completed with errors: $successful_files/$total_files successful"
    else
        print_error "All template file operations failed"
        log_error "Template file generation failed completely"
        return 1
    fi
    
    return 0
}

# Initialize logging
init_logging

# Banner
clear
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  🚀 WordPress Standards & Formatting                         ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Verificar requisitos
log_info "Starting WordPress Standards & Formatting Script"
log_info "Checking system requirements..."

command -v node >/dev/null 2>&1 || { print_error "Node.js requerido"; exit 1; }
command -v npm >/dev/null 2>&1 || { print_error "npm requerido"; exit 1; }
COMPOSER_AVAILABLE=false
command -v composer >/dev/null 2>&1 && COMPOSER_AVAILABLE=true

print_success "Requisitos verificados"
log_success "System requirements check completed"
echo ""

# Modo de operación
echo "══════════════════════════════════════════════════════════════"
echo "  Modo de Operación"
echo "══════════════════════════════════════════════════════════════"
echo "  1️⃣  Configurar y formatear proyecto"
echo "  2️⃣  Solo configurar (sin formatear)"
echo "  3️⃣  Solo formatear código existente"
echo ""
echo -n "Selecciona modo (1-3): "
read MODE
echo ""

FORMAT_CODE=false
CONFIGURE_PROJECT=false

case $MODE in
    1) CONFIGURE_PROJECT=true; FORMAT_CODE=true; print_info "Modo: Configurar y formatear" ;;
    2) CONFIGURE_PROJECT=true; print_info "Modo: Solo configurar" ;;
    3) FORMAT_CODE=true; print_info "Modo: Solo formatear" ;;
    *) print_error "Opción inválida"; exit 1 ;;
esac

echo ""

# Detectar estructura WordPress
detect_wordpress_structure || { print_error "Estructura WordPress no encontrada"; exit 1; }
print_success "Estructura detectada: $WP_CONTENT_DIR"
echo ""

# Detectar componentes
print_info "Detectando componentes personalizados..."
echo ""

DETECTED_PLUGINS=($(detect_custom_plugins))
DETECTED_THEMES=($(detect_custom_themes))
DETECTED_MU_PLUGINS=($(detect_custom_mu_plugins))

[ ${#DETECTED_PLUGINS[@]} -gt 0 ] && {
    print_success "Plugins detectados:"
    for p in "${DETECTED_PLUGINS[@]}"; do echo "  📦 $p"; done
    echo ""
}

[ ${#DETECTED_THEMES[@]} -gt 0 ] && {
    print_success "Temas detectados:"
    for t in "${DETECTED_THEMES[@]}"; do echo "  🎨 $t"; done
    echo ""
}

[ ${#DETECTED_MU_PLUGINS[@]} -gt 0 ] && {
    print_success "MU-Plugins detectados:"
    for m in "${DETECTED_MU_PLUGINS[@]}"; do echo "  🔌 $m"; done
    echo ""
}

# Selección de componentes
SELECTED_PLUGINS=()
SELECTED_THEMES=()
SELECTED_MU_PLUGINS=()

if [ "$CONFIGURE_PROJECT" = true ]; then
    echo "══════════════════════════════════════════════════════════════"
    echo "  Selección de Componentes"
    echo "══════════════════════════════════════════════════════════════"
    echo ""
    
    [ ${#DETECTED_PLUGINS[@]} -gt 0 ] && {
        echo "--- Plugins ---"
        for plugin in "${DETECTED_PLUGINS[@]}"; do
            while true; do
                echo -n "¿Incluir '$plugin'? (y/n): "
                read resp
                case "$resp" in
                    [Yy]|[Yy][Ee][Ss]|[Ss]|[Ss][Ii])
                        SELECTED_PLUGINS+=("$plugin")
                        print_success "Plugin '$plugin' añadido"
                        break
                        ;;
                    [Nn]|[Nn][Oo])
                        print_info "Plugin '$plugin' omitido"
                        break
                        ;;
                    *)
                        print_warning "Por favor responde 'y' para sí o 'n' para no"
                        ;;
                esac
            done
        done
        echo ""
    }
    
    [ ${#DETECTED_THEMES[@]} -gt 0 ] && {
        echo "--- Temas ---"
        for theme in "${DETECTED_THEMES[@]}"; do
            while true; do
                echo -n "¿Incluir '$theme'? (y/n): "
                read resp
                case "$resp" in
                    [Yy]|[Yy][Ee][Ss]|[Ss]|[Ss][Ii])
                        SELECTED_THEMES+=("$theme")
                        print_success "Tema '$theme' añadido"
                        break
                        ;;
                    [Nn]|[Nn][Oo])
                        print_info "Tema '$theme' omitido"
                        break
                        ;;
                    *)
                        print_warning "Por favor responde 'y' para sí o 'n' para no"
                        ;;
                esac
            done
        done
        echo ""
    }
    
    [ ${#DETECTED_MU_PLUGINS[@]} -gt 0 ] && {
        echo "--- MU-Plugins ---"
        for mu in "${DETECTED_MU_PLUGINS[@]}"; do
            while true; do
                echo -n "¿Incluir '$mu'? (y/n): "
                read resp
                case "$resp" in
                    [Yy]|[Yy][Ee][Ss]|[Ss]|[Ss][Ii])
                        SELECTED_MU_PLUGINS+=("$mu")
                        print_success "MU-Plugin '$mu' añadido"
                        break
                        ;;
                    [Nn]|[Nn][Oo])
                        print_info "MU-Plugin '$mu' omitido"
                        break
                        ;;
                    *)
                        print_warning "Por favor responde 'y' para sí o 'n' para no"
                        ;;
                esac
            done
        done
        echo ""
    }
    
    # Debug: mostrar lo que se seleccionó
    print_info "DEBUG: Plugins seleccionados: ${#SELECTED_PLUGINS[@]} (${SELECTED_PLUGINS[@]})"
    print_info "DEBUG: Temas seleccionados: ${#SELECTED_THEMES[@]} (${SELECTED_THEMES[@]})"
    print_info "DEBUG: MU-Plugins seleccionados: ${#SELECTED_MU_PLUGINS[@]} (${SELECTED_MU_PLUGINS[@]})"
    
    [ ${#SELECTED_PLUGINS[@]} -eq 0 ] && [ ${#SELECTED_THEMES[@]} -eq 0 ] && [ ${#SELECTED_MU_PLUGINS[@]} -eq 0 ] && {
        print_error "No se seleccionó ningún componente"
        print_info "Asegúrate de responder 'y' o 'yes' para incluir los componentes que deseas"
        exit 1
    }
    
    echo "══════════════════════════════════════════════════════════════"
    echo "  Resumen"
    echo "══════════════════════════════════════════════════════════════"
    echo ""
    [ ${#SELECTED_PLUGINS[@]} -gt 0 ] && {
        echo "Plugins (${#SELECTED_PLUGINS[@]}):"
        for p in "${SELECTED_PLUGINS[@]}"; do echo "  ✅ $p"; done
        echo ""
    }
    [ ${#SELECTED_THEMES[@]} -gt 0 ] && {
        echo "Temas (${#SELECTED_THEMES[@]}):"
        for t in "${SELECTED_THEMES[@]}"; do echo "  ✅ $t"; done
        echo ""
    }
    [ ${#SELECTED_MU_PLUGINS[@]} -gt 0 ] && {
        echo "MU-Plugins (${#SELECTED_MU_PLUGINS[@]}):"
        for m in "${SELECTED_MU_PLUGINS[@]}"; do echo "  ✅ $m"; done
        echo ""
    }
    
    echo -n "¿Continuar? (y/n): "
    read CONFIRM
    [[ ! $CONFIRM =~ ^[Yy]$ ]] && { print_warning "Cancelado"; exit 0; }
else
    # Modo 3: usar todos los componentes detectados
    SELECTED_PLUGINS=("${DETECTED_PLUGINS[@]}")
    SELECTED_THEMES=("${DETECTED_THEMES[@]}")
    SELECTED_MU_PLUGINS=("${DETECTED_MU_PLUGINS[@]}")
    
    # Verificar que hay componentes para formatear
    if [ ${#SELECTED_PLUGINS[@]} -eq 0 ] && [ ${#SELECTED_THEMES[@]} -eq 0 ] && [ ${#SELECTED_MU_PLUGINS[@]} -eq 0 ]; then
        print_error "No se encontraron componentes personalizados para formatear"
        exit 1
    fi
fi

# Perform comprehensive validation before proceeding
echo ""
echo "══════════════════════════════════════════════════════════════"
echo "  Validation & Pre-flight Checks"
echo "══════════════════════════════════════════════════════════════"
echo ""

if ! validate_file_operations; then
    echo ""
    print_error "Validation failed. Please fix the issues above before continuing."
    
    if [ "$VALIDATION_ERRORS" -gt 0 ]; then
        echo ""
        print_info "Common solutions:"
        echo "  • Ensure you're in a WordPress project directory"
        echo "  • Check file and directory permissions"
        echo "  • Verify selected components exist"
        echo "  • Install required tools (npm, composer)"
    fi
    
    echo ""
    echo -n "Continue anyway? (y/n): "
    read FORCE_CONTINUE
    if [[ ! $FORCE_CONTINUE =~ ^[Yy]$ ]]; then
        print_warning "Operation cancelled by user"
        log_warning "Operation cancelled due to validation failures"
        show_operation_summary
        exit 1
    else
        print_warning "Continuing with validation warnings..."
        log_warning "User chose to continue despite validation failures"
    fi
fi

echo ""

# Nombre del proyecto
echo ""
echo "══════════════════════════════════════════════════════════════"
echo "  Configuración del Proyecto"
echo "══════════════════════════════════════════════════════════════"
echo ""

PROJECT_SLUG=""

print_info "Buscando nombre del proyecto en archivos de configuración..."

# Intentar detectar desde composer.json
if [ -f "composer.json" ]; then
    DETECTED=$(grep -o '"name": "[^"]*"' composer.json 2>/dev/null | head -1 | cut -d'"' -f4 | cut -d'/' -f2 | sed 's/-wordpress$//' || echo "")
    # Ignorar nombres genéricos
    if [ -n "$DETECTED" ] && [ "$DETECTED" != "wordpress" ] && [ "$DETECTED" != "my-project" ]; then
        echo ""
        print_info "Detectado desde composer.json: $DETECTED"
        read -p "¿Usar este nombre? (y/n): " resp < /dev/tty
        echo ""
        [[ $resp =~ ^[Yy]$ ]] && PROJECT_SLUG="$DETECTED"
    fi
fi

# Fallback: intentar desde package.json
if [ -z "$PROJECT_SLUG" ] && [ -f "package.json" ]; then
    DETECTED=$(grep -o '"name": "[^"]*"' package.json 2>/dev/null | head -1 | cut -d'"' -f4 | sed 's/-wordpress$//' || echo "")
    # Ignorar nombres genéricos
    if [ -n "$DETECTED" ] && [ "$DETECTED" != "wordpress" ] && [ "$DETECTED" != "my-project" ]; then
        echo ""
        print_info "Detectado desde package.json: $DETECTED"
        read -p "¿Usar este nombre? (y/n): " resp < /dev/tty
        echo ""
        [[ $resp =~ ^[Yy]$ ]] && PROJECT_SLUG="$DETECTED"
    fi
fi

# Solicitar nombre si no se detectó
if [ -z "$PROJECT_SLUG" ]; then
    echo ""
    print_warning "No se pudo detectar el nombre automáticamente"
fi

while [ -z "$PROJECT_SLUG" ]; do
    echo ""
    echo -n "Nombre del proyecto (slug, ej: astro-headless): "
    read PROJECT_SLUG
    echo ""
    if [ -z "$PROJECT_SLUG" ]; then
        print_error "El nombre no puede estar vacío"
        continue
    fi
    if ! validate_slug "$PROJECT_SLUG"; then
        PROJECT_SLUG=""
    fi
done

print_success "Proyecto: $PROJECT_SLUG"
echo ""

PROJECT_CONSTANT=$(generate_constant "$PROJECT_SLUG")
PROJECT_NAMESPACE=$(generate_namespace "$PROJECT_SLUG")
TEXT_DOMAIN="$PROJECT_SLUG"

# Generar archivos de configuración
if [ "$CONFIGURE_PROJECT" = true ]; then
    echo "══════════════════════════════════════════════════════════════"
    echo "  Generando Archivos de Configuración"
    echo "══════════════════════════════════════════════════════════════"
    echo ""
    
    # Initialize backup directory
    BACKUP_DIR=""
    
    # Generate adapted template files using the new function
    generate_project_files
    
    # Backup existing configuration files
    for f in phpcs.xml.dist phpstan.neon.dist eslint.config.js; do
        [ -f "$f" ] && create_backup "$f"
    done
    [ -n "$BACKUP_DIR" ] && [ -d "$BACKUP_DIR" ] && print_success "Backup: $BACKUP_DIR"
    echo ""
    
    # Construir prefixes y text domains
    PREFIXES=""
    TEXT_DOMAINS="                <element value=\"${TEXT_DOMAIN}\"/>\n"
    
    add_component() {
        local name="$1"
        local prefix=$(echo "$name" | tr '-' '_')
        local constant=$(generate_constant "$name")
        local namespace=$(generate_namespace "$name")
        PREFIXES+="                <element value=\"${prefix}_\"/>\n"
        PREFIXES+="                <element value=\"${constant}_\"/>\n"
        # Escapar correctamente para XML
        PREFIXES+="                <element value=\"${namespace}\\\\\"/>\n"
        TEXT_DOMAINS+="                <element value=\"${name}\"/>\n"
    }
    
    add_component "$PROJECT_SLUG"
    for p in "${SELECTED_PLUGINS[@]}"; do add_component "$p"; done
    for t in "${SELECTED_THEMES[@]}"; do add_component "$t"; done
    
    # Construir rutas
    FILES=""
    for p in "${SELECTED_PLUGINS[@]}"; do FILES+="    <file>${WP_CONTENT_DIR}/plugins/${p}</file>\n"; done
    for t in "${SELECTED_THEMES[@]}"; do FILES+="    <file>${WP_CONTENT_DIR}/themes/${t}</file>\n"; done
    for m in "${SELECTED_MU_PLUGINS[@]}"; do FILES+="    <file>${WP_CONTENT_DIR}/mu-plugins/${m}</file>\n"; done
    
    # phpcs.xml.dist
    print_info "Generando phpcs.xml.dist..."
    cat > phpcs.xml.dist << PHPCS_EOF
<?xml version="1.0"?>
<ruleset name="WordPress Project PHP Standards">
    <description>PHP CodeSniffer rules for WordPress project</description>

    <rule ref="WordPress">
        <exclude name="WordPress.Files.FileName.InvalidClassFileName"/>
        <exclude name="WordPress.Files.FileName.NotHyphenatedLowercase"/>
        <exclude name="Squiz.Commenting.InlineComment.InvalidEndChar"/>
        <exclude name="Squiz.Commenting.FunctionComment.Missing"/>
        <exclude name="Squiz.Commenting.FileComment.Missing"/>
        <exclude name="Squiz.Commenting.ClassComment.Missing"/>
        <exclude name="Squiz.Commenting.VariableComment.Missing"/>
    </rule>

    <rule ref="WordPress.NamingConventions.PrefixAllGlobals">
        <properties>
            <property name="prefixes" type="array">
$(echo -e "$PREFIXES")            </property>
        </properties>
    </rule>

    <rule ref="WordPress.WP.I18n">
        <properties>
            <property name="text_domain" type="array">
$(echo -e "$TEXT_DOMAINS")            </property>
        </properties>
    </rule>

    <!-- Files to check -->
$(echo -e "$FILES")
    <!-- Exclude directories -->
    <exclude-pattern>*/node_modules/*</exclude-pattern>
    <exclude-pattern>*/build/*</exclude-pattern>
    <exclude-pattern>*/vendor/*</exclude-pattern>
    <exclude-pattern>*/tests/*</exclude-pattern>
    <exclude-pattern>*.min.js</exclude-pattern>
    <exclude-pattern>${WP_CONTENT_DIR%/*}/wp-admin/*</exclude-pattern>
    <exclude-pattern>${WP_CONTENT_DIR%/*}/wp-includes/*</exclude-pattern>

    <arg name="extensions" value="php"/>
    <arg value="p"/>
    <arg value="s"/>
    <arg name="parallel" value="8"/>
    <config name="ignore_warnings_on_exit" value="1"/>
</ruleset>
PHPCS_EOF
    
    print_success "phpcs.xml.dist generado"
    
    # phpstan.neon.dist
    print_info "Generando phpstan.neon.dist..."
    PATHS=""
    EXCLUDES=""
    for p in "${SELECTED_PLUGINS[@]}"; do
        PATHS+="    - ${WP_CONTENT_DIR}/plugins/${p}/\n"
        EXCLUDES+="    - ${WP_CONTENT_DIR}/plugins/${p}/build/\n"
        EXCLUDES+="    - ${WP_CONTENT_DIR}/plugins/${p}/vendor/\n"
        EXCLUDES+="    - ${WP_CONTENT_DIR}/plugins/${p}/node_modules/\n"
    done
    for t in "${SELECTED_THEMES[@]}"; do
        PATHS+="    - ${WP_CONTENT_DIR}/themes/${t}/\n"
        EXCLUDES+="    - ${WP_CONTENT_DIR}/themes/${t}/build/\n"
        EXCLUDES+="    - ${WP_CONTENT_DIR}/themes/${t}/vendor/\n"
    done
    for m in "${SELECTED_MU_PLUGINS[@]}"; do
        PATHS+="    - ${WP_CONTENT_DIR}/mu-plugins/${m}/\n"
    done
    
    cat > phpstan.neon.dist << PHPSTAN_EOF
parameters:
  level: 5

  paths:
$(echo -e "$PATHS")
  excludePaths:
$(echo -e "$EXCLUDES")    - ${WP_CONTENT_DIR%/*}/wp-admin/
    - ${WP_CONTENT_DIR%/*}/wp-includes/

  ignoreErrors:
    - '#Call to an undefined method#'
    - '#Access to an undefined property#'
    - '#Undefined variable#'

  phpVersion: 80100
  checkMissingTypehints: false
PHPSTAN_EOF
    
    print_success "phpstan.neon.dist generado"
    
    # eslint.config.js
    print_info "Generando eslint.config.js..."
    ESLINT_FILES=""
    for p in "${SELECTED_PLUGINS[@]}"; do
        ESLINT_FILES+="      '${WP_CONTENT_DIR}/plugins/${p}/**/*.{js,jsx,ts,tsx}',\n"
    done
    for t in "${SELECTED_THEMES[@]}"; do
        ESLINT_FILES+="      '${WP_CONTENT_DIR}/themes/${t}/**/*.{js,jsx,ts,tsx}',\n"
    done
    
    cat > eslint.config.js << 'ESLINT_EOF'
import js from '@eslint/js';
import globals from 'globals';

export default [
  {
    ignores: ['build/', 'node_modules/', 'vendor/', '**/*.min.js'],
  },
  {
    ...js.configs.recommended,
    languageOptions: {
      ecmaVersion: 2022,
      sourceType: 'module',
      globals: { ...globals.browser, ...globals.node, wp: 'readonly', jQuery: 'readonly', $: 'readonly', __: 'readonly' },
    },
ESLINT_EOF
    
    echo "    files: [" >> eslint.config.js
    echo -e "$ESLINT_FILES" | sed '$ s/,$//' >> eslint.config.js
    echo "    ]," >> eslint.config.js
    
    cat >> eslint.config.js << 'ESLINT_RULES'
    rules: {
      'array-bracket-spacing': ['error', 'always'],
      'space-in-parens': ['error', 'always'],
      'object-curly-spacing': ['error', 'always'],
      'computed-property-spacing': ['error', 'always'],
      'space-infix-ops': 'error',
      'keyword-spacing': ['error', { before: true, after: true }],
      'space-before-function-paren': ['error', { anonymous: 'always', named: 'never', asyncArrow: 'always' }],
      'space-before-blocks': 'error',
      'camelcase': ['error', { properties: 'never' }],
      'indent': ['error', 'tab', { SwitchCase: 1 }],
      'quotes': ['error', 'single', { avoidEscape: true }],
      'semi': ['error', 'always'],
      'comma-dangle': ['error', 'always-multiline'],
      'no-trailing-spaces': 'error',
      'eol-last': 'error',
      'no-console': ['warn', { allow: ['warn', 'error'] }],
      'no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
      'prefer-const': 'error',
      'no-var': 'error',
    },
  },
];
ESLINT_RULES
    
    print_success "eslint.config.js generado"
    
    # Generar package.json si no existe
    if [ ! -f "package.json" ]; then
        print_info "Generando package.json..."
        cat > package.json << PACKAGE_EOF
{
  "name": "${PROJECT_SLUG}",
  "version": "1.0.0",
  "description": "WordPress project with coding standards",
  "type": "module",
  "scripts": {
    "lint:js": "eslint '**/*.{js,jsx,ts,tsx}'",
    "lint:js:fix": "eslint --fix '**/*.{js,jsx,ts,tsx}'",
    "lint:php": "./vendor/bin/phpcs --standard=phpcs.xml.dist",
    "lint:php:fix": "./vendor/bin/phpcbf --standard=phpcs.xml.dist",
    "lint": "npm run lint:js && npm run lint:php",
    "format": "npm run lint:js:fix && npm run lint:php:fix"
  },
  "devDependencies": {
    "@eslint/js": "^9.9.0",
    "eslint": "^9.9.0",
    "globals": "^15.9.0"
  },
  "author": "",
  "license": "MIT"
}
PACKAGE_EOF
        print_success "package.json generado"
    fi
    
    # Generar composer.json si no existe
    if [ ! -f "composer.json" ]; then
        print_info "Generando composer.json..."
        cat > composer.json << COMPOSER_EOF
{
    "name": "${PROJECT_SLUG}/wordpress",
    "description": "WordPress project with coding standards",
    "type": "project",
    "require": {
        "php": ">=8.1"
    },
    "require-dev": {
        "dealerdirect/phpcodesniffer-composer-installer": "^1.0",
        "phpcompatibility/php-compatibility": "^9.3",
        "phpstan/phpstan": "^1.11",
        "wp-coding-standards/wpcs": "^3.1"
    },
    "config": {
        "allow-plugins": {
            "dealerdirect/phpcodesniffer-composer-installer": true
        }
    },
    "scripts": {
        "lint": "phpcs --standard=phpcs.xml.dist",
        "lint:fix": "phpcbf --standard=phpcs.xml.dist",
        "analyze": "phpstan analyze"
    }
}
COMPOSER_EOF
        print_success "composer.json generado"
    fi
    
    # Generar carpeta .vscode si no existe
    if [ ! -d ".vscode" ]; then
        print_info "Generando configuración de VSCode..."
        mkdir -p .vscode
        
        # extensions.json
        cat > .vscode/extensions.json << 'VSCODE_EXT_EOF'
{
  "recommendations": [
    "bmewburn.vscode-intelephense-client",
    "ValeryanM.vscode-phpsab",
    "esbenp.prettier-vscode"
  ]
}
VSCODE_EXT_EOF
        
        # settings.json
        cat > .vscode/settings.json << 'VSCODE_SETTINGS_EOF'
{
  "editor.rulers": [120],
  "editor.tabSize": 4,
  "editor.insertSpaces": false,
  "editor.detectIndentation": false,
  "editor.formatOnSave": true,
  
  // PHPCS configuration
  "phpcs.enable": true,
  "phpcs.standard": "./phpcs.xml.dist",
  "phpcs.executablePath": "./vendor/bin/phpcs",
  "phpcs.showSources": true,
  "phpcs.showSniffSource": true,
  
  // PHP language settings
  "[php]": {
    "editor.defaultFormatter": "ValeryanM.vscode-phpsab",
    "editor.formatOnSave": true,
    "editor.tabSize": 4,
    "editor.insertSpaces": false,
    "editor.rulers": [120],
    "editor.codeActionsOnSave": {
      "source.fixAll": "always"
    }
  },
  
  // Prettier para otros formatos
  "[json]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode",
    "editor.formatOnSave": true
  },
  "[javascript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode",
    "editor.formatOnSave": true
  },
  "[markdown]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode",
    "editor.formatOnSave": true
  }
}
VSCODE_SETTINGS_EOF
        
        print_success ".vscode/ generado"
    fi
    
    # Generate workspace file with selected components
    generate_workspace_file
    
    echo ""
    print_success "Archivos de configuración generados"
fi

# Formateo automático
if [ "$FORMAT_CODE" = true ]; then
    echo ""
    echo "══════════════════════════════════════════════════════════════"
    echo "  Formateo Automático del Código"
    echo "══════════════════════════════════════════════════════════════"
    echo ""
    
    [ ! -f "phpcs.xml.dist" ] && {
        print_error "phpcs.xml.dist no encontrado"
        print_info "Ejecuta primero el modo 1 o 2 para generar la configuración"
        exit 1
    }
    
    # Verificar que existan componentes para formatear
    has_components=false
    for plugin in "${SELECTED_PLUGINS[@]}"; do
        [ -d "$WP_CONTENT_DIR/plugins/$plugin" ] && has_components=true && break
    done
    for theme in "${SELECTED_THEMES[@]}"; do
        [ -d "$WP_CONTENT_DIR/themes/$theme" ] && has_components=true && break
    done
    
    [ "$has_components" = false ] && {
        print_warning "Advertencia: No se encontraron directorios de componentes"
        print_info "Verifica que los plugins/temas existan en las rutas esperadas"
        read -p "¿Continuar de todos modos? (y/n): " resp < /dev/tty
        [[ ! $resp =~ ^[Yy]$ ]] && exit 0
    }
    
    # PHP Code Beautifier & Fixer
    if [ -f "vendor/bin/phpcbf" ]; then
        print_info "Formateando código PHP con PHPCBF..."
        echo ""
        ./vendor/bin/phpcbf --standard=phpcs.xml.dist || {
            exitcode=$?
            [ $exitcode -eq 1 ] && print_success "PHP formateado (algunos archivos corregidos)" || print_warning "PHP: revisar warnings"
        }
        echo ""
    elif [ "$COMPOSER_AVAILABLE" = true ] && [ -f "composer.json" ]; then
        print_warning "PHPCBF no encontrado"
        read -p "¿Instalar dependencias de Composer? (y/n): " INSTALL < /dev/tty
        [[ $INSTALL =~ ^[Yy]$ ]] && {
            print_info "Instalando dependencias..."
            if composer install; then
                [ -f "vendor/bin/phpcbf" ] && {
                    print_info "Formateando código PHP..."
                    ./vendor/bin/phpcbf --standard=phpcs.xml.dist || print_success "PHP formateado"
                }
            else
                print_error "Error al instalar dependencias de Composer"
            fi
        }
    elif [ ! -f "composer.json" ]; then
        print_warning "composer.json no encontrado - omitiendo formateo PHP"
    else
        print_warning "Composer no disponible - omitiendo formateo PHP"
    fi
    
    # ESLint (JavaScript) - Updated to use new path building function
    if [ -f "eslint.config.js" ] && command -v npx >/dev/null 2>&1; then
        # Build specific paths for selected components using the new function
        print_info "Building JavaScript paths for selected components..."
        JS_PATHS=($(build_js_paths_for_formatting))
        
        if [ ${#JS_PATHS[@]} -gt 0 ]; then
            print_info "Found ${#JS_PATHS[@]} component path(s) for JavaScript formatting"
            log_info "JavaScript paths: ${JS_PATHS[*]}"
            if [ -d "node_modules" ]; then
                print_info "Formateando código JavaScript con ESLint..."
                echo ""
                npx eslint --fix "${JS_PATHS[@]}" --cache 2>/dev/null || print_warning "ESLint: revisar warnings"
                echo ""
            elif [ -f "package.json" ]; then
                print_warning "node_modules no encontrado"
                read -p "¿Instalar dependencias de npm? (y/n): " INSTALL < /dev/tty
                [[ $INSTALL =~ ^[Yy]$ ]] && {
                    print_info "Instalando dependencias..."
                    if npm install; then
                        print_info "Formateando código JavaScript..."
                        npx eslint --fix "${JS_PATHS[@]}" --cache 2>/dev/null || print_success "JavaScript formateado"
                    else
                        print_error "Error al instalar dependencias de npm"
                    fi
                }
            else
                print_warning "package.json no encontrado - omitiendo formateo JavaScript"
            fi
        else
            print_info "No hay archivos JavaScript para formatear en los componentes seleccionados"
            log_info "No JavaScript files found for formatting in selected components"
        fi
    else
        print_warning "ESLint no disponible - omitiendo formateo JavaScript"
    fi
    
    echo ""
    print_success "Formateo completado"
fi

# Resumen final
echo ""
echo "══════════════════════════════════════════════════════════════"
echo "  🎉 ¡Completado!"
echo "══════════════════════════════════════════════════════════════"
echo ""

if [ "$CONFIGURE_PROJECT" = true ]; then
    print_success "Archivos de configuración generados"
    echo ""
    echo "Archivos creados:"
    [ -f "phpcs.xml.dist" ] && echo "  ✅ phpcs.xml.dist (WordPress PHP Standards)"
    [ -f "phpstan.neon.dist" ] && echo "  ✅ phpstan.neon.dist (PHP Static Analysis)"
    [ -f "eslint.config.js" ] && echo "  ✅ eslint.config.js (WordPress JS Standards)"
    [ -f "composer.json" ] && echo "  ✅ composer.json (Dependencias PHP)"
    [ -f "package.json" ] && echo "  ✅ package.json (Dependencias JS)"
    [ -f "wp.code-workspace" ] && echo "  ✅ wp.code-workspace (VSCode Workspace)"
    [ -d ".vscode" ] && echo "  ✅ .vscode/ (Configuración VSCode)"
    echo ""
fi

if [ "$FORMAT_CODE" = true ]; then
    print_success "Código formateado según estándares WordPress"
    echo ""
fi

echo "══════════════════════════════════════════════════════════════"
echo "  Próximos Pasos"
echo "══════════════════════════════════════════════════════════════"
echo ""

if [ "$CONFIGURE_PROJECT" = true ]; then
    SHOW_INSTALL=false
    [ ! -d "vendor" ] && [ -f "composer.json" ] && SHOW_INSTALL=true
    [ ! -d "node_modules" ] && [ -f "package.json" ] && SHOW_INSTALL=true
    
    if [ "$SHOW_INSTALL" = true ]; then
        echo "1. Instalar dependencias:"
        [ ! -d "vendor" ] && [ -f "composer.json" ] && echo "   ${BLUE}composer install${NC}"
        [ ! -d "node_modules" ] && [ -f "package.json" ] && echo "   ${BLUE}npm install${NC}"
        echo ""
    fi
fi

echo "2. Verificar estándares:"
[ -f "composer.json" ] && echo "   ${BLUE}./vendor/bin/phpcs --standard=phpcs.xml.dist${NC}"
[ -f "package.json" ] && echo "   ${BLUE}npx eslint '**/*.{js,jsx,ts,tsx}'${NC}"
echo ""

echo "3. Formatear código:"
[ -f "composer.json" ] && echo "   ${BLUE}./vendor/bin/phpcbf --standard=phpcs.xml.dist${NC}"
[ -f "package.json" ] && echo "   ${BLUE}npx eslint --fix '**/*.{js,jsx,ts,tsx}'${NC}"
echo ""

print_success "¡Listo para desarrollar con estándares WordPress!"

# Show operation summary
show_operation_summary

echo ""

