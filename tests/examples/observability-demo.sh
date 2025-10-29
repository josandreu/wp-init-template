#!/bin/bash

# Observability System Demo
# Shows how to use the new logging and debugging capabilities

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source the observability system
source "$SCRIPT_DIR/../lib/observability.sh"

# Demo function that we'll observe
demo_validation_function() {
    local file_path="$1"
    local validation_type="$2"
    
    log_info "Validating file" "path=$file_path" "type=$validation_type"
    
    # Simulate some validation work
    sleep 0.1
    
    if [[ ! -f "$file_path" ]]; then
        log_error "File not found" "path=$file_path"
        return 1
    fi
    
    if [[ "$validation_type" == "syntax" ]]; then
        # Simulate syntax validation
        log_debug "Checking syntax"
        sleep 0.05
        
        if [[ "$(basename "$file_path")" == *".sh" ]]; then
            log_info "Bash syntax validation passed"
            return 0
        else
            log_warn "Unknown file type for syntax validation"
            return 2
        fi
    fi
    
    log_info "Validation completed successfully"
    return 0
}

# Demo test function
demo_test_function() {
    local test_name="$1"
    
    log_info "Running test: $test_name"
    
    # Simulate test execution
    case "$test_name" in
        "pass")
            log_debug "Test operations successful"
            return 0
            ;;
        "fail")
            log_error "Test assertion failed"
            return 1
            ;;
        "slow")
            log_debug "Running slow test operations"
            sleep 0.2
            return 0
            ;;
        *)
            log_warn "Unknown test type"
            return 2
            ;;
    esac
}

# Main demo function
run_observability_demo() {
    echo "🔍 Observability System Demo"
    echo "============================"
    
    # Setup observability with different modes
    echo ""
    echo "1. Basic Observability Setup"
    setup_basic_observability
    
    echo ""
    echo "2. Running observed functions..."
    
    # Create a temporary file for testing
    local temp_file="/tmp/demo_file.sh"
    echo "#!/bin/bash" > "$temp_file"
    echo "echo 'Hello World'" >> "$temp_file"
    
    # Demonstrate observed validation
    observe_validation "file_exists_check" demo_validation_function "$temp_file" "exists"
    observe_validation "syntax_check" demo_validation_function "$temp_file" "syntax"
    observe_validation "missing_file_check" demo_validation_function "/nonexistent/file.sh" "exists"
    
    echo ""
    echo "3. Running observed tests..."
    
    # Demonstrate observed tests
    observe_test "passing_test" demo_test_function "pass"
    observe_test "failing_test" demo_test_function "fail"
    observe_test "slow_test" demo_test_function "slow"
    
    echo ""
    echo "4. Running observed commands..."
    
    # Demonstrate observed commands
    observe_command "list_temp_directory" ls -la /tmp
    observe_command "check_disk_usage" df -h
    
    echo ""
    echo "5. Performance and debugging features..."
    
    # Switch to debug mode
    enable_debug_mode
    enable_profile_mode
    
    # Demonstrate performance tracking
    start_timer "complex_operation"
    sleep 0.1
    increment_counter "operations_completed"
    local duration=$(stop_timer "complex_operation")
    
    log_performance "complex_operation" "$duration" "counter_value=$(get_counter operations_completed)"
    
    # Demonstrate state capture
    set_debug_variable "demo_status" "running"
    set_debug_variable "temp_file" "$temp_file"
    capture_state "demo_midpoint" "Midpoint of demo execution"
    
    echo ""
    echo "6. Generating reports..."
    
    # Generate comprehensive report
    local report_file=$(generate_observability_report "demo_report")
    echo "📊 Report generated: $report_file"
    
    # Cleanup
    rm -f "$temp_file"
    cleanup_observability
    
    echo ""
    echo "✅ Demo completed! Check the observability-output directory for detailed reports."
}

# Configuration demo
demo_configuration() {
    echo ""
    echo "🔧 Configuration Demo"
    echo "===================="
    
    # Create and show default configuration
    local config_file=$(create_default_config)
    echo "📄 Default configuration created: $config_file"
    echo ""
    echo "Configuration contents:"
    cat "$config_file"
    
    echo ""
    echo "You can modify this file and load it with:"
    echo "  load_observability_config '$config_file'"
}

# Quick setup demos
demo_quick_setups() {
    echo ""
    echo "⚡ Quick Setup Demos"
    echo "==================="
    
    echo ""
    echo "Available quick setup functions:"
    echo "  setup_basic_observability      - Basic logging only"
    echo "  setup_debug_observability      - Debug mode with tracing"
    echo "  setup_performance_observability - Performance profiling"
    echo "  setup_full_observability       - All features enabled"
    
    echo ""
    echo "Example usage in your scripts:"
    cat << 'EOF'
    
    # At the start of your script:
    source "path/to/tests/lib/observability.sh"
    setup_debug_observability
    
    # Wrap your functions:
    observe_function my_function arg1 arg2
    
    # Wrap your commands:
    observe_command "Installing packages" npm install
    
    # At the end of your script:
    cleanup_observability
    
EOF
}

# Main execution
main() {
    case "${1:-demo}" in
        "demo")
            run_observability_demo
            ;;
        "config")
            demo_configuration
            ;;
        "setups")
            demo_quick_setups
            ;;
        "all")
            run_observability_demo
            demo_configuration
            demo_quick_setups
            ;;
        *)
            echo "Usage: $0 [demo|config|setups|all]"
            echo ""
            echo "  demo   - Run full observability demo"
            echo "  config - Show configuration options"
            echo "  setups - Show quick setup options"
            echo "  all    - Run all demos"
            exit 1
            ;;
    esac
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi