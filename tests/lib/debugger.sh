#!/bin/bash

# Debugging Utilities
# Provides verbose mode, execution tracing, state inspection, and performance profiling

# Source the logger if not already loaded
if ! declare -F log_debug >/dev/null 2>&1; then
    source "$(dirname "${BASH_SOURCE[0]}")/logger.sh"
fi

# Global debugging configuration
DEBUG_MODE="${DEBUG_MODE:-false}"
TRACE_MODE="${TRACE_MODE:-false}"
PROFILE_MODE="${PROFILE_MODE:-false}"
DEBUG_OUTPUT_DIR="${DEBUG_OUTPUT_DIR:-./debug-output}"
TRACE_FILE=""
PROFILE_FILE=""

# Performance tracking (using simple variables for bash 3.2 compatibility)
PERFORMANCE_COUNTERS=""
PERFORMANCE_TIMERS=""
PERFORMANCE_START_TIME=""

# State tracking
DEBUG_STATE=""
DEBUG_CALL_STACK=()
DEBUG_VARIABLES=()

# Initialize debugging system
init_debugging() {
    local debug_session="${1:-$(date +%Y%m%d_%H%M%S)}"
    
    # Create debug output directory
    mkdir -p "$DEBUG_OUTPUT_DIR"
    
    # Set up trace file if tracing enabled
    if [[ "$TRACE_MODE" == "true" ]]; then
        TRACE_FILE="$DEBUG_OUTPUT_DIR/trace_${debug_session}.log"
        log_info "Execution tracing enabled" "trace_file=$TRACE_FILE"
    fi
    
    # Set up profile file if profiling enabled
    if [[ "$PROFILE_MODE" == "true" ]]; then
        PROFILE_FILE="$DEBUG_OUTPUT_DIR/profile_${debug_session}.log"
        PERFORMANCE_START_TIME=$(date +%s%N)
        log_info "Performance profiling enabled" "profile_file=$PROFILE_FILE"
    fi
    
    log_debug "Debugging system initialized" \
        "debug_mode=$DEBUG_MODE" \
        "trace_mode=$TRACE_MODE" \
        "profile_mode=$PROFILE_MODE" \
        "output_dir=$DEBUG_OUTPUT_DIR"
}

# Enable/disable debugging modes
enable_debug_mode() {
    DEBUG_MODE="true"
    set_log_level "DEBUG"
    log_info "Debug mode enabled"
}

disable_debug_mode() {
    DEBUG_MODE="false"
    log_info "Debug mode disabled"
}

enable_trace_mode() {
    TRACE_MODE="true"
    enable_debug_mode
    
    if [[ -z "$TRACE_FILE" ]]; then
        TRACE_FILE="$DEBUG_OUTPUT_DIR/trace_$(date +%Y%m%d_%H%M%S).log"
    fi
    
    log_info "Execution tracing enabled" "trace_file=$TRACE_FILE"
}

disable_trace_mode() {
    TRACE_MODE="false"
    log_info "Execution tracing disabled"
}

enable_profile_mode() {
    PROFILE_MODE="true"
    enable_debug_mode
    
    if [[ -z "$PROFILE_FILE" ]]; then
        PROFILE_FILE="$DEBUG_OUTPUT_DIR/profile_$(date +%Y%m%d_%H%M%S).log"
    fi
    
    if [[ -z "$PERFORMANCE_START_TIME" ]]; then
        PERFORMANCE_START_TIME=$(date +%s%N)
    fi
    
    log_info "Performance profiling enabled" "profile_file=$PROFILE_FILE"
}

disable_profile_mode() {
    PROFILE_MODE="false"
    log_info "Performance profiling disabled"
}

# Execution tracing functions
trace_function_entry() {
    local function_name="$1"
    local args=("${@:2}")
    
    if [[ "$TRACE_MODE" != "true" ]]; then
        return 0
    fi
    
    local timestamp=$(date +%s%N)
    local trace_entry="ENTER|$timestamp|$function_name|${args[*]}"
    
    DEBUG_CALL_STACK+=("$function_name")
    
    echo "$trace_entry" >> "$TRACE_FILE"
    log_debug "→ Entering function: $function_name" "args=${args[*]}" "stack_depth=${#DEBUG_CALL_STACK[@]}"
}

trace_function_exit() {
    local function_name="$1"
    local return_code="${2:-$?}"
    
    if [[ "$TRACE_MODE" != "true" ]]; then
        return 0
    fi
    
    local timestamp=$(date +%s%N)
    local trace_entry="EXIT|$timestamp|$function_name|$return_code"
    
    # Remove from call stack
    if [[ ${#DEBUG_CALL_STACK[@]} -gt 0 ]]; then
        local last_index=$((${#DEBUG_CALL_STACK[@]} - 1))
        unset DEBUG_CALL_STACK[$last_index]
    fi
    
    echo "$trace_entry" >> "$TRACE_FILE"
    log_debug "← Exiting function: $function_name" "return_code=$return_code" "stack_depth=${#DEBUG_CALL_STACK[@]}"
}

trace_command() {
    local command="$1"
    shift
    local args=("$@")
    
    if [[ "$TRACE_MODE" == "true" ]]; then
        local timestamp=$(date +%s%N)
        local trace_entry="COMMAND|$timestamp|$command|${args[*]}"
        echo "$trace_entry" >> "$TRACE_FILE"
        log_debug "Executing command: $command" "args=${args[*]}"
    fi
    
    # Execute the command and capture timing if profiling
    if [[ "$PROFILE_MODE" == "true" ]]; then
        local start_time=$(date +%s%N)
        "$command" "${args[@]}"
        local exit_code=$?
        local end_time=$(date +%s%N)
        local duration=$((end_time - start_time))
        
        profile_command "$command" "$duration" "$exit_code"
        return $exit_code
    else
        "$command" "${args[@]}"
    fi
}

# State inspection functions
capture_state() {
    local state_name="$1"
    local description="${2:-State capture}"
    
    if [[ "$DEBUG_MODE" != "true" ]]; then
        return 0
    fi
    
    local timestamp=$(date +%s%N)
    local state_file="$DEBUG_OUTPUT_DIR/state_${state_name}_${timestamp}.txt"
    
    {
        echo "=== State Capture: $state_name ==="
        echo "Timestamp: $(date)"
        echo "Description: $description"
        echo ""
        
        echo "=== Environment Variables ==="
        env | sort
        echo ""
        
        echo "=== Current Directory ==="
        pwd
        echo ""
        
        echo "=== Directory Contents ==="
        ls -la 2>/dev/null || echo "Cannot list directory"
        echo ""
        
        echo "=== Process Information ==="
        echo "PID: $$"
        echo "PPID: $PPID"
        echo "User: $(whoami 2>/dev/null || echo 'unknown')"
        echo ""
        
        echo "=== Call Stack ==="
        printf '%s\n' "${DEBUG_CALL_STACK[@]}"
        echo ""
        
        echo "=== Debug Variables ==="
        for var in "${DEBUG_VARIABLES[@]}"; do
            if [[ -n "${!var:-}" ]]; then
                echo "$var=${!var}"
            fi
        done
        echo ""
        
        echo "=== Custom State ==="
        if [[ -n "$DEBUG_STATE" ]]; then
            echo "$DEBUG_STATE" | grep -v '^$'
        fi
        
    } > "$state_file"
    
    log_debug "State captured" "state_name=$state_name" "file=$state_file"
}

set_debug_variable() {
    local var_name="$1"
    local var_value="$2"
    
    _set_debug_var "$var_name" "$var_value"
    
    if [[ "$DEBUG_MODE" == "true" ]]; then
        log_debug "Debug variable set" "name=$var_name" "value=$var_value"
    fi
}

get_debug_variable() {
    local var_name="$1"
    _get_debug_var "$var_name"
}

track_variable() {
    local var_name="$1"
    
    if [[ ! " ${DEBUG_VARIABLES[*]} " =~ " $var_name " ]]; then
        DEBUG_VARIABLES+=("$var_name")
        log_debug "Now tracking variable: $var_name"
    fi
}

# Performance profiling functions
# Helper functions for performance tracking (bash 3.2 compatible)
_set_timer() {
    local name="$1"
    local value="$2"
    PERFORMANCE_TIMERS=$(echo "$PERFORMANCE_TIMERS" | grep -v "^$name=" 2>/dev/null || true)
    PERFORMANCE_TIMERS="$PERFORMANCE_TIMERS
$name=$value"
}

_get_timer() {
    local name="$1"
    echo "$PERFORMANCE_TIMERS" | grep "^$name=" | cut -d'=' -f2 2>/dev/null || echo ""
}

_remove_timer() {
    local name="$1"
    PERFORMANCE_TIMERS=$(echo "$PERFORMANCE_TIMERS" | grep -v "^$name=" 2>/dev/null || true)
}

_set_counter() {
    local name="$1"
    local value="$2"
    PERFORMANCE_COUNTERS=$(echo "$PERFORMANCE_COUNTERS" | grep -v "^$name=" 2>/dev/null || true)
    PERFORMANCE_COUNTERS="$PERFORMANCE_COUNTERS
$name=$value"
}

_get_counter() {
    local name="$1"
    echo "$PERFORMANCE_COUNTERS" | grep "^$name=" | cut -d'=' -f2 2>/dev/null || echo "0"
}

_set_debug_var() {
    local name="$1"
    local value="$2"
    DEBUG_STATE=$(echo "$DEBUG_STATE" | grep -v "^$name=" 2>/dev/null || true)
    DEBUG_STATE="$DEBUG_STATE
$name=$value"
}

_get_debug_var() {
    local name="$1"
    echo "$DEBUG_STATE" | grep "^$name=" | cut -d'=' -f2 2>/dev/null || echo ""
}

start_timer() {
    local timer_name="$1"
    _set_timer "$timer_name" "$(date +%s%N)"
    
    if [[ "$PROFILE_MODE" == "true" ]]; then
        log_debug "Timer started: $timer_name"
    fi
}

stop_timer() {
    local timer_name="$1"
    local start_time=$(_get_timer "$timer_name")
    
    if [[ -z "$start_time" ]]; then
        log_error "Timer not found: $timer_name"
        return 1
    fi
    
    local end_time=$(date +%s%N)
    local duration=$((end_time - start_time))
    local duration_ms=$((duration / 1000000))
    
    _remove_timer "$timer_name"
    
    if [[ "$PROFILE_MODE" == "true" ]]; then
        profile_operation "$timer_name" "$duration_ms"
        log_debug "Timer stopped: $timer_name" "duration_ms=$duration_ms"
    fi
    
    echo "$duration_ms"
}

increment_counter() {
    local counter_name="$1"
    local increment="${2:-1}"
    
    local current_value=$(_get_counter "$counter_name")
    local new_value=$((current_value + increment))
    _set_counter "$counter_name" "$new_value"
    
    if [[ "$PROFILE_MODE" == "true" ]]; then
        log_debug "Counter incremented: $counter_name" "value=$new_value"
    fi
}

get_counter() {
    local counter_name="$1"
    _get_counter "$counter_name"
}

profile_operation() {
    local operation_name="$1"
    local duration_ms="$2"
    local additional_data=("${@:3}")
    
    if [[ "$PROFILE_MODE" != "true" ]]; then
        return 0
    fi
    
    local timestamp=$(date +%s%N)
    local profile_entry="OPERATION|$timestamp|$operation_name|$duration_ms"
    
    for data in "${additional_data[@]}"; do
        profile_entry+="|$data"
    done
    
    echo "$profile_entry" >> "$PROFILE_FILE"
    log_performance "$operation_name" "$duration_ms" "${additional_data[@]}"
}

profile_command() {
    local command="$1"
    local duration_ns="$2"
    local exit_code="$3"
    
    if [[ "$PROFILE_MODE" != "true" ]]; then
        return 0
    fi
    
    local duration_ms=$((duration_ns / 1000000))
    local timestamp=$(date +%s%N)
    local profile_entry="COMMAND|$timestamp|$command|$duration_ms|$exit_code"
    
    echo "$profile_entry" >> "$PROFILE_FILE"
    log_performance "command:$command" "$duration_ms" "exit_code=$exit_code"
}

# Memory usage tracking
track_memory_usage() {
    local operation_name="$1"
    
    if [[ "$PROFILE_MODE" != "true" ]]; then
        return 0
    fi
    
    # Get memory usage (works on Linux and macOS)
    local memory_kb=""
    if command -v ps >/dev/null 2>&1; then
        memory_kb=$(ps -o rss= -p $$ 2>/dev/null | tr -d ' ')
    fi
    
    if [[ -n "$memory_kb" ]]; then
        local memory_mb=$((memory_kb / 1024))
        profile_operation "memory:$operation_name" "0" "memory_mb=$memory_mb"
        log_debug "Memory usage tracked" "operation=$operation_name" "memory_mb=${memory_mb}MB"
    fi
}

# Verbose execution wrapper
verbose_execute() {
    local description="$1"
    shift
    local command=("$@")
    
    if [[ "$DEBUG_MODE" == "true" ]]; then
        log_info "Executing: $description"
        log_debug "Command: ${command[*]}"
        
        capture_state "before_$(echo "$description" | tr ' ' '_')" "Before: $description"
    fi
    
    local start_time=""
    if [[ "$PROFILE_MODE" == "true" ]]; then
        start_time=$(date +%s%N)
    fi
    
    # Execute command with tracing
    trace_command "${command[@]}"
    local exit_code=$?
    
    if [[ "$PROFILE_MODE" == "true" && -n "$start_time" ]]; then
        local end_time=$(date +%s%N)
        local duration=$((end_time - start_time))
        profile_operation "execute:$description" "$((duration / 1000000))" "exit_code=$exit_code"
    fi
    
    if [[ "$DEBUG_MODE" == "true" ]]; then
        if [[ $exit_code -eq 0 ]]; then
            log_info "Completed successfully: $description"
        else
            log_error "Failed: $description" "exit_code=$exit_code"
            capture_state "after_error_$(echo "$description" | tr ' ' '_')" "After error: $description"
        fi
    fi
    
    return $exit_code
}

# Debug breakpoint function
debug_breakpoint() {
    local message="${1:-Debug breakpoint reached}"
    
    if [[ "$DEBUG_MODE" != "true" ]]; then
        return 0
    fi
    
    log_warn "BREAKPOINT: $message"
    capture_state "breakpoint_$(date +%s)" "$message"
    
    # If interactive, allow user to inspect
    if [[ -t 0 && -t 1 ]]; then
        echo "Debug breakpoint: $message"
        echo "Current context: $(get_context_string)"
        echo "Call stack: ${DEBUG_CALL_STACK[*]}"
        echo "Press Enter to continue, 'q' to quit, 's' to capture state..."
        
        while true; do
            read -r response
            case "$response" in
                "q"|"quit")
                    log_info "Debug session terminated by user"
                    exit 1
                    ;;
                "s"|"state")
                    capture_state "manual_$(date +%s)" "Manual state capture"
                    echo "State captured. Press Enter to continue..."
                    ;;
                *)
                    break
                    ;;
            esac
        done
    fi
}

# Generate debug report
generate_debug_report() {
    local report_name="${1:-debug_report_$(date +%Y%m%d_%H%M%S)}"
    local report_file="$DEBUG_OUTPUT_DIR/${report_name}.html"
    
    log_info "Generating debug report" "file=$report_file"
    
    {
        cat << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Debug Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .section { margin: 20px 0; padding: 15px; border: 1px solid #ddd; }
        .trace-entry { font-family: monospace; font-size: 12px; }
        .error { color: red; }
        .warning { color: orange; }
        .info { color: blue; }
        .debug { color: gray; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
EOF
        
        echo "<h1>Debug Report: $report_name</h1>"
        echo "<p>Generated: $(date)</p>"
        
        # Performance summary
        if [[ "$PROFILE_MODE" == "true" && -f "$PROFILE_FILE" ]]; then
            echo "<div class='section'>"
            echo "<h2>Performance Summary</h2>"
            echo "<table>"
            echo "<tr><th>Operation</th><th>Duration (ms)</th><th>Details</th></tr>"
            
            while IFS='|' read -r type timestamp operation duration details; do
                if [[ "$type" == "OPERATION" ]]; then
                    echo "<tr><td>$operation</td><td>$duration</td><td>$details</td></tr>"
                fi
            done < "$PROFILE_FILE"
            
            echo "</table>"
            echo "</div>"
        fi
        
        # Execution trace
        if [[ "$TRACE_MODE" == "true" && -f "$TRACE_FILE" ]]; then
            echo "<div class='section'>"
            echo "<h2>Execution Trace</h2>"
            echo "<pre>"
            
            while IFS='|' read -r type timestamp operation details; do
                local time_readable=$(date -d @$((timestamp / 1000000000)) 2>/dev/null || echo "$timestamp")
                echo "<div class='trace-entry'>[$time_readable] $type: $operation $details</div>"
            done < "$TRACE_FILE"
            
            echo "</pre>"
            echo "</div>"
        fi
        
        # Performance counters
        if [[ -n "$PERFORMANCE_COUNTERS" ]]; then
            echo "<div class='section'>"
            echo "<h2>Performance Counters</h2>"
            echo "<table>"
            echo "<tr><th>Counter</th><th>Value</th></tr>"
            
            echo "$PERFORMANCE_COUNTERS" | grep -v '^$' | while IFS='=' read -r counter value; do
                echo "<tr><td>$counter</td><td>$value</td></tr>"
            done
            
            echo "</table>"
            echo "</div>"
        fi
        
        # Debug state
        if [[ -n "$DEBUG_STATE" ]]; then
            echo "<div class='section'>"
            echo "<h2>Debug State</h2>"
            echo "<table>"
            echo "<tr><th>Variable</th><th>Value</th></tr>"
            
            echo "$DEBUG_STATE" | grep -v '^$' | while IFS='=' read -r var value; do
                echo "<tr><td>$var</td><td>$value</td></tr>"
            done
            
            echo "</table>"
            echo "</div>"
        fi
        
        echo "</body></html>"
        
    } > "$report_file"
    
    log_info "Debug report generated" "file=$report_file"
    printf "%s" "$report_file"
}

# Cleanup debugging system
cleanup_debugging() {
    log_info "Cleaning up debugging system"
    
    # Generate final report if profiling was enabled
    if [[ "$PROFILE_MODE" == "true" ]]; then
        generate_debug_report "final_report_$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Clear variables
    PERFORMANCE_COUNTERS=""
    PERFORMANCE_TIMERS=""
    DEBUG_STATE=""
    DEBUG_CALL_STACK=()
    DEBUG_VARIABLES=()
    
    log_debug "Debugging system cleanup completed"
}

# Export functions for use in other scripts
export -f init_debugging enable_debug_mode disable_debug_mode
export -f enable_trace_mode disable_trace_mode enable_profile_mode disable_profile_mode
export -f trace_function_entry trace_function_exit trace_command
export -f capture_state set_debug_variable get_debug_variable track_variable
export -f start_timer stop_timer increment_counter get_counter
export -f profile_operation track_memory_usage verbose_execute
export -f debug_breakpoint generate_debug_report cleanup_debugging