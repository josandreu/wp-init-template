#!/bin/bash

# Unit Tests for Validation Engine
# Tests validation functions in isolation

# Source test dependencies
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/assertions.sh"
source "$SCRIPT_DIR/../../lib/mock-env.sh"
source "$SCRIPT_DIR/../../lib/validation-engine.sh"

# Mock logging functions for testing
log_info() { echo "INFO: $1"; }
log_warning() { echo "WARNING: $1"; }
log_error() { echo "ERROR: $1"; }

# Test setup
setup_validation_tests() {
    # Reset validation state
    VALIDATION_ERRORS=0
    VALIDATION_WARNINGS=0
    VALIDATION_INFO=0
    VALIDATION_RESULTS=()
    VALIDATION_CONTEXT=""
    
    # Mock WordPress structure
    WP_CONTENT_DIR="wp-content"
}

# Test teardown
teardown_validation_tests() {
    cleanup_mock_env
}

# Test init_validation_engine function
test_init_validation_engine() {
    echo "Testing init_validation_engine..."
    
    init_validation_engine "CONFIGURE"
    
    assert_equals "CONFIGURE" "$VALIDATION_CONTEXT" "Context should be set correctly"
    assert_equals "0" "$VALIDATION_ERRORS" "Errors should be reset to 0"
    assert_equals "0" "$VALIDATION_WARNINGS" "Warnings should be reset to 0"
    assert_equals "0" "$VALIDATION_INFO" "Info should be reset to 0"
    assert_equals "0" "${#VALIDATION_RESULTS[@]}" "Results array should be empty"
}

# Test add_validation_result function
test_add_validation_result() {
    echo "Testing add_validation_result..."
    
    setup_validation_tests
    
    # Test adding a critical error
    add_validation_result "test_check" "FAIL" "CRITICAL" "Test error message" "Test solution" "test.txt"
    
    assert_equals "1" "$VALIDATION_ERRORS" "Should increment error count"
    assert_equals "1" "${#VALIDATION_RESULTS[@]}" "Should add result to array"
    
    # Test adding a warning
    add_validation_result "test_warning" "WARN" "WARNING" "Test warning message" "" ""
    
    assert_equals "1" "$VALIDATION_WARNINGS" "Should increment warning count"
    assert_equals "2" "${#VALIDATION_RESULTS[@]}" "Should add second result to array"
    
    # Test adding info
    add_validation_result "test_info" "INFO" "INFO" "Test info message" "" ""
    
    assert_equals "1" "$VALIDATION_INFO" "Should increment info count"
    assert_equals "3" "${#VALIDATION_RESULTS[@]}" "Should add third result to array"
}

# Test get_validation_summary function
test_get_validation_summary() {
    echo "Testing get_validation_summary..."
    
    setup_validation_tests
    
    add_validation_result "test1" "FAIL" "CRITICAL" "Error" "" ""
    add_validation_result "test2" "WARN" "WARNING" "Warning" "" ""
    add_validation_result "test3" "INFO" "INFO" "Info" "" ""
    
    local summary
    summary=$(get_validation_summary)
    
    assert_equals "ERRORS:1|WARNINGS:1|INFO:1" "$summary" "Summary should match expected format"
}

# Test validation_passed function
test_validation_passed() {
    echo "Testing validation_passed..."
    
    setup_validation_tests
    
    # Test with no errors
    if validation_passed; then
        print_assertion "PASS" "Should pass with no errors"
    else
        print_assertion "FAIL" "Should pass with no errors"
    fi
    
    # Test with errors
    add_validation_result "test" "FAIL" "CRITICAL" "Error" "" ""
    
    if ! validation_passed; then
        print_assertion "PASS" "Should fail with errors"
    else
        print_assertion "FAIL" "Should fail with errors"
    fi
}

# Test validation_can_continue function
test_validation_can_continue() {
    echo "Testing validation_can_continue..."
    
    setup_validation_tests
    
    # Test with no errors
    if validation_can_continue; then
        print_assertion "PASS" "Should continue with no errors"
    else
        print_assertion "FAIL" "Should continue with no errors"
    fi
    
    # Test with warning only
    add_validation_result "test" "FAIL" "WARNING" "Warning" "" ""
    
    if validation_can_continue; then
        print_assertion "PASS" "Should continue with warnings only"
    else
        print_assertion "FAIL" "Should continue with warnings only"
    fi
    
    # Test with critical error
    add_validation_result "test2" "FAIL" "CRITICAL" "Critical error" "" ""
    
    if ! validation_can_continue; then
        print_assertion "PASS" "Should not continue with critical errors"
    else
        print_assertion "FAIL" "Should not continue with critical errors"
    fi
}

# Test validate_project_slug function
test_validate_project_slug() {
    echo "Testing validate_project_slug..."
    
    setup_validation_tests
    
    # Test valid slug
    if validate_project_slug "CONFIGURE" "my-project"; then
        print_assertion "PASS" "Should accept valid slug"
    else
        print_assertion "FAIL" "Should accept valid slug"
    fi
    
    setup_validation_tests
    
    # Test invalid slug with uppercase
    if ! validate_project_slug "CONFIGURE" "My-Project"; then
        print_assertion "PASS" "Should reject slug with uppercase"
    else
        print_assertion "FAIL" "Should reject slug with uppercase"
    fi
    
    setup_validation_tests
    
    # Test invalid slug with special characters
    if ! validate_project_slug "CONFIGURE" "my_project!"; then
        print_assertion "PASS" "Should reject slug with special characters"
    else
        print_assertion "FAIL" "Should reject slug with special characters"
    fi
    
    setup_validation_tests
    
    # Test empty slug (should be info, not error)
    if validate_project_slug "CONFIGURE" ""; then
        print_assertion "PASS" "Should handle empty slug gracefully"
    else
        print_assertion "FAIL" "Should handle empty slug gracefully"
    fi
}

# Test validate_write_permissions function
test_validate_write_permissions() {
    echo "Testing validate_write_permissions..."
    
    setup_validation_tests
    
    # Create temporary directory for testing
    local test_dir
    test_dir=$(create_mock_env "write_permissions_test")
    
    # Test writable directory
    if validate_write_permissions "CONFIGURE" "$test_dir"; then
        print_assertion "PASS" "Should pass for writable directory"
    else
        print_assertion "FAIL" "Should pass for writable directory"
    fi
    
    cleanup_mock_env "$test_dir"
}

# Test validate_disk_space function
test_validate_disk_space() {
    echo "Testing validate_disk_space..."
    
    setup_validation_tests
    
    # Test with very low requirement (should pass)
    if validate_disk_space "CONFIGURE" 1; then
        print_assertion "PASS" "Should pass with low disk space requirement"
    else
        print_assertion "FAIL" "Should pass with low disk space requirement"
    fi
    
    # Note: Testing insufficient disk space is difficult without actually filling the disk
    # This would be better tested in integration tests with mock df command
}

# Test context-specific validation functions
test_validate_configure_context() {
    echo "Testing validate_configure_context..."
    
    setup_validation_tests
    
    # Mock required variables
    SELECTED_PLUGINS=()
    SELECTED_THEMES=()
    SELECTED_MU_PLUGINS=()
    PROJECT_SLUG="test-project"
    
    # Create mock WordPress structure
    local test_env
    test_env=$(create_mock_env "configure_test")
    mkdir -p "$test_env/wp-content"
    WP_CONTENT_DIR="$test_env/wp-content"
    
    # Create required template
    touch ".gitignore.template"
    
    # Run validation
    local result=0
    validate_configure_context || result=$?
    
    # Should have some validation results
    if [ "${#VALIDATION_RESULTS[@]}" -gt 0 ]; then
        print_assertion "PASS" "Should generate validation results"
    else
        print_assertion "FAIL" "Should generate validation results"
    fi
    
    # Clean up
    rm -f ".gitignore.template"
    cleanup_mock_env "$test_env"
}

# Run all tests
run_validation_engine_tests() {
    echo "🧪 Running Validation Engine Unit Tests..."
    echo "================================================"
    
    test_init_validation_engine
    test_add_validation_result
    test_get_validation_summary
    test_validation_passed
    test_validation_can_continue
    test_validate_project_slug
    test_validate_write_permissions
    test_validate_disk_space
    test_validate_configure_context
    
    echo ""
    echo "📊 Test Results:"
    echo "  • Total Assertions: $ASSERTION_COUNT"
    echo "  • Failed Assertions: $ASSERTION_FAILURES"
    echo "  • Success Rate: $(( (ASSERTION_COUNT - ASSERTION_FAILURES) * 100 / ASSERTION_COUNT ))%"
    
    if [ "$ASSERTION_FAILURES" -eq 0 ]; then
        echo "✅ All validation engine tests passed!"
        return 0
    else
        echo "❌ Some validation engine tests failed!"
        return 1
    fi
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_validation_engine_tests
fi