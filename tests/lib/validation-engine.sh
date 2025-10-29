#!/bin/bash

# ====================================================================
# Modular Validation Engine
# ====================================================================
# Context-aware validation system with error categorization
# Extracted from init-project.sh for better modularity and testing
# ====================================================================

# Source required dependencies
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

# Validate WordPress structure
validate_wordpress_structure() {
    local context="$1"
    
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
    local -n components_ref=$3  # Array reference
    
    local errors=0
    local component_dir="$WP_CONTENT_DIR/$component_type"
    
    for component in "${components_ref[@]}"; do
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
    
    # Core validations
    validate_wordpress_structure "$CONTEXT_CONFIGURE"
    validate_write_permissions "$CONTEXT_CONFIGURE"
    
    # Calculate required disk space based on components
    local total_components=$((${#selected_plugins[@]} + ${#selected_themes[@]} + ${#selected_mu_plugins[@]}))
    local required_space=$((50 + total_components * 20 + 80))  # Base + components + tools
    validate_disk_space "$CONTEXT_CONFIGURE" "$required_space"
    
    # Component validations
    if [ ${#selected_plugins[@]} -gt 0 ]; then
        validate_component_directories "$CONTEXT_CONFIGURE" "plugins" selected_plugins
    fi
    if [ ${#selected_themes[@]} -gt 0 ]; then
        validate_component_directories "$CONTEXT_CONFIGURE" "themes" selected_themes
    fi
    if [ ${#selected_mu_plugins[@]} -gt 0 ]; then
        validate_component_directories "$CONTEXT_CONFIGURE" "mu-plugins" selected_mu_plugins
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
    
    # Template validations
    local required_templates=(".gitignore.template")
    local optional_templates=("bitbucket-pipelines.yml.template" "commitlint.config.cjs.template" "lighthouserc.js.template" "Makefile.template")
    
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
    
    # Core validations
    validate_wordpress_structure "$CONTEXT_FORMAT"
    validate_write_permissions "$CONTEXT_FORMAT"
    validate_disk_space "$CONTEXT_FORMAT" 70  # Less space needed for formatting
    
    # Component validations
    if [ ${#selected_plugins[@]} -gt 0 ]; then
        validate_component_directories "$CONTEXT_FORMAT" "plugins" selected_plugins
    fi
    if [ ${#selected_themes[@]} -gt 0 ]; then
        validate_component_directories "$CONTEXT_FORMAT" "themes" selected_themes
    fi
    if [ ${#selected_mu_plugins[@]} -gt 0 ]; then
        validate_component_directories "$CONTEXT_FORMAT" "mu-plugins" selected_mu_plugins
    fi
    
    # Check for existing formatting tools (optional)
    local formatting_tools=()
    
    # Check for PHP files and tools
    local has_php_files=false
    for component_type in "plugins" "themes" "mu-plugins"; do
        local component_array_name="selected_${component_type}"
        local -n components_ref=$component_array_name
        
        for component in "${components_ref[@]}"; do
            if [ -d "$WP_CONTENT_DIR/$component_type/$component" ] && \
               find "$WP_CONTENT_DIR/$component_type/$component" -name "*.php" -type f | head -1 | grep -q .; then
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
        local -n components_ref=$component_array_name
        
        for component in "${components_ref[@]}"; do
            if [ -d "$WP_CONTENT_DIR/$component_type/$component" ] && \
               find "$WP_CONTENT_DIR/$component_type/$component" \( -name "*.js" -o -name "*.jsx" -o -name "*.ts" -o -name "*.tsx" \) -type f | head -1 | grep -q .; then
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
    
    # Core validations
    validate_wordpress_structure "$CONTEXT_MERGE"
    validate_write_permissions "$CONTEXT_MERGE"
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
    
    # All template files validation
    local all_templates=(
        ".gitignore.template"
        "bitbucket-pipelines.yml.template"
        "commitlint.config.cjs.template"
        "lighthouserc.js.template"
        "Makefile.template"
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