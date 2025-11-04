#!/bin/bash

# ====================================================================
# Modular Validation Engine
# ====================================================================
# Context-aware validation system with error categorization
# Extracted from init-project.sh for better modularity and testing
# ====================================================================

# Source required dependencies
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Mock logging functions if not already defined
if ! command -v log_info >/dev/null 2>&1; then
    log_info() { echo "INFO: $1" >&2; }
fi
if ! command -v log_warning >/dev/null 2>&1; then
    log_warning() { echo "WARNING: $1" >&2; }
fi
if ! command -v log_error >/dev/null 2>&1; then
    log_error() { echo "ERROR: $1" >&2; }
fi
if ! command -v log_success >/dev/null 2>&1; then
    log_success() { echo "SUCCESS: $1" >&2; }
fi
if ! command -v log_validation_result >/dev/null 2>&1; then
    log_validation_result() { echo "VALIDATION: $1 - $2" >&2; }
fi

# Global validation state
VALIDATION_ERRORS=0
VALIDATION_WARNINGS=0
VALIDATION_INFO=0
VALIDATION_RESULTS=()
VALIDATION_CONTEXT=""

# Validation contexts
readonly CONTEXT_CONFIGURE="CONFIGURE"
readonly CONTEXT_FORMAT="FORMAT" 
readonly CONTEXT_MERGE="MERGE"
readonly CONTEXT_TEMPLATE="TEMPLATE"

# Error severity levels
readonly SEVERITY_CRITICAL="CRITICAL"
readonly SEVERITY_WARNING="WARNING"
readonly SEVERITY_INFO="INFO"

# ====================================================================
# Core Validation Functions
# ====================================================================

# Initialize validation engine
init_validation_engine() {
    local context="$1"
    
    VALIDATION_CONTEXT="$context"
    VALIDATION_ERRORS=0
    VALIDATION_WARNINGS=0
    VALIDATION_INFO=0
    VALIDATION_RESULTS=()
    
    log_info "Validation engine initialized for context: $context" "VALIDATION_ENGINE"
}

# Add validation result
add_validation_result() {
    local check_name="$1"
    local status="$2"        # PASS|FAIL|WARN|INFO
    local severity="$3"      # CRITICAL|WARNING|INFO
    local message="$4"
    local solution="${5:-}"
    local affected_files="${6:-}"
    
    local result="$check_name|$status|$severity|$message|$solution|$affected_files"
    VALIDATION_RESULTS+=("$result")
    
    case "$status" in
        "FAIL")
            case "$severity" in
                "$SEVERITY_CRITICAL") ((VALIDATION_ERRORS++)) ;;
                "$SEVERITY_WARNING") ((VALIDATION_WARNINGS++)) ;;
                "$SEVERITY_INFO") ((VALIDATION_INFO++)) ;;
            esac
            ;;
        "WARN") ((VALIDATION_WARNINGS++)) ;;
        "INFO") ((VALIDATION_INFO++)) ;;
    esac
    
    log_validation_result "$check_name" "$status" "$message"
}

# Get validation summary
get_validation_summary() {
    echo "ERRORS:$VALIDATION_ERRORS|WARNINGS:$VALIDATION_WARNINGS|INFO:$VALIDATION_INFO"
}

# Check if validation passed
validation_passed() {
    [ "$VALIDATION_ERRORS" -eq 0 ]
}

# Check if validation can continue (non-critical errors only)
validation_can_continue() {
    local critical_count=0
    
    for result in "${VALIDATION_RESULTS[@]}"; do
        IFS='|' read -r check status severity message solution files <<< "$result"
        if [ "$status" = "FAIL" ] && [ "$severity" = "$SEVERITY_CRITICAL" ]; then
            ((critical_count++))
        fi
    done
    
    [ "$critical_count" -eq 0 ]
}

# ====================================================================
# Context-Specific Validation Functions
# ====================================================================

# Validate WordPress structure - enhanced for external paths
validate_wordpress_structure() {
    local context="$1"
    local custom_path="${2:-}"
    
    # If custom path is provided, validate it directly
    if [ -n "$custom_path" ]; then
        return validate_external_wordpress_structure "$context" "$custom_path"
    fi
    
    # Use existing detection logic for backward compatibility
    if detect_wordpress_structure; then
        add_validation_result "wordpress_structure" "PASS" "$SEVERITY_INFO" \
            "WordPress structure detected: $WP_CONTENT_DIR" "" ""
        return 0
    else
        local solution="Create WordPress structure: mkdir -p wordpress/wp-content/{plugins,themes,mu-plugins} OR mkdir -p wp-content/{plugins,themes,mu-plugins}"
        add_validation_result "wordpress_structure" "FAIL" "$SEVERITY_CRITICAL" \
            "WordPress structure not found" "$solution" ""
        return 1
    fi
}

# Validate external WordPress structure at custom path
validate_external_wordpress_structure() {
    local context="$1"
    local wp_path="$2"
    
    # Convert relative path to absolute path for validation
    if [[ "$wp_path" != /* ]]; then
        local original_path="$wp_path"
        wp_path="$(cd "$(dirname "$wp_path")" 2>/dev/null && pwd)/$(basename "$wp_path")" || wp_path="$original_path"
    fi
    
    # Verify that the directory exists
    if [ ! -d "$wp_path" ]; then
        local solution="Create WordPress directory: mkdir -p '$wp_path' OR verify path is correct"
        add_validation_result "external_wordpress_path" "FAIL" "$SEVERITY_CRITICAL" \
            "WordPress directory not found: $wp_path" "$solution" "$wp_path"
        return 1
    fi
    
    # Verify wp-content and subdirectories
    if [ ! -d "$wp_path/wp-content" ]; then
        local solution="Create wp-content structure: mkdir -p '$wp_path/wp-content/{plugins,themes,mu-plugins}'"
        add_validation_result "external_wordpress_structure" "FAIL" "$SEVERITY_CRITICAL" \
            "wp-content directory not found in: $wp_path" "$solution" "$wp_path/wp-content"
        return 1
    fi
    
    if [ ! -d "$wp_path/wp-content/plugins" ]; then
        local solution="Create plugins directory: mkdir -p '$wp_path/wp-content/plugins'"
        add_validation_result "external_wordpress_plugins" "FAIL" "$SEVERITY_CRITICAL" \
            "plugins directory not found in: $wp_path/wp-content" "$solution" "$wp_path/wp-content/plugins"
        return 1
    fi
    
    if [ ! -d "$wp_path/wp-content/themes" ]; then
        local solution="Create themes directory: mkdir -p '$wp_path/wp-content/themes'"
        add_validation_result "external_wordpress_themes" "FAIL" "$SEVERITY_CRITICAL" \
            "themes directory not found in: $wp_path/wp-content" "$solution" "$wp_path/wp-content/themes"
        return 1
    fi
    
    # Create mu-plugins directory if it doesn't exist (non-critical)
    if [ ! -d "$wp_path/wp-content/mu-plugins" ]; then
        if mkdir -p "$wp_path/wp-content/mu-plugins" 2>/dev/null; then
            add_validation_result "external_wordpress_mu_plugins" "PASS" "$SEVERITY_INFO" \
                "mu-plugins directory created: $wp_path/wp-content/mu-plugins" "" "$wp_path/wp-content/mu-plugins"
        else
            local solution="Create mu-plugins directory: mkdir -p '$wp_path/wp-content/mu-plugins'"
            add_validation_result "external_wordpress_mu_plugins" "WARN" "$SEVERITY_WARNING" \
                "mu-plugins directory could not be created: $wp_path/wp-content/mu-plugins" "$solution" "$wp_path/wp-content/mu-plugins"
        fi
    fi
    
    add_validation_result "external_wordpress_structure" "PASS" "$SEVERITY_INFO" \
        "External WordPress structure validated: $wp_path" "" "$wp_path"
    return 0
}

# Validate project root calculation from WordPress path
validate_project_root_calculation() {
    local context="$1"
    local wp_path="$2"
    local expected_root="${3:-}"
    
    # Calculate project root as parent directory of WordPress path
    local calculated_root
    calculated_root="$(dirname "$wp_path")"
    
    # Verify calculated root is a valid directory
    if [ ! -d "$calculated_root" ]; then
        local solution="Verify WordPress path is correct: '$wp_path' should be inside a valid project directory"
        add_validation_result "project_root_calculation" "FAIL" "$SEVERITY_CRITICAL" \
            "Calculated project root is not a valid directory: $calculated_root" "$solution" "$calculated_root"
        return 1
    fi
    
    # Verify calculated root is writable
    if [ ! -w "$calculated_root" ]; then
        local solution="Fix permissions: chmod 755 '$calculated_root' OR run with appropriate permissions"
        add_validation_result "project_root_permissions" "FAIL" "$SEVERITY_CRITICAL" \
            "Project root is not writable: $calculated_root" "$solution" "$calculated_root"
        return 1
    fi
    
    # If expected root is provided, validate it matches
    if [ -n "$expected_root" ]; then
        local expected_abs
        expected_abs="$(cd "$expected_root" 2>/dev/null && pwd)" || expected_abs="$expected_root"
        local calculated_abs
        calculated_abs="$(cd "$calculated_root" 2>/dev/null && pwd)" || calculated_abs="$calculated_root"
        
        if [ "$expected_abs" != "$calculated_abs" ]; then
            local solution="Verify WordPress path: expected project root '$expected_root', calculated '$calculated_root'"
            add_validation_result "project_root_mismatch" "FAIL" "$SEVERITY_CRITICAL" \
                "Project root mismatch: expected '$expected_root', calculated '$calculated_root'" "$solution" "$calculated_root"
            return 1
        fi
    fi
    
    add_validation_result "project_root_calculation" "PASS" "$SEVERITY_INFO" \
        "Project root calculation validated: $calculated_root" "" "$calculated_root"
    return 0
}

# Validate write permissions
validate_write_permissions() {
    local context="$1"
    local target_dir="${2:-.}"
    
    if [ -w "$target_dir" ]; then
        add_validation_result "write_permissions" "PASS" "$SEVERITY_INFO" \
            "Write permissions verified for $target_dir" "" "$target_dir"
        return 0
    else
        local solution="Fix permissions: chmod 755 $target_dir"
        add_validation_result "write_permissions" "FAIL" "$SEVERITY_CRITICAL" \
            "No write permissions in $target_dir" "$solution" "$target_dir"
        return 1
    fi
}

# Validate disk space
validate_disk_space() {
    local context="$1"
    local required_mb="${2:-50}"
    
    if ! command -v df >/dev/null 2>&1; then
        add_validation_result "disk_space" "WARN" "$SEVERITY_WARNING" \
            "Cannot check disk space (df command not available)" "" ""
        return 0
    fi
    
    local available_space
    available_space=$(df . | tail -1 | awk '{print $4}')
    local available_mb=$((available_space / 1024))
    
    if [ "$available_mb" -lt "$required_mb" ]; then
        local solution="Free up disk space: rm -rf backup-* *.log node_modules/ vendor/"
        add_validation_result "disk_space" "FAIL" "$SEVERITY_CRITICAL" \
            "Insufficient disk space: ${available_mb}MB available, ${required_mb}MB required" \
            "$solution" ""
        return 1
    elif [ "$available_mb" -lt $((required_mb * 2)) ]; then
        add_validation_result "disk_space" "WARN" "$SEVERITY_WARNING" \
            "Low disk space: ${available_mb}MB available, ${required_mb}MB required (recommended: $((required_mb * 2))MB)" \
            "" ""
        return 0
    else
        add_validation_result "disk_space" "PASS" "$SEVERITY_INFO" \
            "Disk space check passed: ${available_mb}MB available, ${required_mb}MB required" \
            "" ""
        return 0
    fi
}

# Validate component directories
validate_component_directories() {
    local context="$1"
    local component_type="$2"  # plugins|themes|mu-plugins
    local components_array_name="$3"  # Array name as string
    
    local errors=0
    local component_dir
    
    # Use external WordPress path if available, otherwise use legacy WP_CONTENT_DIR
    if [ -n "$WORDPRESS_PATH" ]; then
        component_dir="$WORDPRESS_PATH/wp-content/$component_type"
    else
        component_dir="$WP_CONTENT_DIR/$component_type"
    fi
    
    # Get array contents using eval (compatible with bash 3.2)
    local components_list
    eval "components_list=(\"\${${components_array_name}[@]}\")"
    
    for component in "${components_list[@]}"; do
        local component_path="$component_dir/$component"
        
        if [ -d "$component_path" ]; then
            add_validation_result "${component_type}_${component}" "PASS" "$SEVERITY_INFO" \
                "$component_type directory verified: $component_path" "" "$component_path"
        else
            local solution="Create $component_type structure: mkdir -p $component_path"
            case "$component_type" in
                "plugins")
                    solution="$solution && echo '<?php // Plugin: $component' > $component_path/init.php"
                    ;;
                "themes")
                    solution="$solution && echo '<?php // Theme: $component' > $component_path/functions.php && echo '/* Theme Name: $component */' > $component_path/style.css"
                    ;;
                "mu-plugins")
                    solution="$solution && echo '<?php // MU-Plugin: $component' > $component_path/init.php"
                    ;;
            esac
            
            add_validation_result "${component_type}_${component}" "FAIL" "$SEVERITY_CRITICAL" \
                "$component_type directory not found: $component_path" "$solution" "$component_path"
            ((errors++))
        fi
    done
    
    return $errors
}

# Validate required tools for context
validate_required_tools() {
    local context="$1"
    shift
    local tools=("$@")
    
    local errors=0
    
    for tool in "${tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            add_validation_result "tool_${tool}" "PASS" "$SEVERITY_INFO" \
                "$tool is available" "" ""
        else
            local solution=""
            case "$tool" in
                "jq")
                    solution="Install jq: brew install jq (macOS) | sudo apt-get install jq (Ubuntu) | sudo yum install jq (CentOS)"
                    ;;
                "npm")
                    solution="Install Node.js and npm: https://nodejs.org/"
                    ;;
                "composer")
                    solution="Install Composer: https://getcomposer.org/"
                    ;;
                *)
                    solution="Install $tool using your system package manager"
                    ;;
            esac
            
            local severity="$SEVERITY_CRITICAL"
            if [ "$context" = "$CONTEXT_FORMAT" ] && [[ "$tool" =~ ^(npm|composer)$ ]]; then
                severity="$SEVERITY_WARNING"  # Optional for formatting
            fi
            
            add_validation_result "tool_${tool}" "FAIL" "$severity" \
                "$tool is required for $context but not available" "$solution" ""
            
            if [ "$severity" = "$SEVERITY_CRITICAL" ]; then
                ((errors++))
            fi
        fi
    done
    
    return $errors
}

# Validate template files
validate_template_files() {
    local context="$1"
    shift
    local required_templates=("$@")
    
    local errors=0
    
    for template in "${required_templates[@]}"; do
        if [ -f "$template" ]; then
            add_validation_result "template_${template}" "PASS" "$SEVERITY_INFO" \
                "Template file found: $template" "" "$template"
        else
            local solution="Download template: curl -O https://raw.githubusercontent.com/tu-usuario/wp-init/main/$template"
            add_validation_result "template_${template}" "FAIL" "$SEVERITY_CRITICAL" \
                "Required template file not found: $template" "$solution" "$template"
            ((errors++))
        fi
    done
    
    return $errors
}

# Validate optional template files
validate_optional_template_files() {
    local context="$1"
    shift
    local optional_templates=("$@")
    
    for template in "${optional_templates[@]}"; do
        if [ -f "$template" ]; then
            add_validation_result "optional_template_${template}" "PASS" "$SEVERITY_INFO" \
                "Optional template file found: $template" "" "$template"
        else
            add_validation_result "optional_template_${template}" "WARN" "$SEVERITY_WARNING" \
                "Optional template file not found: $template (will be skipped)" \
                "Download if needed: curl -O https://raw.githubusercontent.com/tu-usuario/wp-init/main/$template" "$template"
        fi
    done
    
    return 0
}

# Validate project slug
validate_project_slug() {
    local context="$1"
    local slug="$2"
    
    if [ -z "$slug" ]; then
        add_validation_result "project_slug" "INFO" "$SEVERITY_INFO" \
            "No project slug provided" "" ""
        return 0
    fi
    
    if [[ "$slug" =~ ^[a-z0-9-]+$ ]]; then
        add_validation_result "project_slug" "PASS" "$SEVERITY_INFO" \
            "Project slug validated: $slug" "" ""
        return 0
    else
        local solution="Use only lowercase letters, numbers, and hyphens. Example: my-project-name"
        add_validation_result "project_slug" "FAIL" "$SEVERITY_CRITICAL" \
            "Invalid project slug: $slug" "$solution" ""
        return 1
    fi
}

# ====================================================================
# Context-Specific Validation Orchestrators
# ====================================================================

# Validate CONFIGURE context
validate_configure_context() {
    local selected_plugins=("${SELECTED_PLUGINS[@]}")
    local selected_themes=("${SELECTED_THEMES[@]}")
    local selected_mu_plugins=("${SELECTED_MU_PLUGINS[@]}")
    local project_slug="$PROJECT_SLUG"
    
    init_validation_engine "$CONTEXT_CONFIGURE"
    
    # Core validations - enhanced for external WordPress paths
    if [ -n "$WORDPRESS_PATH" ]; then
        # External WordPress path validation
        validate_external_wordpress_structure "$CONTEXT_CONFIGURE" "$WORDPRESS_PATH"
        validate_project_root_calculation "$CONTEXT_CONFIGURE" "$WORDPRESS_PATH" "$PROJECT_ROOT"
        validate_write_permissions "$CONTEXT_CONFIGURE" "$PROJECT_ROOT"
    else
        # Legacy validation for backward compatibility
        validate_wordpress_structure "$CONTEXT_CONFIGURE"
        validate_write_permissions "$CONTEXT_CONFIGURE"
    fi
    
    # Calculate required disk space based on components
    local total_components=$((${#selected_plugins[@]} + ${#selected_themes[@]} + ${#selected_mu_plugins[@]}))
    local required_space=$((50 + total_components * 20 + 80))  # Base + components + tools
    validate_disk_space "$CONTEXT_CONFIGURE" "$required_space"
    
    # Component validations
    if [ ${#selected_plugins[@]} -gt 0 ]; then
        validate_component_directories "$CONTEXT_CONFIGURE" "plugins" "selected_plugins"
    fi
    if [ ${#selected_themes[@]} -gt 0 ]; then
        validate_component_directories "$CONTEXT_CONFIGURE" "themes" "selected_themes"
    fi
    if [ ${#selected_mu_plugins[@]} -gt 0 ]; then
        validate_component_directories "$CONTEXT_CONFIGURE" "mu-plugins" "selected_mu_plugins"
    fi
    
    # Tool validations (optional for configure)
    local optional_tools=()
    if [ "$total_components" -gt 0 ]; then
        optional_tools+=("npm" "composer")
    fi
    
    for tool in "${optional_tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            add_validation_result "tool_${tool}" "PASS" "$SEVERITY_INFO" \
                "$tool is available for configuration" "" ""
        else
            add_validation_result "tool_${tool}" "WARN" "$SEVERITY_WARNING" \
                "$tool not available - some configuration will be limited" \
                "Install $tool for full functionality" ""
        fi
    done
    
    # Template validations - use INIT_SCRIPT_DIR to find templates relative to init-project.sh location
    local required_templates=("$INIT_SCRIPT_DIR/templates/.gitignore.template")
    local optional_templates=("$INIT_SCRIPT_DIR/templates/bitbucket-pipelines.yml.template" "$INIT_SCRIPT_DIR/templates/commitlint.config.cjs.template" "$INIT_SCRIPT_DIR/templates/lighthouserc.js.template" "$INIT_SCRIPT_DIR/templates/Makefile.template")
    
    validate_template_files "$CONTEXT_CONFIGURE" "${required_templates[@]}"
    validate_optional_template_files "$CONTEXT_CONFIGURE" "${optional_templates[@]}"
    
    # Project slug validation
    validate_project_slug "$CONTEXT_CONFIGURE" "$project_slug"
    
    return $VALIDATION_ERRORS
}

# Validate FORMAT context
validate_format_context() {
    local selected_plugins=("${SELECTED_PLUGINS[@]}")
    local selected_themes=("${SELECTED_THEMES[@]}")
    local selected_mu_plugins=("${SELECTED_MU_PLUGINS[@]}")
    
    init_validation_engine "$CONTEXT_FORMAT"
    
    # Core validations - enhanced for external WordPress paths
    if [ -n "$WORDPRESS_PATH" ]; then
        # External WordPress path validation
        validate_external_wordpress_structure "$CONTEXT_FORMAT" "$WORDPRESS_PATH"
        validate_project_root_calculation "$CONTEXT_FORMAT" "$WORDPRESS_PATH" "$PROJECT_ROOT"
        validate_write_permissions "$CONTEXT_FORMAT" "$PROJECT_ROOT"
    else
        # Legacy validation for backward compatibility
        validate_wordpress_structure "$CONTEXT_FORMAT"
        validate_write_permissions "$CONTEXT_FORMAT"
    fi
    validate_disk_space "$CONTEXT_FORMAT" 70  # Less space needed for formatting
    
    # Component validations
    if [ ${#selected_plugins[@]} -gt 0 ]; then
        validate_component_directories "$CONTEXT_FORMAT" "plugins" "selected_plugins"
    fi
    if [ ${#selected_themes[@]} -gt 0 ]; then
        validate_component_directories "$CONTEXT_FORMAT" "themes" "selected_themes"
    fi
    if [ ${#selected_mu_plugins[@]} -gt 0 ]; then
        validate_component_directories "$CONTEXT_FORMAT" "mu-plugins" "selected_mu_plugins"
    fi
    
    # Check for existing formatting tools (optional)
    local formatting_tools=()
    
    # Check for PHP files and tools
    local has_php_files=false
    for component_type in "plugins" "themes" "mu-plugins"; do
        local component_array_name="selected_${component_type}"
        
        # Get array contents using eval (compatible with bash 3.2)
        local components_list
        eval "components_list=(\"\${${component_array_name}[@]}\")"
        
        for component in "${components_list[@]}"; do
            local component_path
            if [ -n "$WORDPRESS_PATH" ]; then
                component_path="$WORDPRESS_PATH/wp-content/$component_type/$component"
            else
                component_path="$WP_CONTENT_DIR/$component_type/$component"
            fi
            
            if [ -d "$component_path" ] && \
               find "$component_path" -name "*.php" -type f | head -1 | grep -q .; then
                has_php_files=true
                break 2
            fi
        done
    done
    
    if [ "$has_php_files" = true ]; then
        if [ -f "vendor/bin/phpcbf" ] || [ -f "composer.json" ]; then
            add_validation_result "php_formatting" "PASS" "$SEVERITY_INFO" \
                "PHP formatting tools available" "" ""
        else
            add_validation_result "php_formatting" "WARN" "$SEVERITY_WARNING" \
                "PHP formatting tools not available - run 'composer install' after configuration" \
                "composer install" ""
        fi
    fi
    
    # Check for JS files and tools
    local has_js_files=false
    for component_type in "plugins" "themes" "mu-plugins"; do
        local component_array_name="selected_${component_type}"
        
        # Get array contents using eval (compatible with bash 3.2)
        local components_list
        eval "components_list=(\"\${${component_array_name}[@]}\")"
        
        for component in "${components_list[@]}"; do
            local component_path
            if [ -n "$WORDPRESS_PATH" ]; then
                component_path="$WORDPRESS_PATH/wp-content/$component_type/$component"
            else
                component_path="$WP_CONTENT_DIR/$component_type/$component"
            fi
            
            if [ -d "$component_path" ] && \
               find "$component_path" \( -name "*.js" -o -name "*.jsx" -o -name "*.ts" -o -name "*.tsx" \) -type f | head -1 | grep -q .; then
                has_js_files=true
                break 2
            fi
        done
    done
    
    if [ "$has_js_files" = true ]; then
        if [ -f "node_modules/.bin/eslint" ] || [ -f "package.json" ]; then
            add_validation_result "js_formatting" "PASS" "$SEVERITY_INFO" \
                "JavaScript formatting tools available" "" ""
        else
            add_validation_result "js_formatting" "WARN" "$SEVERITY_WARNING" \
                "JavaScript formatting tools not available - run 'npm install' after configuration" \
                "npm install" ""
        fi
    fi
    
    return $VALIDATION_ERRORS
}

# Validate MERGE context
validate_merge_context() {
    init_validation_engine "$CONTEXT_MERGE"
    
    # Core validations - enhanced for external WordPress paths
    if [ -n "$WORDPRESS_PATH" ]; then
        # External WordPress path validation
        validate_external_wordpress_structure "$CONTEXT_MERGE" "$WORDPRESS_PATH"
        validate_project_root_calculation "$CONTEXT_MERGE" "$WORDPRESS_PATH" "$PROJECT_ROOT"
        validate_write_permissions "$CONTEXT_MERGE" "$PROJECT_ROOT"
    else
        # Legacy validation for backward compatibility
        validate_wordpress_structure "$CONTEXT_MERGE"
        validate_write_permissions "$CONTEXT_MERGE"
    fi
    validate_disk_space "$CONTEXT_MERGE" 100  # More space needed for backups
    
    # jq is required for merge operations
    validate_required_tools "$CONTEXT_MERGE" "jq"
    
    # Validate existing configuration files for merging
    local config_files=("package.json" "composer.json")
    
    for config_file in "${config_files[@]}"; do
        if [ -f "$config_file" ]; then
            # Validate JSON syntax
            if command -v jq >/dev/null 2>&1 && jq empty "$config_file" 2>/dev/null; then
                add_validation_result "config_${config_file}" "PASS" "$SEVERITY_INFO" \
                    "Configuration file valid for merging: $config_file" "" "$config_file"
            else
                local solution="Fix JSON syntax in $config_file or use Mode 2 (configure only) instead"
                add_validation_result "config_${config_file}" "FAIL" "$SEVERITY_CRITICAL" \
                    "Invalid JSON syntax in $config_file" "$solution" "$config_file"
            fi
        else
            add_validation_result "config_${config_file}" "INFO" "$SEVERITY_INFO" \
                "Configuration file not found: $config_file (will be created)" "" "$config_file"
        fi
    done
    
    return $VALIDATION_ERRORS
}

# Validate TEMPLATE context
validate_template_context() {
    init_validation_engine "$CONTEXT_TEMPLATE"
    
    # Core validations
    validate_write_permissions "$CONTEXT_TEMPLATE"
    validate_disk_space "$CONTEXT_TEMPLATE" 30  # Minimal space for templates
    
    # All template files validation - use INIT_SCRIPT_DIR to find templates relative to init-project.sh location
    local all_templates=(
        "$INIT_SCRIPT_DIR/templates/.gitignore.template"
        "$INIT_SCRIPT_DIR/templates/bitbucket-pipelines.yml.template"
        "$INIT_SCRIPT_DIR/templates/commitlint.config.cjs.template"
        "$INIT_SCRIPT_DIR/templates/lighthouserc.js.template"
        "$INIT_SCRIPT_DIR/templates/Makefile.template"
    )
    
    validate_template_files "$CONTEXT_TEMPLATE" "${all_templates[@]}"
    
    return $VALIDATION_ERRORS
}

# ====================================================================
# Main Validation Interface
# ====================================================================

# Main validation function - context-aware entry point
validate_system() {
    local context="$1"
    local mode="${2:-1}"
    
    case "$context" in
        "$CONTEXT_CONFIGURE")
            validate_configure_context
            ;;
        "$CONTEXT_FORMAT")
            validate_format_context
            ;;
        "$CONTEXT_MERGE")
            validate_merge_context
            ;;
        "$CONTEXT_TEMPLATE")
            validate_template_context
            ;;
        *)
            echo "Error: Unknown validation context: $context" >&2
            return 1
            ;;
    esac
    
    local exit_code=$?
    
    # Log summary
    log_info "Validation completed for context $context: $(get_validation_summary)" "VALIDATION_ENGINE"
    
    return $exit_code
}

# Display validation results
display_validation_results() {
    local show_all="${1:-false}"
    
    echo ""
    echo "📊 Validation Results:"
    echo "  • Errors: $VALIDATION_ERRORS"
    echo "  • Warnings: $VALIDATION_WARNINGS"
    echo "  • Info: $VALIDATION_INFO"
    echo ""
    
    if [ "$show_all" = "true" ] || [ "$VALIDATION_ERRORS" -gt 0 ] || [ "$VALIDATION_WARNINGS" -gt 0 ]; then
        for result in "${VALIDATION_RESULTS[@]}"; do
            IFS='|' read -r check status severity message solution files <<< "$result"
            
            local icon=""
            local color=""
            case "$status" in
                "PASS") icon="✅"; color="$GREEN" ;;
                "FAIL") 
                    case "$severity" in
                        "$SEVERITY_CRITICAL") icon="❌"; color="$RED" ;;
                        "$SEVERITY_WARNING") icon="⚠️"; color="$YELLOW" ;;
                        "$SEVERITY_INFO") icon="ℹ️"; color="$BLUE" ;;
                    esac
                    ;;
                "WARN") icon="⚠️"; color="$YELLOW" ;;
                "INFO") icon="ℹ️"; color="$BLUE" ;;
            esac
            
            echo -e "${color}${icon} ${check}: ${message}${NC}"
            
            if [ -n "$solution" ] && [ "$status" = "FAIL" ]; then
                echo -e "   ${BLUE}💡 Solution: ${solution}${NC}"
            fi
            
            if [ -n "$files" ]; then
                echo -e "   ${MAGENTA}📁 Files: ${files}${NC}"
            fi
        done
        echo ""
    fi
}

# Export validation results for external processing
export_validation_results() {
    local format="${1:-json}"
    local output_file="${2:-}"
    
    case "$format" in
        "json")
            local json_output="{"
            json_output+='"summary":{"errors":'$VALIDATION_ERRORS',"warnings":'$VALIDATION_WARNINGS',"info":'$VALIDATION_INFO'},'
            json_output+='"context":"'$VALIDATION_CONTEXT'",'
            json_output+='"results":['
            
            local first=true
            for result in "${VALIDATION_RESULTS[@]}"; do
                IFS='|' read -r check status severity message solution files <<< "$result"
                
                [ "$first" = false ] && json_output+=","
                json_output+='{"check":"'$check'","status":"'$status'","severity":"'$severity'","message":"'$message'","solution":"'$solution'","files":"'$files'"}'
                first=false
            done
            
            json_output+=']}'
            
            if [ -n "$output_file" ]; then
                echo "$json_output" > "$output_file"
            else
                echo "$json_output"
            fi
            ;;
        *)
            echo "Error: Unsupported export format: $format" >&2
            return 1
            ;;
    esac
}