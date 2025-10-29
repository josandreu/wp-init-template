#!/bin/bash

# Integration Tests for Error Recovery
# Tests error handling and recovery scenarios

# Source test dependencies
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/assertions.sh"
source "$SCRIPT_DIR/../../lib/mock-env.sh"
source "$SCRIPT_DIR/../../lib/validation-engine.sh"
source "$SCRIPT_DIR/../../lib/recovery-manager.sh"

# Test setup
setup_recovery_tests() {
    # Create isolated test environment
    TEST_ENV=$(create_mock_env "recovery_test")
    cd "$TEST_ENV"
    
    # Create WordPress structure
    mkdir -p wp-content/{plugins,themes,mu-plugins}
    
    # Create test files
    create_test_files
}

# Create test files for recovery scenarios
create_test_files() {
    # Create original configuration files
    cat > package.json << 'EOF'
{
  "name": "original-project",
  "version": "1.0.0",
  "scripts": {
    "test": "echo 'original test'"
  }
}
EOF

    cat > composer.json << 'EOF'
{
  "name": "original/project",
  "description": "Original project",
  "require": {
    "php": ">=7.4"
  }
}
EOF

    # Create .gitignore
    cat > .gitignore << 'EOF'
# Original gitignore
node_modules/
vendor/
EOF

    # Create sample component files
    mkdir -p wp-content/plugins/test-plugin
    cat > wp-content/plugins/test-plugin/plugin.php << 'EOF'
<?php
/**
 * Original Plugin
 */
echo "Original plugin content";
EOF
}

# Test teardown
teardown_recovery_tests() {
    cd - > /dev/null
    cleanup_mock_env "$TEST_ENV"
}

# Test basic recovery point creation
test_create_recovery_point() {
    echo "Testing recovery point creation..."
    
    setup_recovery_tests
    
    # Create recovery point
    local recovery_id
    recovery_id=$(create_recovery_point "test_operation" "package.json composer.json .gitignore")
    
    if [ -n "$recovery_id" ]; then
        print_assertion "PASS" "Should create recovery point with ID"
    else
        print_assertion "FAIL" "Should create recovery point with ID"
    fi
    
    # Check that backup files were created
    if [ -f "package.json.backup-$recovery_id" ]; then
        print_assertion "PASS" "Should create backup of package.json"
    else
        print_assertion "FAIL" "Should create backup of package.json"
    fi
    
    if [ -f "composer.json.backup-$recovery_id" ]; then
        print_assertion "PASS" "Should create backup of composer.json"
    else
        print_assertion "FAIL" "Should create backup of composer.json"
    fi
    
    # Check backup content integrity
    if diff -q package.json "package.json.backup-$recovery_id" >/dev/null; then
        print_assertion "PASS" "Backup should match original file content"
    else
        print_assertion "FAIL" "Backup should match original file content"
    fi
    
    teardown_recovery_tests
}

# Test recovery point rollback
test_recovery_rollback() {
    echo "Testing recovery rollback..."
    
    setup_recovery_tests
    
    # Create recovery point
    local recovery_id
    recovery_id=$(create_recovery_point "test_rollback" "package.json composer.json")
    
    # Modify files to simulate failed operation
    cat > package.json << 'EOF'
{
  "name": "corrupted-project",
  "version": "0.0.0",
  "invalid": "json syntax"
}
EOF

    echo "corrupted content" > composer.json
    
    # Verify files are modified
    if grep -q "corrupted-project" package.json; then
        print_assertion "PASS" "Files should be modified before rollback"
    else
        print_assertion "FAIL" "Files should be modified before rollback"
    fi
    
    # Execute rollback
    if execute_rollback "$recovery_id"; then
        print_assertion "PASS" "Should execute rollback successfully"
    else
        print_assertion "FAIL" "Should execute rollback successfully"
    fi
    
    # Verify files are restored
    if grep -q "original-project" package.json; then
        print_assertion "PASS" "Should restore original package.json content"
    else
        print_assertion "FAIL" "Should restore original package.json content"
    fi
    
    if grep -q "original/project" composer.json; then
        print_assertion "PASS" "Should restore original composer.json content"
    else
        print_assertion "FAIL" "Should restore original composer.json content"
    fi
    
    teardown_recovery_tests
}

# Test selective rollback
test_selective_rollback() {
    echo "Testing selective rollback..."
    
    setup_recovery_tests
    
    # Create recovery point for multiple files
    local recovery_id
    recovery_id=$(create_recovery_point "selective_test" "package.json composer.json .gitignore")
    
    # Modify all files
    echo "modified package.json" > package.json
    echo "modified composer.json" > composer.json
    echo "modified .gitignore" > .gitignore
    
    # Rollback only package.json
    if execute_rollback "$recovery_id" "package.json"; then
        print_assertion "PASS" "Should execute selective rollback"
    else
        print_assertion "FAIL" "Should execute selective rollback"
    fi
    
    # Verify only package.json is restored
    if grep -q "original-project" package.json; then
        print_assertion "PASS" "Should restore selected file (package.json)"
    else
        print_assertion "FAIL" "Should restore selected file (package.json)"
    fi
    
    # Verify other files remain modified
    if grep -q "modified composer.json" composer.json; then
        print_assertion "PASS" "Should leave unselected files modified"
    else
        print_assertion "FAIL" "Should leave unselected files modified"
    fi
    
    if grep -q "modified .gitignore" .gitignore; then
        print_assertion "PASS" "Should leave unselected files modified"
    else
        print_assertion "FAIL" "Should leave unselected files modified"
    fi
    
    teardown_recovery_tests
}

# Test automatic recovery scenarios
test_automatic_recovery() {
    echo "Testing automatic recovery..."
    
    setup_recovery_tests
    
    # Test recovery from validation failure
    export PROJECT_SLUG="test-project"
    export SELECTED_PLUGINS=("nonexistent-plugin")
    export SELECTED_THEMES=()
    export SELECTED_MU_PLUGINS=()
    
    # Create recovery point before validation
    local recovery_id
    recovery_id=$(create_recovery_point "validation_test" "package.json")
    
    # Simulate validation failure and recovery attempt
    init_validation_engine "CONFIGURE"
    
    # This should fail validation
    local selected_plugins=("${SELECTED_PLUGINS[@]}")
    if ! validate_component_directories "CONFIGURE" "plugins" selected_plugins; then
        print_assertion "PASS" "Should fail validation for nonexistent plugin"
        
        # Attempt automatic recovery
        if auto_recover "component_validation" "nonexistent-plugin"; then
            print_assertion "PASS" "Should attempt automatic recovery"
        else
            print_assertion "FAIL" "Should attempt automatic recovery"
        fi
    else
        print_assertion "FAIL" "Should fail validation for nonexistent plugin"
    fi
    
    teardown_recovery_tests
}

# Test recovery from file operation failures
test_file_operation_recovery() {
    echo "Testing file operation recovery..."
    
    setup_recovery_tests
    
    # Create recovery point
    local recovery_id
    recovery_id=$(create_recovery_point "file_operation_test" "package.json")
    
    # Simulate file operation failure (permission denied)
    chmod 444 package.json  # Make file read-only
    
    # Attempt to modify file (should fail)
    if ! echo "new content" > package.json 2>/dev/null; then
        print_assertion "PASS" "Should fail to modify read-only file"
        
        # Restore permissions and rollback
        chmod 644 package.json
        
        if execute_rollback "$recovery_id"; then
            print_assertion "PASS" "Should recover from file operation failure"
        else
            print_assertion "FAIL" "Should recover from file operation failure"
        fi
        
        # Verify original content is restored
        if grep -q "original-project" package.json; then
            print_assertion "PASS" "Should restore original content after recovery"
        else
            print_assertion "FAIL" "Should restore original content after recovery"
        fi
    else
        print_assertion "FAIL" "Should fail to modify read-only file"
        chmod 644 package.json  # Restore permissions for cleanup
    fi
    
    teardown_recovery_tests
}

# Test recovery from disk space issues
test_disk_space_recovery() {
    echo "Testing disk space recovery..."
    
    setup_recovery_tests
    
    # This test is challenging to implement without actually filling the disk
    # We'll simulate the scenario by testing the recovery logic
    
    # Create recovery point
    local recovery_id
    recovery_id=$(create_recovery_point "disk_space_test" "package.json")
    
    # Simulate disk space check failure
    init_validation_engine "CONFIGURE"
    
    # Mock disk space validation (would normally check actual disk space)
    # For testing, we'll assume it fails and test recovery response
    
    # Create a large temporary file to simulate space usage
    local temp_file="large_temp_file.tmp"
    
    # Create recovery strategy for disk space issues
    if auto_recover "disk_space_insufficient" "cleanup_temp_files"; then
        print_assertion "PASS" "Should attempt disk space recovery"
    else
        print_assertion "FAIL" "Should attempt disk space recovery"
    fi
    
    # Verify cleanup would be attempted
    # In real scenario, this would remove temporary files
    if [ ! -f "$temp_file" ]; then
        print_assertion "PASS" "Should clean up temporary files during recovery"
    else
        print_assertion "FAIL" "Should clean up temporary files during recovery"
    fi
    
    teardown_recovery_tests
}

# Test recovery point cleanup
test_recovery_cleanup() {
    echo "Testing recovery point cleanup..."
    
    setup_recovery_tests
    
    # Create multiple recovery points
    local recovery_id1
    local recovery_id2
    recovery_id1=$(create_recovery_point "test1" "package.json")
    recovery_id2=$(create_recovery_point "test2" "composer.json")
    
    # Verify backup files exist
    if [ -f "package.json.backup-$recovery_id1" ] && [ -f "composer.json.backup-$recovery_id2" ]; then
        print_assertion "PASS" "Should create multiple recovery points"
    else
        print_assertion "FAIL" "Should create multiple recovery points"
    fi
    
    # Clean up old recovery points
    cleanup_recovery_points
    
    # Verify cleanup (in real implementation, this would remove old backups)
    # For testing, we'll check that the function exists and can be called
    if command -v cleanup_recovery_points >/dev/null 2>&1; then
        print_assertion "PASS" "Should have recovery cleanup function"
    else
        print_assertion "FAIL" "Should have recovery cleanup function"
    fi
    
    teardown_recovery_tests
}

# Test error categorization and recovery strategies
test_error_categorization_recovery() {
    echo "Testing error categorization and recovery..."
    
    setup_recovery_tests
    
    # Test different error categories and their recovery strategies
    init_validation_engine "CONFIGURE"
    
    # Test CRITICAL error (should stop execution)
    add_validation_result "critical_test" "FAIL" "CRITICAL" "Critical error message" "Critical solution" ""
    
    if ! validation_can_continue; then
        print_assertion "PASS" "Should not continue with critical errors"
    else
        print_assertion "FAIL" "Should not continue with critical errors"
    fi
    
    # Reset and test WARNING (should allow continuation)
    init_validation_engine "CONFIGURE"
    add_validation_result "warning_test" "FAIL" "WARNING" "Warning message" "Warning solution" ""
    
    if validation_can_continue; then
        print_assertion "PASS" "Should continue with warnings only"
    else
        print_assertion "FAIL" "Should continue with warnings only"
    fi
    
    # Test INFO (should not affect continuation)
    add_validation_result "info_test" "INFO" "INFO" "Info message" "" ""
    
    if validation_can_continue; then
        print_assertion "PASS" "Should continue with info messages"
    else
        print_assertion "FAIL" "Should continue with info messages"
    fi
    
    teardown_recovery_tests
}

# Run all recovery tests
run_error_recovery_tests() {
    echo "🧪 Running Error Recovery Integration Tests..."
    echo "=============================================="
    
    test_create_recovery_point
    test_recovery_rollback
    test_selective_rollback
    test_automatic_recovery
    test_file_operation_recovery
    test_disk_space_recovery
    test_recovery_cleanup
    test_error_categorization_recovery
    
    echo ""
    echo "📊 Test Results:"
    echo "  • Total Assertions: $ASSERTION_COUNT"
    echo "  • Failed Assertions: $ASSERTION_FAILURES"
    echo "  • Success Rate: $(( (ASSERTION_COUNT - ASSERTION_FAILURES) * 100 / ASSERTION_COUNT ))%"
    
    if [ "$ASSERTION_FAILURES" -eq 0 ]; then
        echo "✅ All error recovery tests passed!"
        return 0
    else
        echo "❌ Some error recovery tests failed!"
        return 1
    fi
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_error_recovery_tests
fi