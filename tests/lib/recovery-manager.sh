#!/bin/bash

# ====================================================================
# Recovery and Rollback System
# ====================================================================
# Comprehensive backup and recovery system with automatic rollback capabilities
# Supports selective rollback and recovery point management
# ====================================================================

# Source required dependencies
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Global recovery state
RECOVERY_POINTS=()
RECOVERY_METADATA=()
CURRENT_RECOVERY_POINT=""
RECOVERY_BASE_DIR=""
RECOVERY_ENABLED=true

# Recovery point structure
readonly RECOVERY_POINT_PREFIX="recovery-point"
readonly RECOVERY_METADATA_FILE="recovery-metadata.json"
readonly RECOVERY_MANIFEST_FILE="recovery-manifest.txt"

# Recovery operations
readonly RECOVERY_OP_CREATE="CREATE"
readonly RECOVERY_OP_BACKUP="BACKUP"
readonly RECOVERY_OP_RESTORE="RESTORE"
readonly RECOVERY_OP_CLEANUP="CLEANUP"

# ====================================================================
# Recovery System Initialization
# ====================================================================

# Initialize recovery system
init_recovery_system() {
    local base_dir="${1:-./recovery}"
    
    RECOVERY_BASE_DIR="$base_dir"
    
    # Create recovery base directory
    if [ ! -d "$RECOVERY_BASE_DIR" ]; then
        if ! mkdir -p "$RECOVERY_BASE_DIR"; then
            log_error "Failed to create recovery base directory: $RECOVERY_BASE_DIR" "RECOVERY_MANAGER"
            RECOVERY_ENABLED=false
            return 1
        fi
    fi
    
    # Initialize recovery metadata
    local metadata_file="$RECOVERY_BASE_DIR/$RECOVERY_METADATA_FILE"
    if [ ! -f "$metadata_file" ]; then
        cat > "$metadata_file" << EOF
{
    "version": "1.0",
    "created": "$(date -Iseconds)",
    "recovery_points": [],
    "active_point": null
}
EOF
    fi
    
    log_info "Recovery system initialized: $RECOVERY_BASE_DIR" "RECOVERY_MANAGER"
    return 0
}

# Check if recovery system is enabled
is_recovery_enabled() {
    [ "$RECOVERY_ENABLED" = true ]
}

# Disable recovery system
disable_recovery() {
    RECOVERY_ENABLED=false
    log_warning "Recovery system disabled" "RECOVERY_MANAGER"
}

# Enable recovery system
enable_recovery() {
    RECOVERY_ENABLED=true
    log_info "Recovery system enabled" "RECOVERY_MANAGER"
}

# ====================================================================
# Recovery Point Management
# ====================================================================

# Generate recovery point ID
generate_recovery_point_id() {
    local operation_name="$1"
    local timestamp=$(date +%Y%m%d-%H%M%S)
    local random_suffix=$(head -c 4 /dev/urandom | xxd -p)
    
    echo "${RECOVERY_POINT_PREFIX}-${operation_name}-${timestamp}-${random_suffix}"
}

# Create recovery point
create_recovery_point() {
    local operation_name="$1"
    local description="${2:-Recovery point for $operation_name}"
    shift 2
    local files_to_backup=("$@")
    
    if ! is_recovery_enabled; then
        log_warning "Recovery system disabled - skipping recovery point creation" "RECOVERY_MANAGER"
        return 0
    fi
    
    local recovery_point_id
    recovery_point_id=$(generate_recovery_point_id "$operation_name")
    local recovery_point_dir="$RECOVERY_BASE_DIR/$recovery_point_id"
    
    log_operation_start "$RECOVERY_OP_CREATE" "Creating recovery point: $recovery_point_id"
    
    # Create recovery point directory
    if ! mkdir -p "$recovery_point_dir"; then
        log_error "Failed to create recovery point directory: $recovery_point_dir" "RECOVERY_MANAGER"
        return 1
    fi
    
    # Create manifest file
    local manifest_file="$recovery_point_dir/$RECOVERY_MANIFEST_FILE"
    cat > "$manifest_file" << EOF
# Recovery Point Manifest
# Created: $(date -Iseconds)
# Operation: $operation_name
# Description: $description
# Files backed up:
EOF
    
    # Backup files
    local backup_count=0
    local failed_backups=0
    
    for file_path in "${files_to_backup[@]}"; do
        if backup_file_to_recovery_point "$recovery_point_dir" "$file_path"; then
            echo "$file_path" >> "$manifest_file"
            ((backup_count++))
        else
            log_warning "Failed to backup file: $file_path" "RECOVERY_MANAGER"
            ((failed_backups++))
        fi
    done
    
    # Create recovery point metadata
    local metadata_file="$recovery_point_dir/metadata.json"
    cat > "$metadata_file" << EOF
{
    "id": "$recovery_point_id",
    "operation": "$operation_name",
    "description": "$description",
    "created": "$(date -Iseconds)",
    "files_backed_up": $backup_count,
    "failed_backups": $failed_backups,
    "working_directory": "$(pwd)",
    "user": "$(whoami)",
    "system": "$(uname -s)",
    "script_version": "${SCRIPT_VERSION:-unknown}"
}
EOF
    
    # Update global metadata
    update_global_recovery_metadata "$recovery_point_id" "$operation_name" "$description"
    
    # Set as current recovery point
    CURRENT_RECOVERY_POINT="$recovery_point_id"
    RECOVERY_POINTS+=("$recovery_point_id")
    
    if [ "$failed_backups" -eq 0 ]; then
        log_operation_end "$RECOVERY_OP_CREATE" "SUCCESS" "Recovery point created: $recovery_point_id ($backup_count files)"
        echo "$recovery_point_id"
        return 0
    else
        log_operation_end "$RECOVERY_OP_CREATE" "PARTIAL_SUCCESS" "Recovery point created with $failed_backups failed backups"
        echo "$recovery_point_id"
        return 0
    fi
}

# Backup file to recovery point
backup_file_to_recovery_point() {
    local recovery_point_dir="$1"
    local file_path="$2"
    
    # Skip if file doesn't exist
    if [ ! -e "$file_path" ]; then
        log_info "Skipping non-existent file: $file_path" "RECOVERY_MANAGER"
        return 0
    fi
    
    # Create relative directory structure in recovery point
    local relative_dir
    relative_dir=$(dirname "$file_path")
    local backup_dir="$recovery_point_dir/files/$relative_dir"
    
    if [ "$relative_dir" != "." ] && [ ! -d "$backup_dir" ]; then
        if ! mkdir -p "$backup_dir"; then
            log_error "Failed to create backup directory: $backup_dir" "RECOVERY_MANAGER"
            return 1
        fi
    fi
    
    # Copy file with metadata preservation
    local backup_path="$recovery_point_dir/files/$file_path"
    if cp -p "$file_path" "$backup_path" 2>/dev/null; then
        log_file_operation "$RECOVERY_OP_BACKUP" "$file_path" "SUCCESS" "Backed up to: $backup_path"
        return 0
    else
        log_file_operation "$RECOVERY_OP_BACKUP" "$file_path" "FAILED" "Failed to backup to: $backup_path"
        return 1
    fi
}

# Update global recovery metadata
update_global_recovery_metadata() {
    local recovery_point_id="$1"
    local operation_name="$2"
    local description="$3"
    
    local metadata_file="$RECOVERY_BASE_DIR/$RECOVERY_METADATA_FILE"
    
    # Use jq if available for proper JSON manipulation
    if command -v jq >/dev/null 2>&1; then
        local temp_file
        temp_file=$(mktemp)
        
        jq --arg id "$recovery_point_id" \
           --arg op "$operation_name" \
           --arg desc "$description" \
           --arg created "$(date -Iseconds)" \
           '.recovery_points += [{
               "id": $id,
               "operation": $op,
               "description": $desc,
               "created": $created
           }] | .active_point = $id' \
           "$metadata_file" > "$temp_file" && mv "$temp_file" "$metadata_file"
    else
        # Fallback: simple append (not proper JSON, but functional)
        log_warning "jq not available - using simplified metadata format" "RECOVERY_MANAGER"
    fi
}

# ====================================================================
# Recovery and Rollback Operations
# ====================================================================

# List available recovery points
list_recovery_points() {
    local format="${1:-table}"  # table|json|simple
    
    if [ ! -d "$RECOVERY_BASE_DIR" ]; then
        echo "No recovery points available"
        return 0
    fi
    
    local recovery_points=()
    for point_dir in "$RECOVERY_BASE_DIR"/$RECOVERY_POINT_PREFIX-*; do
        [ -d "$point_dir" ] || continue
        recovery_points+=("$(basename "$point_dir")")
    done
    
    if [ ${#recovery_points[@]} -eq 0 ]; then
        echo "No recovery points found"
        return 0
    fi
    
    case "$format" in
        "table")
            echo ""
            echo "📋 Available Recovery Points:"
            echo "════════════════════════════════════════════════════════════════"
            printf "%-40s %-15s %-20s\n" "Recovery Point ID" "Operation" "Created"
            echo "────────────────────────────────────────────────────────────────"
            
            for point_id in "${recovery_points[@]}"; do
                local metadata_file="$RECOVERY_BASE_DIR/$point_id/metadata.json"
                if [ -f "$metadata_file" ]; then
                    local operation created
                    if command -v jq >/dev/null 2>&1; then
                        operation=$(jq -r '.operation' "$metadata_file" 2>/dev/null || echo "unknown")
                        created=$(jq -r '.created' "$metadata_file" 2>/dev/null || echo "unknown")
                    else
                        operation="unknown"
                        created="unknown"
                    fi
                    printf "%-40s %-15s %-20s\n" "$point_id" "$operation" "$created"
                else
                    printf "%-40s %-15s %-20s\n" "$point_id" "unknown" "unknown"
                fi
            done
            echo ""
            ;;
        "json")
            echo "["
            local first=true
            for point_id in "${recovery_points[@]}"; do
                local metadata_file="$RECOVERY_BASE_DIR/$point_id/metadata.json"
                if [ -f "$metadata_file" ]; then
                    [ "$first" = false ] && echo ","
                    cat "$metadata_file"
                    first=false
                fi
            done
            echo "]"
            ;;
        "simple")
            for point_id in "${recovery_points[@]}"; do
                echo "$point_id"
            done
            ;;
    esac
}

# Get recovery point information
get_recovery_point_info() {
    local recovery_point_id="$1"
    local format="${2:-json}"
    
    local recovery_point_dir="$RECOVERY_BASE_DIR/$recovery_point_id"
    local metadata_file="$recovery_point_dir/metadata.json"
    
    if [ ! -f "$metadata_file" ]; then
        echo "Recovery point not found: $recovery_point_id" >&2
        return 1
    fi
    
    case "$format" in
        "json")
            cat "$metadata_file"
            ;;
        "summary")
            if command -v jq >/dev/null 2>&1; then
                local operation created files_count
                operation=$(jq -r '.operation' "$metadata_file")
                created=$(jq -r '.created' "$metadata_file")
                files_count=$(jq -r '.files_backed_up' "$metadata_file")
                
                echo "Recovery Point: $recovery_point_id"
                echo "Operation: $operation"
                echo "Created: $created"
                echo "Files backed up: $files_count"
            else
                echo "Recovery Point: $recovery_point_id"
                echo "Metadata file: $metadata_file"
            fi
            ;;
    esac
}

# Execute rollback to recovery point
execute_rollback() {
    local recovery_point_id="$1"
    local selective_files="${2:-}"  # Optional: specific files to restore
    local confirm="${3:-true}"
    
    if ! is_recovery_enabled; then
        log_error "Recovery system disabled - cannot execute rollback" "RECOVERY_MANAGER"
        return 1
    fi
    
    local recovery_point_dir="$RECOVERY_BASE_DIR/$recovery_point_id"
    
    if [ ! -d "$recovery_point_dir" ]; then
        log_error "Recovery point not found: $recovery_point_id" "RECOVERY_MANAGER"
        return 1
    fi
    
    log_operation_start "$RECOVERY_OP_RESTORE" "Rolling back to recovery point: $recovery_point_id"
    
    # Show recovery point information
    echo ""
    echo "🔄 Rollback Information:"
    get_recovery_point_info "$recovery_point_id" "summary"
    echo ""
    
    # Confirm rollback if requested
    if [ "$confirm" = "true" ]; then
        echo -n "Proceed with rollback? This will overwrite current files (y/N): "
        read -r rollback_confirm
        
        if [[ ! $rollback_confirm =~ ^[Yy]$ ]]; then
            log_info "Rollback cancelled by user" "RECOVERY_MANAGER"
            return 0
        fi
    fi
    
    # Read manifest to get list of files to restore
    local manifest_file="$recovery_point_dir/$RECOVERY_MANIFEST_FILE"
    local files_to_restore=()
    
    if [ -f "$manifest_file" ]; then
        while IFS= read -r line; do
            # Skip comments and empty lines
            [[ "$line" =~ ^#.*$ ]] || [ -z "$line" ] && continue
            files_to_restore+=("$line")
        done < "$manifest_file"
    else
        log_error "Recovery manifest not found: $manifest_file" "RECOVERY_MANAGER"
        return 1
    fi
    
    # Filter files if selective restore requested
    if [ -n "$selective_files" ]; then
        local filtered_files=()
        IFS=',' read -ra selective_array <<< "$selective_files"
        
        for file in "${files_to_restore[@]}"; do
            for selective in "${selective_array[@]}"; do
                if [[ "$file" == *"$selective"* ]]; then
                    filtered_files+=("$file")
                    break
                fi
            done
        done
        
        files_to_restore=("${filtered_files[@]}")
    fi
    
    # Execute rollback
    local restored_count=0
    local failed_count=0
    
    for file_path in "${files_to_restore[@]}"; do
        local backup_file="$recovery_point_dir/files/$file_path"
        
        if [ -f "$backup_file" ]; then
            # Create directory if needed
            local target_dir
            target_dir=$(dirname "$file_path")
            if [ "$target_dir" != "." ] && [ ! -d "$target_dir" ]; then
                mkdir -p "$target_dir"
            fi
            
            # Restore file
            if cp -p "$backup_file" "$file_path"; then
                log_file_operation "$RECOVERY_OP_RESTORE" "$file_path" "SUCCESS" "Restored from: $backup_file"
                ((restored_count++))
            else
                log_file_operation "$RECOVERY_OP_RESTORE" "$file_path" "FAILED" "Failed to restore from: $backup_file"
                ((failed_count++))
            fi
        else
            log_warning "Backup file not found: $backup_file" "RECOVERY_MANAGER"
            ((failed_count++))
        fi
    done
    
    # Report results
    if [ "$failed_count" -eq 0 ]; then
        log_operation_end "$RECOVERY_OP_RESTORE" "SUCCESS" "Rollback completed: $restored_count files restored"
        echo -e "${GREEN}✅ Rollback completed successfully: $restored_count files restored${NC}"
        return 0
    else
        log_operation_end "$RECOVERY_OP_RESTORE" "PARTIAL_SUCCESS" "Rollback completed with errors: $restored_count restored, $failed_count failed"
        echo -e "${YELLOW}⚠️  Rollback completed with errors: $restored_count restored, $failed_count failed${NC}"
        return 1
    fi
}

# ====================================================================
# Automatic Recovery
# ====================================================================

# Attempt automatic recovery based on error context
auto_recover() {
    local failed_operation="$1"
    local error_context="$2"
    local error_code="${3:-}"
    
    if ! is_recovery_enabled; then
        log_warning "Recovery system disabled - cannot attempt auto recovery" "RECOVERY_MANAGER"
        return 1
    fi
    
    log_operation_start "AUTO_RECOVERY" "Attempting automatic recovery for: $failed_operation"
    
    case "$error_context" in
        "FILE_OPERATIONS")
            auto_recover_file_operations "$failed_operation" "$error_code"
            ;;
        "VALIDATION")
            auto_recover_validation "$failed_operation" "$error_code"
            ;;
        "TEMPLATE_PROCESSING")
            auto_recover_template_processing "$failed_operation" "$error_code"
            ;;
        "MERGE_OPERATIONS")
            auto_recover_merge_operations "$failed_operation" "$error_code"
            ;;
        *)
            log_warning "No automatic recovery strategy for context: $error_context" "RECOVERY_MANAGER"
            return 1
            ;;
    esac
}

# Auto-recover file operations
auto_recover_file_operations() {
    local failed_operation="$1"
    local error_code="$2"
    
    case "$error_code" in
        "E5001") # Backup creation failed
            # Try to create backup in alternative location
            local alt_backup_dir="/tmp/wp-init-backup-$(date +%s)"
            if mkdir -p "$alt_backup_dir"; then
                log_info "Created alternative backup directory: $alt_backup_dir" "RECOVERY_MANAGER"
                return 0
            fi
            ;;
        "E5002"|"E5003") # File copy/write failed
            # Check if it's a permission issue and try to fix
            local target_file
            target_file=$(echo "$failed_operation" | sed 's/.*-> //')
            if [ -n "$target_file" ]; then
                local target_dir
                target_dir=$(dirname "$target_file")
                if [ -d "$target_dir" ] && [ ! -w "$target_dir" ]; then
                    log_info "Attempting to fix directory permissions: $target_dir" "RECOVERY_MANAGER"
                    if chmod 755 "$target_dir" 2>/dev/null; then
                        return 0
                    fi
                fi
            fi
            ;;
    esac
    
    return 1
}

# Auto-recover validation errors
auto_recover_validation() {
    local failed_operation="$1"
    local error_code="$2"
    
    case "$error_code" in
        "E1001") # WordPress structure not found
            # Try to create basic WordPress structure
            if mkdir -p wp-content/{plugins,themes,mu-plugins} 2>/dev/null; then
                log_info "Created basic WordPress structure" "RECOVERY_MANAGER"
                return 0
            fi
            ;;
        "E2001") # Component directory not found
            # Extract component info and try to create directory
            local component_info
            component_info=$(echo "$failed_operation" | grep -o '[^:]*$')
            if [ -n "$component_info" ] && mkdir -p "$WP_CONTENT_DIR/plugins/$component_info" 2>/dev/null; then
                log_info "Created component directory: $WP_CONTENT_DIR/plugins/$component_info" "RECOVERY_MANAGER"
                return 0
            fi
            ;;
    esac
    
    return 1
}

# Auto-recover template processing
auto_recover_template_processing() {
    local failed_operation="$1"
    local error_code="$2"
    
    case "$error_code" in
        "E3001") # Template file not found
            # Try to download template from repository
            local template_file
            template_file=$(echo "$failed_operation" | grep -o '[^:]*\.template$')
            if [ -n "$template_file" ]; then
                local template_url="https://raw.githubusercontent.com/tu-usuario/wp-init/main/$template_file"
                if command -v curl >/dev/null 2>&1; then
                    if curl -s -o "$template_file" "$template_url" && [ -f "$template_file" ]; then
                        log_info "Downloaded template file: $template_file" "RECOVERY_MANAGER"
                        return 0
                    fi
                fi
            fi
            ;;
    esac
    
    return 1
}

# Auto-recover merge operations
auto_recover_merge_operations() {
    local failed_operation="$1"
    local error_code="$2"
    
    case "$error_code" in
        "E5005") # JSON merge operation failed
            # Try to restore from most recent recovery point
            if [ -n "$CURRENT_RECOVERY_POINT" ]; then
                local config_file
                config_file=$(echo "$failed_operation" | grep -o '[^:]*\.json$')
                if [ -n "$config_file" ]; then
                    execute_rollback "$CURRENT_RECOVERY_POINT" "$config_file" "false"
                    return $?
                fi
            fi
            ;;
    esac
    
    return 1
}

# ====================================================================
# Recovery Point Cleanup
# ====================================================================

# Clean up old recovery points
cleanup_recovery_points() {
    local max_age_days="${1:-7}"
    local max_count="${2:-10}"
    
    if ! is_recovery_enabled; then
        log_warning "Recovery system disabled - skipping cleanup" "RECOVERY_MANAGER"
        return 0
    fi
    
    log_operation_start "$RECOVERY_OP_CLEANUP" "Cleaning up recovery points (max age: ${max_age_days}d, max count: $max_count)"
    
    local recovery_points=()
    for point_dir in "$RECOVERY_BASE_DIR"/$RECOVERY_POINT_PREFIX-*; do
        [ -d "$point_dir" ] || continue
        recovery_points+=("$(basename "$point_dir")")
    done
    
    if [ ${#recovery_points[@]} -eq 0 ]; then
        log_info "No recovery points to clean up" "RECOVERY_MANAGER"
        return 0
    fi
    
    # Sort recovery points by creation time (newest first)
    local sorted_points=()
    for point_id in "${recovery_points[@]}"; do
        local metadata_file="$RECOVERY_BASE_DIR/$point_id/metadata.json"
        local created_timestamp=""
        
        if [ -f "$metadata_file" ] && command -v jq >/dev/null 2>&1; then
            created_timestamp=$(jq -r '.created' "$metadata_file" 2>/dev/null)
        fi
        
        sorted_points+=("$created_timestamp|$point_id")
    done
    
    # Sort by timestamp (newest first)
    IFS=$'\n' sorted_points=($(sort -r <<< "${sorted_points[*]}"))
    
    local cleaned_count=0
    local current_time=$(date +%s)
    
    for i in "${!sorted_points[@]}"; do
        IFS='|' read -r timestamp point_id <<< "${sorted_points[$i]}"
        
        local should_delete=false
        
        # Check age limit
        if [ -n "$timestamp" ] && [ "$timestamp" != "null" ]; then
            local point_time
            point_time=$(date -d "$timestamp" +%s 2>/dev/null || echo "0")
            local age_days=$(( (current_time - point_time) / 86400 ))
            
            if [ "$age_days" -gt "$max_age_days" ]; then
                should_delete=true
                log_info "Recovery point $point_id is $age_days days old (exceeds $max_age_days days)" "RECOVERY_MANAGER"
            fi
        fi
        
        # Check count limit (keep newest points)
        if [ "$i" -ge "$max_count" ]; then
            should_delete=true
            log_info "Recovery point $point_id exceeds count limit (position $i, max $max_count)" "RECOVERY_MANAGER"
        fi
        
        # Delete if marked for deletion
        if [ "$should_delete" = true ]; then
            local point_dir="$RECOVERY_BASE_DIR/$point_id"
            if rm -rf "$point_dir"; then
                log_info "Cleaned up recovery point: $point_id" "RECOVERY_MANAGER"
                ((cleaned_count++))
            else
                log_warning "Failed to clean up recovery point: $point_id" "RECOVERY_MANAGER"
            fi
        fi
    done
    
    log_operation_end "$RECOVERY_OP_CLEANUP" "SUCCESS" "Cleaned up $cleaned_count recovery points"
    
    if [ "$cleaned_count" -gt 0 ]; then
        echo -e "${GREEN}✅ Cleaned up $cleaned_count old recovery points${NC}"
    else
        echo -e "${BLUE}ℹ️  No recovery points needed cleanup${NC}"
    fi
    
    return 0
}

# ====================================================================
# Recovery System Interface
# ====================================================================

# Main recovery manager interface
recovery_manager() {
    local command="$1"
    shift
    
    case "$command" in
        "init")
            init_recovery_system "$@"
            ;;
        "create")
            create_recovery_point "$@"
            ;;
        "list")
            list_recovery_points "$@"
            ;;
        "info")
            get_recovery_point_info "$@"
            ;;
        "rollback")
            execute_rollback "$@"
            ;;
        "auto-recover")
            auto_recover "$@"
            ;;
        "cleanup")
            cleanup_recovery_points "$@"
            ;;
        "enable")
            enable_recovery
            ;;
        "disable")
            disable_recovery
            ;;
        "status")
            if is_recovery_enabled; then
                echo "Recovery system: ENABLED"
                echo "Base directory: $RECOVERY_BASE_DIR"
                echo "Current recovery point: ${CURRENT_RECOVERY_POINT:-none}"
                echo "Available recovery points: $(list_recovery_points simple | wc -l)"
            else
                echo "Recovery system: DISABLED"
            fi
            ;;
        *)
            echo "Usage: recovery_manager <command> [options]"
            echo ""
            echo "Commands:"
            echo "  init [base_dir]                    Initialize recovery system"
            echo "  create <operation> [description] [files...]  Create recovery point"
            echo "  list [format]                      List recovery points (table|json|simple)"
            echo "  info <recovery_point_id> [format] Get recovery point information"
            echo "  rollback <recovery_point_id> [selective_files] [confirm]  Execute rollback"
            echo "  auto-recover <operation> <context> [error_code]  Attempt automatic recovery"
            echo "  cleanup [max_age_days] [max_count]  Clean up old recovery points"
            echo "  enable                             Enable recovery system"
            echo "  disable                            Disable recovery system"
            echo "  status                             Show recovery system status"
            return 1
            ;;
    esac
}

# ====================================================================
# Initialization
# ====================================================================

# Auto-initialize recovery system when sourced
if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
    # Set default recovery base directory
    RECOVERY_BASE_DIR="${RECOVERY_BASE_DIR:-./recovery}"
    
    log_info "Recovery manager loaded" "RECOVERY_MANAGER"
fi