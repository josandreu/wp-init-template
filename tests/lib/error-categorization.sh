#!/bin/bash

# ====================================================================
# Error Categorization System
# ====================================================================
# Comprehensive error categorization with specific error codes and solutions
# Context-aware error handling for different operation modes
# ====================================================================

# Source required dependencies
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Error categories
readonly ERROR_CATEGORY_CRITICAL="CRITICAL"
readonly ERROR_CATEGORY_WARNING="WARNING"
readonly ERROR_CATEGORY_INFO="INFO"

# Error contexts
readonly ERROR_CONTEXT_SYSTEM="SYSTEM"
readonly ERROR_CONTEXT_COMPONENT="COMPONENT"
readonly ERROR_CONTEXT_TEMPLATE="TEMPLATE"
readonly ERROR_CONTEXT_TOOL="TOOL"
readonly ERROR_CONTEXT_FILE="FILE"
readonly ERROR_CONTEXT_VALIDATION="VALIDATION"

# Global error tracking
ERROR_REGISTRY=()
ERROR_COUNTS=()
ERROR_SOLUTIONS=()

# ====================================================================
# Error Code Definitions
# ====================================================================

# System errors (E1xxx)
readonly E1001="WORDPRESS_STRUCTURE_NOT_FOUND"
readonly E1002="WRITE_PERMISSIONS_DENIED"
readonly E1003="INSUFFICIENT_DISK_SPACE"
readonly E1004="INVALID_PROJECT_DIRECTORY"
readonly E1005="SYSTEM_DEPENDENCY_MISSING"

# Component errors (E2xxx)
readonly E2001="COMPONENT_DIRECTORY_NOT_FOUND"
readonly E2002="COMPONENT_INVALID_STRUCTURE"
readonly E2003="NO_COMPONENTS_SELECTED"
readonly E2004="COMPONENT_PERMISSION_DENIED"
readonly E2005="COMPONENT_CORRUPTED"

# Template errors (E3xxx)
readonly E3001="TEMPLATE_FILE_NOT_FOUND"
readonly E3002="TEMPLATE_SYNTAX_ERROR"
readonly E3003="TEMPLATE_PERMISSION_DENIED"
readonly E3004="TEMPLATE_CORRUPTED"
readonly E3005="TEMPLATE_VERSION_MISMATCH"

# Tool errors (E4xxx)
readonly E4001="JQ_NOT_AVAILABLE"
readonly E4002="NPM_NOT_AVAILABLE"
readonly E4003="COMPOSER_NOT_AVAILABLE"
readonly E4004="TOOL_VERSION_INCOMPATIBLE"
readonly E4005="TOOL_EXECUTION_FAILED"

# File operation errors (E5xxx)
readonly E5001="BACKUP_CREATION_FAILED"
readonly E5002="FILE_COPY_FAILED"
readonly E5003="FILE_WRITE_FAILED"
readonly E5004="FILE_READ_FAILED"
readonly E5005="MERGE_OPERATION_FAILED"

# Validation errors (E6xxx)
readonly E6001="INVALID_PROJECT_SLUG"
readonly E6002="INVALID_JSON_SYNTAX"
readonly E6003="MISSING_REQUIRED_FIELD"
readonly E6004="VALIDATION_TIMEOUT"
readonly E6005="VALIDATION_DEPENDENCY_FAILED"

# ====================================================================
# Error Information Database
# ====================================================================

# Initialize error information database
init_error_database() {
    # System errors
    register_error "$E1001" "$ERROR_CATEGORY_CRITICAL" "$ERROR_CONTEXT_SYSTEM" \
        "WordPress structure not found" \
        "Create WordPress structure: mkdir -p wordpress/wp-content/{plugins,themes,mu-plugins} OR mkdir -p wp-content/{plugins,themes,mu-plugins}" \
        "Verify you're in the correct directory and create the required WordPress directory structure"

    register_error "$E1002" "$ERROR_CATEGORY_CRITICAL" "$ERROR_CONTEXT_SYSTEM" \
        "Write permissions denied" \
        "Fix permissions: chmod 755 . && chmod 644 *" \
        "Ensure the current user has write permissions to the project directory"

    register_error "$E1003" "$ERROR_CATEGORY_CRITICAL" "$ERROR_CONTEXT_SYSTEM" \
        "Insufficient disk space" \
        "Free up disk space: rm -rf backup-* *.log node_modules/ vendor/" \
        "Clean up temporary files and ensure adequate disk space for the operation"

    register_error "$E1004" "$ERROR_CATEGORY_CRITICAL" "$ERROR_CONTEXT_SYSTEM" \
        "Invalid project directory" \
        "Navigate to a valid WordPress project directory" \
        "Ensure you're running the script from a WordPress project root directory"

    register_error "$E1005" "$ERROR_CATEGORY_WARNING" "$ERROR_CONTEXT_SYSTEM" \
        "System dependency missing" \
        "Install missing system dependencies using your package manager" \
        "Some features may be limited without all system dependencies"

    # Component errors
    register_error "$E2001" "$ERROR_CATEGORY_CRITICAL" "$ERROR_CONTEXT_COMPONENT" \
        "Component directory not found" \
        "Create component directory structure" \
        "The selected component directory does not exist and needs to be created"

    register_error "$E2002" "$ERROR_CATEGORY_WARNING" "$ERROR_CONTEXT_COMPONENT" \
        "Component has invalid structure" \
        "Review and fix component structure according to WordPress standards" \
        "Component exists but may not follow WordPress coding standards"

    register_error "$E2003" "$ERROR_CATEGORY_CRITICAL" "$ERROR_CONTEXT_COMPONENT" \
        "No components selected for processing" \
        "Select at least one component (plugin, theme, or mu-plugin) to proceed" \
        "The script requires at least one component to be selected for processing"

    register_error "$E2004" "$ERROR_CATEGORY_CRITICAL" "$ERROR_CONTEXT_COMPONENT" \
        "Component permission denied" \
        "Fix component directory permissions: chmod -R 755 component_directory" \
        "Insufficient permissions to access or modify the component directory"

    register_error "$E2005" "$ERROR_CATEGORY_WARNING" "$ERROR_CONTEXT_COMPONENT" \
        "Component appears corrupted" \
        "Restore component from backup or recreate" \
        "Component files may be corrupted or incomplete"

    # Template errors
    register_error "$E3001" "$ERROR_CATEGORY_CRITICAL" "$ERROR_CONTEXT_TEMPLATE" \
        "Template file not found" \
        "Download template: curl -O https://raw.githubusercontent.com/tu-usuario/wp-init/main/TEMPLATE_FILE" \
        "Required template file is missing and needs to be downloaded"

    register_error "$E3002" "$ERROR_CATEGORY_WARNING" "$ERROR_CONTEXT_TEMPLATE" \
        "Template syntax error" \
        "Review and fix template syntax" \
        "Template file contains syntax errors that may affect processing"

    register_error "$E3003" "$ERROR_CATEGORY_CRITICAL" "$ERROR_CONTEXT_TEMPLATE" \
        "Template permission denied" \
        "Fix template file permissions: chmod 644 template_file" \
        "Insufficient permissions to read the template file"

    register_error "$E3004" "$ERROR_CATEGORY_WARNING" "$ERROR_CONTEXT_TEMPLATE" \
        "Template file corrupted" \
        "Re-download template file" \
        "Template file appears to be corrupted or incomplete"

    register_error "$E3005" "$ERROR_CATEGORY_INFO" "$ERROR_CONTEXT_TEMPLATE" \
        "Template version mismatch" \
        "Update template to latest version" \
        "Template file version may not match current script requirements"

    # Tool errors
    register_error "$E4001" "$ERROR_CATEGORY_CRITICAL" "$ERROR_CONTEXT_TOOL" \
        "jq is required but not available" \
        "Install jq: brew install jq (macOS) | sudo apt-get install jq (Ubuntu) | sudo yum install jq (CentOS)" \
        "jq is required for JSON processing operations"

    register_error "$E4002" "$ERROR_CATEGORY_WARNING" "$ERROR_CONTEXT_TOOL" \
        "npm is not available" \
        "Install Node.js and npm: https://nodejs.org/" \
        "npm is needed for JavaScript dependency management"

    register_error "$E4003" "$ERROR_CATEGORY_WARNING" "$ERROR_CONTEXT_TOOL" \
        "Composer is not available" \
        "Install Composer: https://getcomposer.org/" \
        "Composer is needed for PHP dependency management"

    register_error "$E4004" "$ERROR_CATEGORY_WARNING" "$ERROR_CONTEXT_TOOL" \
        "Tool version incompatible" \
        "Update tool to compatible version" \
        "The installed tool version may not be compatible with current requirements"

    register_error "$E4005" "$ERROR_CATEGORY_CRITICAL" "$ERROR_CONTEXT_TOOL" \
        "Tool execution failed" \
        "Check tool installation and permissions" \
        "Tool is available but failed to execute properly"

    # File operation errors
    register_error "$E5001" "$ERROR_CATEGORY_CRITICAL" "$ERROR_CONTEXT_FILE" \
        "Backup creation failed" \
        "Check disk space and permissions: df -h . && ls -la ." \
        "Unable to create backup before modifying files"

    register_error "$E5002" "$ERROR_CATEGORY_CRITICAL" "$ERROR_CONTEXT_FILE" \
        "File copy operation failed" \
        "Check source file exists and target directory is writable" \
        "Unable to copy file to target location"

    register_error "$E5003" "$ERROR_CATEGORY_CRITICAL" "$ERROR_CONTEXT_FILE" \
        "File write operation failed" \
        "Check disk space and write permissions" \
        "Unable to write content to file"

    register_error "$E5004" "$ERROR_CATEGORY_CRITICAL" "$ERROR_CONTEXT_FILE" \
        "File read operation failed" \
        "Check file exists and is readable: ls -la file_name" \
        "Unable to read content from file"

    register_error "$E5005" "$ERROR_CATEGORY_CRITICAL" "$ERROR_CONTEXT_FILE" \
        "JSON merge operation failed" \
        "Verify JSON syntax: jq empty file.json" \
        "Unable to merge JSON configuration files"

    # Validation errors
    register_error "$E6001" "$ERROR_CATEGORY_CRITICAL" "$ERROR_CONTEXT_VALIDATION" \
        "Invalid project slug format" \
        "Use only lowercase letters, numbers, and hyphens. Example: my-project-name" \
        "Project slug must follow WordPress naming conventions"

    register_error "$E6002" "$ERROR_CATEGORY_CRITICAL" "$ERROR_CONTEXT_VALIDATION" \
        "Invalid JSON syntax" \
        "Fix JSON syntax errors: jq . file.json" \
        "Configuration file contains invalid JSON syntax"

    register_error "$E6003" "$ERROR_CATEGORY_WARNING" "$ERROR_CONTEXT_VALIDATION" \
        "Missing required field" \
        "Add missing required field to configuration" \
        "Configuration is missing a required field"

    register_error "$E6004" "$ERROR_CATEGORY_WARNING" "$ERROR_CONTEXT_VALIDATION" \
        "Validation timeout" \
        "Reduce validation scope or increase timeout" \
        "Validation process took longer than expected"

    register_error "$E6005" "$ERROR_CATEGORY_CRITICAL" "$ERROR_CONTEXT_VALIDATION" \
        "Validation dependency failed" \
        "Fix dependency issues before proceeding" \
        "Validation cannot proceed due to failed dependencies"
}

# Register error information
register_error() {
    local error_code="$1"
    local category="$2"
    local context="$3"
    local message="$4"
    local solution="$5"
    local description="$6"
    
    ERROR_REGISTRY["$error_code"]="$category|$context|$message|$solution|$description"
}

# ====================================================================
# Error Handling Functions
# ====================================================================

# Get error information
get_error_info() {
    local error_code="$1"
    
    if [[ -n "${ERROR_REGISTRY[$error_code]:-}" ]]; then
        echo "${ERROR_REGISTRY[$error_code]}"
    else
        echo "UNKNOWN|UNKNOWN|Unknown error code: $error_code|Check documentation|Unknown error occurred"
    fi
}

# Parse error information
parse_error_info() {
    local error_info="$1"
    local field="$2"  # category|context|message|solution|description
    
    IFS='|' read -r category context message solution description <<< "$error_info"
    
    case "$field" in
        "category") echo "$category" ;;
        "context") echo "$context" ;;
        "message") echo "$message" ;;
        "solution") echo "$solution" ;;
        "description") echo "$description" ;;
        *) echo "$error_info" ;;
    esac
}

# Create categorized error
create_error() {
    local error_code="$1"
    local details="${2:-}"
    local affected_files="${3:-}"
    
    local error_info
    error_info=$(get_error_info "$error_code")
    
    local category
    category=$(parse_error_info "$error_info" "category")
    local context
    context=$(parse_error_info "$error_info" "context")
    local message
    message=$(parse_error_info "$error_info" "message")
    local solution
    solution=$(parse_error_info "$error_info" "solution")
    local description
    description=$(parse_error_info "$error_info" "description")
    
    # Add details to message if provided
    if [ -n "$details" ]; then
        message="$message: $details"
    fi
    
    # Create error object
    local error_object="{"
    error_object+='"code":"'$error_code'",'
    error_object+='"category":"'$category'",'
    error_object+='"context":"'$context'",'
    error_object+='"message":"'$message'",'
    error_object+='"solution":"'$solution'",'
    error_object+='"description":"'$description'",'
    error_object+='"details":"'$details'",'
    error_object+='"affected_files":"'$affected_files'",'
    error_object+='"timestamp":"'$(date -Iseconds)'"'
    error_object+="}"
    
    echo "$error_object"
}

# Display error with context-aware formatting
display_error() {
    local error_code="$1"
    local details="${2:-}"
    local affected_files="${3:-}"
    local show_solution="${4:-true}"
    
    local error_info
    error_info=$(get_error_info "$error_code")
    
    local category
    category=$(parse_error_info "$error_info" "category")
    local context
    context=$(parse_error_info "$error_info" "context")
    local message
    message=$(parse_error_info "$error_info" "message")
    local solution
    solution=$(parse_error_info "$error_info" "solution")
    local description
    description=$(parse_error_info "$error_info" "description")
    
    # Choose icon and color based on category
    local icon color
    case "$category" in
        "$ERROR_CATEGORY_CRITICAL")
            icon="❌"
            color="$RED"
            ;;
        "$ERROR_CATEGORY_WARNING")
            icon="⚠️"
            color="$YELLOW"
            ;;
        "$ERROR_CATEGORY_INFO")
            icon="ℹ️"
            color="$BLUE"
            ;;
        *)
            icon="❓"
            color="$NC"
            ;;
    esac
    
    # Display error header
    echo -e "${color}${icon} [$error_code] $message${NC}"
    
    # Add details if provided
    if [ -n "$details" ]; then
        echo -e "   ${MAGENTA}Details: $details${NC}"
    fi
    
    # Add affected files if provided
    if [ -n "$affected_files" ]; then
        echo -e "   ${MAGENTA}Affected files: $affected_files${NC}"
    fi
    
    # Show solution if requested
    if [ "$show_solution" = "true" ] && [ -n "$solution" ]; then
        echo ""
        echo -e "   ${BLUE}💡 Solution: $solution${NC}"
    fi
    
    # Show description for critical errors
    if [ "$category" = "$ERROR_CATEGORY_CRITICAL" ] && [ -n "$description" ]; then
        echo -e "   ${BLUE}📖 Description: $description${NC}"
    fi
    
    echo ""
}

# Handle error with context-aware recovery
handle_error() {
    local error_code="$1"
    local details="${2:-}"
    local affected_files="${3:-}"
    local recovery_mode="${4:-PROMPT}"  # SKIP|CONTINUE|RETRY|PROMPT|ABORT
    
    local error_info
    error_info=$(get_error_info "$error_code")
    local category
    category=$(parse_error_info "$error_info" "category")
    
    # Display the error
    display_error "$error_code" "$details" "$affected_files"
    
    # Log the error
    log_error "[$error_code] $(parse_error_info "$error_info" "message"): $details" "ERROR_HANDLER"
    
    # Handle based on category and recovery mode
    case "$category" in
        "$ERROR_CATEGORY_CRITICAL")
            case "$recovery_mode" in
                "SKIP")
                    echo -e "${YELLOW}⏭️  Skipping critical error (may cause issues)${NC}"
                    return 0
                    ;;
                "CONTINUE")
                    echo -e "${YELLOW}⚠️  Continuing despite critical error${NC}"
                    return 0
                    ;;
                "PROMPT")
                    prompt_error_recovery "$error_code" "$details" "$affected_files"
                    return $?
                    ;;
                "ABORT"|*)
                    echo -e "${RED}🛑 Aborting due to critical error${NC}"
                    return 1
                    ;;
            esac
            ;;
        "$ERROR_CATEGORY_WARNING")
            case "$recovery_mode" in
                "SKIP"|"CONTINUE")
                    echo -e "${YELLOW}⚠️  Continuing with warning${NC}"
                    return 0
                    ;;
                "PROMPT")
                    prompt_error_recovery "$error_code" "$details" "$affected_files"
                    return $?
                    ;;
                *)
                    return 0
                    ;;
            esac
            ;;
        "$ERROR_CATEGORY_INFO")
            echo -e "${BLUE}ℹ️  Information noted${NC}"
            return 0
            ;;
        *)
            echo -e "${RED}❓ Unknown error category${NC}"
            return 1
            ;;
    esac
}

# Prompt user for error recovery
prompt_error_recovery() {
    local error_code="$1"
    local details="${2:-}"
    local affected_files="${3:-}"
    
    local error_info
    error_info=$(get_error_info "$error_code")
    local category
    category=$(parse_error_info "$error_info" "category")
    
    echo "🔄 Recovery Options:"
    
    case "$category" in
        "$ERROR_CATEGORY_CRITICAL")
            echo "   1. Abort operation (recommended)"
            echo "   2. Skip this error and continue (may cause issues)"
            echo "   3. Retry after manual fix"
            echo ""
            echo -n "Choose option (1-3): "
            read -r recovery_choice
            
            case "$recovery_choice" in
                1) return 1 ;;  # Abort
                2) return 0 ;;  # Skip
                3) return 2 ;;  # Retry
                *) return 1 ;;  # Default to abort
            esac
            ;;
        "$ERROR_CATEGORY_WARNING")
            echo "   1. Continue with warning"
            echo "   2. Skip this operation"
            echo "   3. Abort operation"
            echo ""
            echo -n "Choose option (1-3): "
            read -r recovery_choice
            
            case "$recovery_choice" in
                1) return 0 ;;  # Continue
                2) return 0 ;;  # Skip (same as continue for warnings)
                3) return 1 ;;  # Abort
                *) return 0 ;;  # Default to continue
            esac
            ;;
        *)
            return 0
            ;;
    esac
}

# ====================================================================
# Error Statistics and Reporting
# ====================================================================

# Initialize error counters
init_error_counters() {
    ERROR_COUNTS["$ERROR_CATEGORY_CRITICAL"]=0
    ERROR_COUNTS["$ERROR_CATEGORY_WARNING"]=0
    ERROR_COUNTS["$ERROR_CATEGORY_INFO"]=0
}

# Increment error counter
increment_error_counter() {
    local category="$1"
    local current=${ERROR_COUNTS["$category"]:-0}
    ERROR_COUNTS["$category"]=$((current + 1))
}

# Get error statistics
get_error_statistics() {
    local critical=${ERROR_COUNTS["$ERROR_CATEGORY_CRITICAL"]:-0}
    local warnings=${ERROR_COUNTS["$ERROR_CATEGORY_WARNING"]:-0}
    local info=${ERROR_COUNTS["$ERROR_CATEGORY_INFO"]:-0}
    
    echo "CRITICAL:$critical|WARNING:$warnings|INFO:$info"
}

# Display error summary
display_error_summary() {
    local critical=${ERROR_COUNTS["$ERROR_CATEGORY_CRITICAL"]:-0}
    local warnings=${ERROR_COUNTS["$ERROR_CATEGORY_WARNING"]:-0}
    local info=${ERROR_COUNTS["$ERROR_CATEGORY_INFO"]:-0}
    local total=$((critical + warnings + info))
    
    if [ "$total" -eq 0 ]; then
        echo -e "${GREEN}✅ No errors encountered${NC}"
        return 0
    fi
    
    echo ""
    echo "📊 Error Summary:"
    echo "  • Critical errors: $critical"
    echo "  • Warnings: $warnings"
    echo "  • Information: $info"
    echo "  • Total: $total"
    echo ""
    
    if [ "$critical" -gt 0 ]; then
        echo -e "${RED}❌ Critical errors require attention before proceeding${NC}"
        return 1
    elif [ "$warnings" -gt 0 ]; then
        echo -e "${YELLOW}⚠️  Warnings detected - review before proceeding${NC}"
        return 0
    else
        echo -e "${BLUE}ℹ️  Information messages only${NC}"
        return 0
    fi
}

# ====================================================================
# Context-Aware Error Handling
# ====================================================================

# Handle system errors
handle_system_error() {
    local error_code="$1"
    local details="${2:-}"
    local recovery_mode="${3:-PROMPT}"
    
    case "$error_code" in
        "$E1001") # WordPress structure not found
            handle_error "$error_code" "$details" "" "$recovery_mode"
            ;;
        "$E1002") # Write permissions denied
            handle_error "$error_code" "$details" "$(pwd)" "$recovery_mode"
            ;;
        "$E1003") # Insufficient disk space
            local available_space
            available_space=$(df . | tail -1 | awk '{print $4}')
            local available_mb=$((available_space / 1024))
            handle_error "$error_code" "Available: ${available_mb}MB, Required: $details" "" "$recovery_mode"
            ;;
        *)
            handle_error "$error_code" "$details" "" "$recovery_mode"
            ;;
    esac
}

# Handle component errors
handle_component_error() {
    local error_code="$1"
    local component_type="$2"
    local component_name="$3"
    local recovery_mode="${4:-PROMPT}"
    
    local component_path="$WP_CONTENT_DIR/$component_type/$component_name"
    
    case "$error_code" in
        "$E2001") # Component directory not found
            handle_error "$error_code" "$component_type: $component_name" "$component_path" "$recovery_mode"
            ;;
        *)
            handle_error "$error_code" "$component_type: $component_name" "$component_path" "$recovery_mode"
            ;;
    esac
}

# Handle tool errors
handle_tool_error() {
    local error_code="$1"
    local tool_name="$2"
    local context="${3:-}"
    local recovery_mode="${4:-PROMPT}"
    
    case "$error_code" in
        "$E4001"|"$E4002"|"$E4003") # Tool not available
            handle_error "$error_code" "$tool_name for $context" "" "$recovery_mode"
            ;;
        *)
            handle_error "$error_code" "$tool_name" "" "$recovery_mode"
            ;;
    esac
}

# Handle file operation errors
handle_file_error() {
    local error_code="$1"
    local operation="$2"
    local file_path="$3"
    local recovery_mode="${4:-PROMPT}"
    
    handle_error "$error_code" "$operation" "$file_path" "$recovery_mode"
}

# ====================================================================
# Initialization
# ====================================================================

# Initialize error categorization system
init_error_categorization() {
    # Initialize associative arrays
    declare -gA ERROR_REGISTRY
    declare -gA ERROR_COUNTS
    
    # Initialize error database
    init_error_database
    
    # Initialize counters
    init_error_counters
    
    log_info "Error categorization system initialized" "ERROR_CATEGORIZATION"
}

# Auto-initialize when sourced
if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
    init_error_categorization
fi