#!/bin/bash

# Test observability integration with existing test infrastructure
# This test verifies that the new logging and debugging systems work correctly
# @tag observability
# @tag integration

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source required libraries
source "$SCRIPT_DIR/../lib/observability.sh"

# Test configuration
TEST_NAME="observability_integration"
TEMP_DIR="/tmp/test_observability_$$"

# Setup test environment
setup_observability_test() {
    mkdir -p "$TEMP_DIR"
    
    # Initialize observability with test configuration
    OBSERVABILITY_OUTPUT_DIR="$TEMP_DIR/observability"
    setup_basic_observability
    
    log_info "Test environment setup completed" "temp_dir=$TEMP_DIR"
}

# Cleanup test environment
cleanup_observability_test() {
    if [[ -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
    fi
    
    cleanup_observability
}

# Test basic logging functionality
test_basic_logging() {
    local test_name="basic_logging"
    
    log_info "Testing basic logging functionality"
    
    # Test different log levels
    log_debug "Debug message for testing"
    log_info "Info message for testing"
    log_warn "Warning message for testing"
    log_error "Error message for testing"
    
    # Test with metadata
    log_info "Message with metadata" "key1=value1" "key2=value2"
    
    return 0
}

# Test context management
test_context_management() {
    local test_name="context_management"
    
    log_info "Testing context management"
    
    # Test context stack
    push_context "test_context"
    log_info "Inside test context"
    
    push_context "nested_context"
    log_info "Inside nested context"
    
    pop_context
    log_info "Back to test context"
    
    pop_context
    log_info "Back to root context"
    
    return 0
}

# Test performance tracking
test_performance_tracking() {
    local test_name="performance_tracking"
    
    log_info "Testing performance tracking"
    
    # Test timers
    start_timer "test_operation"
    sleep 0.1
    local duration=$(stop_timer "test_operation")
    
    if [[ $duration -gt 50 ]]; then
        log_info "Timer test passed" "duration_ms=$duration"
    else
        log_error "Timer test failed" "duration_ms=$duration"
        return 1
    fi
    
    # Test counters
    increment_counter "test_counter" 5
    increment_counter "test_counter" 3
    local counter_value=$(get_counter "test_counter")
    
    if [[ $counter_value -eq 8 ]]; then
        log_info "Counter test passed" "value=$counter_value"
    else
        log_error "Counter test failed" "expected=8" "actual=$counter_value"
        return 1
    fi
    
    return 0
}

# Test debug variables
test_debug_variables() {
    local test_name="debug_variables"
    
    log_info "Testing debug variables"
    
    # Set debug variables
    set_debug_variable "test_var1" "test_value1"
    set_debug_variable "test_var2" "test_value2"
    
    # Get debug variables
    local value1=$(get_debug_variable "test_var1")
    local value2=$(get_debug_variable "test_var2")
    
    if [[ "$value1" == "test_value1" && "$value2" == "test_value2" ]]; then
        log_info "Debug variables test passed"
        return 0
    else
        log_error "Debug variables test failed" "value1=$value1" "value2=$value2"
        return 1
    fi
}

# Test observed function execution
test_observed_functions() {
    local test_name="observed_functions"
    
    log_info "Testing observed function execution"
    
    # Define a test function
    test_function() {
        local arg1="$1"
        local arg2="$2"
        
        log_info "Test function called" "arg1=$arg1" "arg2=$arg2"
        
        if [[ "$arg1" == "fail" ]]; then
            return 1
        fi
        
        return 0
    }
    
    # Test successful function
    if observe_function test_function "success" "test"; then
        log_info "Observed function success test passed"
    else
        log_error "Observed function success test failed"
        return 1
    fi
    
    # Test failing function
    if ! observe_function test_function "fail" "test"; then
        log_info "Observed function failure test passed"
    else
        log_error "Observed function failure test failed"
        return 1
    fi
    
    return 0
}

# Test report generation
test_report_generation() {
    local test_name="report_generation"
    
    log_info "Testing report generation"
    
    # Generate a test report
    local report_output=$(generate_observability_report "test_report")
    local report_file=$(echo "$report_output" | tail -1)
    
    if [[ -f "$report_file" ]]; then
        log_info "Report generation test passed" "file=$report_file"
        
        # Check if report contains expected content
        if grep -q "Observability Report" "$report_file"; then
            log_info "Report content validation passed"
            return 0
        else
            log_error "Report content validation failed"
            return 1
        fi
    else
        log_error "Report generation test failed" "expected_file=$report_file"
        return 1
    fi
}

# Main test execution
run_observability_tests() {
    local failed_tests=0
    local total_tests=0
    
    echo "🔍 Running Observability Integration Tests"
    echo "=========================================="
    
    # Setup test environment
    setup_observability_test
    
    # Run individual tests
    local tests=(
        "test_basic_logging"
        "test_context_management"
        "test_performance_tracking"
        "test_debug_variables"
        "test_observed_functions"
        "test_report_generation"
    )
    
    for test_func in "${tests[@]}"; do
        echo ""
        echo "Running: $test_func"
        ((total_tests++))
        
        if $test_func; then
            echo "✅ PASSED: $test_func"
        else
            echo "❌ FAILED: $test_func"
            ((failed_tests++))
        fi
    done
    
    # Cleanup
    cleanup_observability_test
    
    # Summary
    echo ""
    echo "=========================================="
    echo "Test Summary:"
    echo "  Total tests: $total_tests"
    echo "  Passed: $((total_tests - failed_tests))"
    echo "  Failed: $failed_tests"
    
    if [[ $failed_tests -eq 0 ]]; then
        echo "🎉 All observability integration tests passed!"
        return 0
    else
        echo "💥 Some observability integration tests failed!"
        return 1
    fi
}

# Run tests if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_observability_tests
fi