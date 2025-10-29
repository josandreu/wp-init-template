#!/bin/bash

# Comprehensive Logging System
# Provides structured logging with JSON output, multiple log levels, and context tracking

# Global logging configuration
LOG_LEVEL="${LOG_LEVEL:-INFO}"
LOG_FORMAT="${LOG_FORMAT:-CONSOLE}"  # CONSOLE, JSON, STRUCTURED
LOG_FILE="${LOG_FILE:-}"
LOG_CONTEXT_STACK=()
LOG_OPERATION_ID=""
LOG_SESSION_ID=""
LOG_ENABLE_COLORS="${LOG_ENABLE_COLORS:-true}"

# Log level functions (compatibility with bash 3.2)
get_log_level_num() {
    case "$1" in
        "DEBUG") echo "10" ;;
        "INFO") echo "20" ;;
        "WARN") echo "30" ;;
        "ERROR") echo "40" ;;
        "CRITICAL") echo "50" ;;
        *) echo "20" ;;
    esac
}

# Color functions (compatibility with bash 3.2)
get_log_color() {
    case "$1" in
        "DEBUG") echo "\033[0;36m" ;;      # Cyan
        "INFO") echo "\033[0;32m" ;;       # Green
        "WARN") echo "\033[0;33m" ;;       # Yellow
        "ERROR") echo "\033[0;31m" ;;      # Red
        "CRITICAL") echo "\033[1;31m" ;;   # Bold Red
        "RESET") echo "\033[0m" ;;         # Reset
        *) echo "" ;;
    esac
}

# Initialize logging system
init_logging() {
    local session_id="${1:-$(date +%s)_$$}"
    local operation_id="${2:-}"
    
    LOG_SESSION_ID="$session_id"
    LOG_OPERATION_ID="$operation_id"
    
    # Create log directory if logging to file
    if [[ -n "$LOG_FILE" ]]; then
        mkdir -p "$(dirname "$LOG_FILE")"
    fi
    
    log_debug "Logging system initialized" \
        "session_id=$LOG_SESSION_ID" \
        "operation_id=$LOG_OPERATION_ID" \
        "log_level=$LOG_LEVEL" \
        "log_format=$LOG_FORMAT"
}

# Check if log level should be output
should_log() {
    local level="$1"
    local current_level_num=$(get_log_level_num "$LOG_LEVEL")
    local message_level_num=$(get_log_level_num "$level")
    
    [[ $message_level_num -ge $current_level_num ]]
}

# Get current timestamp in ISO 8601 format
get_timestamp() {
    date -u +"%Y-%m-%dT%H:%M:%S.%3NZ" 2>/dev/null || date -u +"%Y-%m-%dT%H:%M:%SZ"
}

# Get current context as string
get_context_string() {
    local context=""
    if [[ ${#LOG_CONTEXT_STACK[@]} -gt 0 ]]; then
        context=$(IFS="."; echo "${LOG_CONTEXT_STACK[*]}")
    fi
    echo "$context"
}

# Format log message based on LOG_FORMAT
format_log_message() {
    local level="$1"
    local message="$2"
    shift 2
    local metadata=("$@")
    
    local timestamp=$(get_timestamp)
    local context=$(get_context_string)
    local pid=$$
    
    case "$LOG_FORMAT" in
        "JSON")
            format_json_log "$level" "$message" "$timestamp" "$context" "$pid" "${metadata[@]}"
            ;;
        "STRUCTURED")
            format_structured_log "$level" "$message" "$timestamp" "$context" "$pid" "${metadata[@]}"
            ;;
        *)
            format_console_log "$level" "$message" "$timestamp" "$context" "$pid" "${metadata[@]}"
            ;;
    esac
}

# Format JSON log entry
format_json_log() {
    local level="$1"
    local message="$2"
    local timestamp="$3"
    local context="$4"
    local pid="$5"
    shift 5
    local metadata=("$@")
    
    # Build metadata object
    local metadata_json="{"
    local first=true
    
    for item in "${metadata[@]}"; do
        if [[ "$item" == *"="* ]]; then
            local key="${item%%=*}"
            local value="${item#*=}"
            
            if [[ "$first" == "true" ]]; then
                first=false
            else
                metadata_json+=","
            fi
            
            metadata_json+="\"$key\":\"$value\""
        fi
    done
    metadata_json+="}"
    
    # Build complete JSON log entry
    cat << EOF
{
  "timestamp": "$timestamp",
  "level": "$level",
  "message": "$message",
  "context": "$context",
  "session_id": "$LOG_SESSION_ID",
  "operation_id": "$LOG_OPERATION_ID",
  "pid": $pid,
  "metadata": $metadata_json
}
EOF
}

# Format structured log entry (key=value pairs)
format_structured_log() {
    local level="$1"
    local message="$2"
    local timestamp="$3"
    local context="$4"
    local pid="$5"
    shift 5
    local metadata=("$@")
    
    local output="timestamp=$timestamp level=$level message=\"$message\""
    
    if [[ -n "$context" ]]; then
        output+=" context=$context"
    fi
    
    if [[ -n "$LOG_SESSION_ID" ]]; then
        output+=" session_id=$LOG_SESSION_ID"
    fi
    
    if [[ -n "$LOG_OPERATION_ID" ]]; then
        output+=" operation_id=$LOG_OPERATION_ID"
    fi
    
    output+=" pid=$pid"
    
    for item in "${metadata[@]}"; do
        if [[ "$item" == *"="* ]]; then
            output+=" $item"
        fi
    done
    
    echo "$output"
}

# Format console log entry (human-readable with colors)
format_console_log() {
    local level="$1"
    local message="$2"
    local timestamp="$3"
    local context="$4"
    local pid="$5"
    shift 5
    local metadata=("$@")
    
    local color=""
    local reset=""
    
    if [[ "$LOG_ENABLE_COLORS" == "true" ]] && [[ -t 1 ]]; then
        color=$(get_log_color "$level")
        reset=$(get_log_color "RESET")
    fi
    
    local time_short=$(echo "$timestamp" | cut -d'T' -f2 | cut -d'.' -f1)
    local output="${color}[$time_short] [$level]${reset}"
    
    if [[ -n "$context" ]]; then
        output+=" [$context]"
    fi
    
    output+=" $message"
    
    # Add metadata if present
    if [[ ${#metadata[@]} -gt 0 ]]; then
        local meta_str=""
        for item in "${metadata[@]}"; do
            if [[ -n "$meta_str" ]]; then
                meta_str+=", "
            fi
            meta_str+="$item"
        done
        output+=" ($meta_str)"
    fi
    
    echo "$output"
}

# Write log entry to output
write_log() {
    local formatted_message="$1"
    
    # Always write to stdout/stderr
    echo "$formatted_message"
    
    # Also write to file if configured
    if [[ -n "$LOG_FILE" ]]; then
        echo "$formatted_message" >> "$LOG_FILE"
    fi
}

# Core logging function
log_message() {
    local level="$1"
    local message="$2"
    shift 2
    local metadata=("$@")
    
    if ! should_log "$level"; then
        return 0
    fi
    
    local formatted_message
    formatted_message=$(format_log_message "$level" "$message" "${metadata[@]}")
    
    write_log "$formatted_message"
}

# Convenience logging functions
log_debug() {
    log_message "DEBUG" "$@"
}

log_info() {
    log_message "INFO" "$@"
}

log_warn() {
    log_message "WARN" "$@"
}

log_error() {
    log_message "ERROR" "$@"
}

log_critical() {
    log_message "CRITICAL" "$@"
}

# Context management functions
push_context() {
    local context="$1"
    LOG_CONTEXT_STACK+=("$context")
    log_debug "Entered context: $context" "stack_depth=${#LOG_CONTEXT_STACK[@]}"
}

pop_context() {
    if [[ ${#LOG_CONTEXT_STACK[@]} -gt 0 ]]; then
        local last_index=$((${#LOG_CONTEXT_STACK[@]} - 1))
        local context="${LOG_CONTEXT_STACK[$last_index]}"
        unset LOG_CONTEXT_STACK[$last_index]
        log_debug "Exited context: $context" "stack_depth=${#LOG_CONTEXT_STACK[@]}"
    fi
}

clear_context() {
    LOG_CONTEXT_STACK=()
    log_debug "Cleared all context"
}

# Operation tracking
start_operation() {
    local operation_name="$1"
    local operation_id="${2:-$(date +%s%N)}"
    
    LOG_OPERATION_ID="$operation_id"
    push_context "$operation_name"
    
    log_info "Started operation: $operation_name" \
        "operation_id=$operation_id" \
        "start_time=$(get_timestamp)"
}

end_operation() {
    local operation_name="$1"
    local status="${2:-SUCCESS}"
    
    log_info "Completed operation: $operation_name" \
        "operation_id=$LOG_OPERATION_ID" \
        "status=$status" \
        "end_time=$(get_timestamp)"
    
    pop_context
}

# Performance logging helpers
log_performance() {
    local operation="$1"
    local duration_ms="$2"
    local additional_metrics=("${@:3}")
    
    log_info "Performance metric" \
        "operation=$operation" \
        "duration_ms=$duration_ms" \
        "${additional_metrics[@]}"
}

# Error logging with stack trace
log_error_with_trace() {
    local message="$1"
    shift
    local metadata=("$@")
    
    # Get call stack
    local stack_trace=""
    local i=1
    while caller $i >/dev/null 2>&1; do
        local line_info=$(caller $i)
        local line_num=$(echo "$line_info" | cut -d' ' -f1)
        local func_name=$(echo "$line_info" | cut -d' ' -f2)
        local file_name=$(echo "$line_info" | cut -d' ' -f3)
        
        if [[ -n "$stack_trace" ]]; then
            stack_trace+="|"
        fi
        stack_trace+="${func_name}:${line_num}(${file_name})"
        
        ((i++))
    done
    
    log_error "$message" "stack_trace=$stack_trace" "${metadata[@]}"
}

# Structured event logging
log_event() {
    local event_type="$1"
    local event_name="$2"
    shift 2
    local event_data=("$@")
    
    log_info "Event: $event_name" \
        "event_type=$event_type" \
        "event_time=$(get_timestamp)" \
        "${event_data[@]}"
}

# Configuration helpers
set_log_level() {
    local level="$1"
    local level_num=$(get_log_level_num "$level")
    if [[ "$level_num" != "20" || "$level" == "INFO" ]]; then
        LOG_LEVEL="$level"
        log_info "Log level changed to: $level"
    else
        log_error "Invalid log level: $level" "valid_levels=DEBUG,INFO,WARN,ERROR,CRITICAL"
        return 1
    fi
}

set_log_format() {
    local format="$1"
    case "$format" in
        "CONSOLE"|"JSON"|"STRUCTURED")
            LOG_FORMAT="$format"
            log_info "Log format changed to: $format"
            ;;
        *)
            log_error "Invalid log format: $format" "valid_formats=CONSOLE,JSON,STRUCTURED"
            return 1
            ;;
    esac
}

set_log_file() {
    local file="$1"
    LOG_FILE="$file"
    
    if [[ -n "$file" ]]; then
        mkdir -p "$(dirname "$file")"
        log_info "Log file set to: $file"
    else
        log_info "Log file disabled"
    fi
}

# Cleanup function
cleanup_logging() {
    log_info "Shutting down logging system" \
        "session_id=$LOG_SESSION_ID" \
        "final_context=$(get_context_string)"
    
    # Clear context stack
    clear_context
    
    # Reset operation ID
    LOG_OPERATION_ID=""
}

# Export functions for use in other scripts
export -f init_logging log_debug log_info log_warn log_error log_critical
export -f push_context pop_context clear_context start_operation end_operation
export -f log_performance log_error_with_trace log_event
export -f set_log_level set_log_format set_log_file cleanup_logging