#!/bin/bash

# Observability Integration
# Combines logging and debugging systems for comprehensive observability

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source required libraries
source "$SCRIPT_DIR/logger.sh"
source "$SCRIPT_DIR/debugger.sh"

# Global observability configuration
OBSERVABILITY_ENABLED="${OBSERVABILITY_ENABLED:-true}"
OBSERVABILITY_SESSION_ID=""
OBSERVABILITY_OUTPUT_DIR="${OBSERVABILITY_OUTPUT_DIR:-./observability-output}"

# Initialize complete observability system
init_observability() {
    local session_name="${1:-$(date +%Y%m%d_%H%M%S)}"
    local config_file="${2:-}"
    
    if [[ "$OBSERVABILITY_ENABLED" != "true" ]]; then
        return 0
    fi
    
    OBSERVABILITY_SESSION_ID="$session_name"
    
    # Create output directory
    mkdir -p "$OBSERVABILITY_OUTPUT_DIR"
    
    # Load configuration if provided
    if [[ -n "$config_file" && -f "$config_file" ]]; then
        load_observability_config "$config_file"
    fi
    
    # Initialize logging system
    init_logging "$session_name" "observability"
    
    # Initialize debugging system
    DEBUG_OUTPUT_DIR="$OBSERVABILITY_OUTPUT_DIR"
    init_debugging "$session_name"
    
    log_info "Observability system initialized" \
        "session_id=$OBSERVABILITY_SESSION_ID" \
        "output_dir=$OBSERVABILITY_OUTPUT_DIR"
}

# Load configuration from file
load_observability_config() {
    local config_file="$1"
    
    if [[ ! -f "$config_file" ]]; then
        log_error "Configuration file not found: $config_file"
        return 1
    fi
    
    log_info "Loading observability configuration" "file=$config_file"
    
    # Source the config file safely
    while IFS='=' read -r key value; do
        # Skip comments and empty lines
        [[ "$key" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$key" ]] && continue
        
        # Remove quotes from value
        value=$(echo "$value" | sed 's/^["'\'']//' | sed 's/["'\'']$//')
        
        case "$key" in
            "LOG_LEVEL")
                set_log_level "$value"
                ;;
            "LOG_FORMAT")
                set_log_format "$value"
                ;;
            "LOG_FILE")
                set_log_file "$value"
                ;;
            "DEBUG_MODE")
                if [[ "$value" == "true" ]]; then
                    enable_debug_mode
                fi
                ;;
            "TRACE_MODE")
                if [[ "$value" == "true" ]]; then
                    enable_trace_mode
                fi
                ;;
            "PROFILE_MODE")
                if [[ "$value" == "true" ]]; then
                    enable_profile_mode
                fi
                ;;
            "LOG_ENABLE_COLORS")
                LOG_ENABLE_COLORS="$value"
                ;;
        esac
    done < "$config_file"
}

# Create default configuration file
create_default_config() {
    local config_file="${1:-$OBSERVABILITY_OUTPUT_DIR/observability.conf}"
    
    # Ensure we have a valid output directory
    if [[ -z "$OBSERVABILITY_OUTPUT_DIR" ]]; then
        OBSERVABILITY_OUTPUT_DIR="./observability-output"
    fi
    
    mkdir -p "$(dirname "$config_file")"
    
    cat > "$config_file" << 'EOF'
# Observability Configuration
# This file configures logging and debugging behavior

# Logging Configuration
LOG_LEVEL=INFO
LOG_FORMAT=CONSOLE
LOG_FILE=
LOG_ENABLE_COLORS=true

# Debugging Configuration
DEBUG_MODE=false
TRACE_MODE=false
PROFILE_MODE=false

# Output Configuration
OBSERVABILITY_OUTPUT_DIR=./observability-output
EOF
    
    # Only log if logging is initialized
    if [[ -n "$LOG_SESSION_ID" ]]; then
        log_info "Default configuration created" "file=$config_file"
    fi
    printf "%s" "$config_file"
}

# Observability wrapper for functions
observe_function() {
    local function_name="$1"
    shift
    local args=("$@")
    
    # Start observing
    push_context "$function_name"
    trace_function_entry "$function_name" "${args[@]}"
    start_timer "function:$function_name"
    track_memory_usage "before:$function_name"
    
    # Execute function
    local exit_code=0
    "$function_name" "${args[@]}" || exit_code=$?
    
    # Stop observing
    local duration=$(stop_timer "function:$function_name")
    track_memory_usage "after:$function_name"
    trace_function_exit "$function_name" "$exit_code"
    pop_context
    
    if [[ $exit_code -ne 0 ]]; then
        log_error "Function failed: $function_name" \
            "exit_code=$exit_code" \
            "duration_ms=$duration" \
            "args=${args[*]}"
    else
        log_debug "Function completed: $function_name" \
            "duration_ms=$duration" \
            "args=${args[*]}"
    fi
    
    return $exit_code
}

# Observability wrapper for commands
observe_command() {
    local description="$1"
    shift
    local command=("$@")
    
    log_info "Executing command: $description"
    
    push_context "command"
    start_timer "command:$description"
    
    # Execute with full observability
    verbose_execute "$description" "${command[@]}"
    local exit_code=$?
    
    local duration=$(stop_timer "command:$description")
    pop_context
    
    if [[ $exit_code -eq 0 ]]; then
        log_info "Command completed successfully: $description" "duration_ms=$duration"
    else
        log_error "Command failed: $description" \
            "exit_code=$exit_code" \
            "duration_ms=$duration" \
            "command=${command[*]}"
    fi
    
    return $exit_code
}

# Test execution with full observability
observe_test() {
    local test_name="$1"
    local test_function="$2"
    shift 2
    local test_args=("$@")
    
    log_info "Starting test: $test_name"
    
    push_context "test:$test_name"
    start_timer "test:$test_name"
    capture_state "test_start_$test_name" "Before test: $test_name"
    
    # Execute test
    local exit_code=0
    "$test_function" "${test_args[@]}" || exit_code=$?
    
    local duration=$(stop_timer "test:$test_name")
    
    if [[ $exit_code -eq 0 ]]; then
        log_info "Test passed: $test_name" "duration_ms=$duration"
        increment_counter "tests_passed"
    else
        log_error "Test failed: $test_name" \
            "exit_code=$exit_code" \
            "duration_ms=$duration"
        capture_state "test_failure_$test_name" "After test failure: $test_name"
        increment_counter "tests_failed"
    fi
    
    increment_counter "tests_total"
    pop_context
    
    return $exit_code
}

# Validation with observability
observe_validation() {
    local validation_name="$1"
    local validation_function="$2"
    shift 2
    local validation_args=("$@")
    
    log_info "Running validation: $validation_name"
    
    push_context "validation:$validation_name"
    start_timer "validation:$validation_name"
    
    # Execute validation
    local exit_code=0
    "$validation_function" "${validation_args[@]}" || exit_code=$?
    
    local duration=$(stop_timer "validation:$validation_name")
    
    case $exit_code in
        0)
            log_info "Validation passed: $validation_name" "duration_ms=$duration"
            increment_counter "validations_passed"
            ;;
        1)
            log_error "Validation failed (critical): $validation_name" \
                "duration_ms=$duration"
            increment_counter "validations_critical"
            ;;
        2)
            log_warn "Validation failed (warning): $validation_name" \
                "duration_ms=$duration"
            increment_counter "validations_warning"
            ;;
        *)
            log_error "Validation error: $validation_name" \
                "exit_code=$exit_code" \
                "duration_ms=$duration"
            increment_counter "validations_error"
            ;;
    esac
    
    increment_counter "validations_total"
    pop_context
    
    return $exit_code
}

# Generate comprehensive observability report
generate_observability_report() {
    local report_name="${1:-observability_report_$(date +%Y%m%d_%H%M%S)}"
    local report_file="$OBSERVABILITY_OUTPUT_DIR/${report_name}.html"
    
    log_info "Generating comprehensive observability report" "file=$report_file"
    
    {
        cat << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Observability Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background-color: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .header { text-align: center; margin-bottom: 30px; padding-bottom: 20px; border-bottom: 2px solid #eee; }
        .section { margin: 20px 0; padding: 15px; border: 1px solid #ddd; border-radius: 5px; }
        .metrics-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px; margin: 20px 0; }
        .metric-card { background: #f8f9fa; padding: 15px; border-radius: 5px; text-align: center; }
        .metric-value { font-size: 24px; font-weight: bold; color: #007bff; }
        .metric-label { font-size: 14px; color: #666; margin-top: 5px; }
        .trace-entry { font-family: monospace; font-size: 12px; padding: 2px 0; }
        .log-entry { font-family: monospace; font-size: 12px; padding: 2px 0; border-left: 3px solid #ddd; padding-left: 10px; margin: 2px 0; }
        .error { color: #dc3545; border-left-color: #dc3545; }
        .warning { color: #ffc107; border-left-color: #ffc107; }
        .info { color: #17a2b8; border-left-color: #17a2b8; }
        .debug { color: #6c757d; border-left-color: #6c757d; }
        .success { color: #28a745; border-left-color: #28a745; }
        table { border-collapse: collapse; width: 100%; margin: 10px 0; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; font-weight: bold; }
        .chart-container { margin: 20px 0; }
        .progress-bar { width: 100%; height: 20px; background-color: #e9ecef; border-radius: 10px; overflow: hidden; }
        .progress-fill { height: 100%; background-color: #28a745; transition: width 0.3s ease; }
    </style>
</head>
<body>
<div class="container">
EOF
        
        echo "<div class='header'>"
        echo "<h1>🔍 Observability Report</h1>"
        echo "<h2>$report_name</h2>"
        echo "<p>Generated: $(date)</p>"
        echo "<p>Session ID: $OBSERVABILITY_SESSION_ID</p>"
        echo "</div>"
        
        # Executive Summary
        echo "<div class='section'>"
        echo "<h2>📊 Executive Summary</h2>"
        echo "<div class='metrics-grid'>"
        
        # Calculate summary metrics
        local total_tests=$(get_counter "tests_total")
        local passed_tests=$(get_counter "tests_passed")
        local failed_tests=$(get_counter "tests_failed")
        local total_validations=$(get_counter "validations_total")
        local passed_validations=$(get_counter "validations_passed")
        
        echo "<div class='metric-card'>"
        echo "<div class='metric-value'>$total_tests</div>"
        echo "<div class='metric-label'>Total Tests</div>"
        echo "</div>"
        
        echo "<div class='metric-card'>"
        echo "<div class='metric-value'>$passed_tests</div>"
        echo "<div class='metric-label'>Tests Passed</div>"
        echo "</div>"
        
        echo "<div class='metric-card'>"
        echo "<div class='metric-value'>$failed_tests</div>"
        echo "<div class='metric-label'>Tests Failed</div>"
        echo "</div>"
        
        echo "<div class='metric-card'>"
        echo "<div class='metric-value'>$total_validations</div>"
        echo "<div class='metric-label'>Total Validations</div>"
        echo "</div>"
        
        # Success rate
        if [[ $total_tests -gt 0 ]]; then
            local success_rate=$(( (passed_tests * 100) / total_tests ))
            echo "<div class='metric-card'>"
            echo "<div class='metric-value'>${success_rate}%</div>"
            echo "<div class='metric-label'>Success Rate</div>"
            echo "</div>"
        fi
        
        echo "</div>"
        echo "</div>"
        
        # Include debug report content
        if [[ -f "$DEBUG_OUTPUT_DIR/debug_report_"*".html" ]]; then
            local debug_report=$(ls -t "$DEBUG_OUTPUT_DIR"/debug_report_*.html 2>/dev/null | head -1)
            if [[ -n "$debug_report" ]]; then
                # Extract content from debug report (skip HTML wrapper)
                sed -n '/<body>/,/<\/body>/p' "$debug_report" | sed '1d;$d' 2>/dev/null || true
            fi
        fi
        
        # Configuration summary
        echo "<div class='section'>"
        echo "<h2>⚙️ Configuration</h2>"
        echo "<table>"
        echo "<tr><th>Setting</th><th>Value</th></tr>"
        echo "<tr><td>Log Level</td><td>$LOG_LEVEL</td></tr>"
        echo "<tr><td>Log Format</td><td>$LOG_FORMAT</td></tr>"
        echo "<tr><td>Debug Mode</td><td>$DEBUG_MODE</td></tr>"
        echo "<tr><td>Trace Mode</td><td>$TRACE_MODE</td></tr>"
        echo "<tr><td>Profile Mode</td><td>$PROFILE_MODE</td></tr>"
        echo "<tr><td>Output Directory</td><td>$OBSERVABILITY_OUTPUT_DIR</td></tr>"
        echo "</table>"
        echo "</div>"
        
        echo "</div>"
        echo "</body></html>"
        
    } > "$report_file"
    
    log_info "Comprehensive observability report generated" "file=$report_file"
    printf "%s" "$report_file"
}

# Quick setup functions for common scenarios
setup_basic_observability() {
    LOG_LEVEL="INFO"
    LOG_FORMAT="CONSOLE"
    init_observability "basic_$(date +%Y%m%d_%H%M%S)"
}

setup_debug_observability() {
    LOG_LEVEL="DEBUG"
    LOG_FORMAT="STRUCTURED"
    enable_debug_mode
    enable_trace_mode
    init_observability "debug_$(date +%Y%m%d_%H%M%S)"
}

setup_performance_observability() {
    LOG_LEVEL="INFO"
    LOG_FORMAT="JSON"
    enable_profile_mode
    init_observability "performance_$(date +%Y%m%d_%H%M%S)"
}

setup_full_observability() {
    LOG_LEVEL="DEBUG"
    LOG_FORMAT="JSON"
    enable_debug_mode
    enable_trace_mode
    enable_profile_mode
    init_observability "full_$(date +%Y%m%d_%H%M%S)"
}

# Cleanup complete observability system
cleanup_observability() {
    log_info "Shutting down observability system"
    
    # Generate final comprehensive report
    generate_observability_report "final_$(date +%Y%m%d_%H%M%S)"
    
    # Cleanup individual systems
    cleanup_debugging
    cleanup_logging
    
    log_info "Observability system shutdown complete"
}

# Export main functions
export -f init_observability load_observability_config create_default_config
export -f observe_function observe_command observe_test observe_validation
export -f generate_observability_report cleanup_observability
export -f setup_basic_observability setup_debug_observability
export -f setup_performance_observability setup_full_observability