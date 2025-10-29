# Developer Guide: Writing Tests

## Overview

This guide provides detailed instructions for developers to write effective tests using the WordPress Init testing system. It covers best practices, patterns, and examples for creating maintainable and reliable tests.

## Getting Started

### Setting Up Your Development Environment

1. **Clone and setup**:
```bash
git clone <repository>
cd <project>
./tests/run-tests.sh --help  # Verify test system works
```

2. **Install development dependencies** (if any):
```bash
# The testing system is self-contained and requires no external dependencies
# However, you may want to install shellcheck for linting:
# brew install shellcheck  # macOS
# apt-get install shellcheck  # Ubuntu
```

3. **Configure your environment**:
```bash
cp tests/test-config.example tests/test-config
# Edit tests/test-config with your preferences
```

## Test Structure and Organization

### Directory Structure

```
tests/
├── unit/                   # Fast, isolated tests
│   ├── validation/        # Validation logic tests
│   ├── utils/             # Utility function tests
│   └── components/        # Component detection tests
├── integration/           # Component interaction tests
│   ├── modes/            # Mode operation tests
│   ├── workflows/        # Workflow tests
│   └── file-generation/  # File generation tests
├── e2e/                  # End-to-end scenario tests
│   ├── scenarios/        # User scenario tests
│   └── regression/       # Regression prevention tests
├── fixtures/             # Test data and mocks
│   ├── wordpress/        # WordPress structure mocks
│   ├── configs/          # Configuration test data
│   └── templates/        # Template test data
└── lib/                  # Testing libraries (don't modify)
```

### Naming Conventions

- **Test files**: `test_<component>_<scenario>.sh`
- **Test functions**: `test_<component>_<specific_behavior>`
- **Mock data**: `mock_<type>_<variant>.json`
- **Fixtures**: `fixture_<component>_<scenario>/`

### File Template

```bash
#!/bin/bash

# Test: <Component Name> - <Test Purpose>
# Description: Brief description of what this test validates

set -euo pipefail

# Get script directory and source dependencies
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly TEST_LIB_DIR="$(dirname "$SCRIPT_DIR")/lib"

source "$TEST_LIB_DIR/test-runner.sh"
source "$TEST_LIB_DIR/assertions.sh"
source "$TEST_LIB_DIR/mock-env.sh"

# Test setup (if needed)
setup_test_environment() {
    # Create any necessary test setup
    export TEST_VAR="test_value"
}

# Test cleanup (if needed)
cleanup_test_environment() {
    # Clean up any test artifacts
    unset TEST_VAR
}

# Individual test functions
test_component_basic_functionality() {
    local description="Component should handle basic input correctly"
    
    # Arrange
    local input="test_input"
    local expected="expected_output"
    
    # Act
    local result=$(component_function "$input")
    
    # Assert
    assert_equals "$expected" "$result" "$description"
}

test_component_error_handling() {
    local description="Component should handle invalid input gracefully"
    
    # Arrange
    local invalid_input=""
    
    # Act & Assert
    assert_command_fails "component_function '$invalid_input'" "$description"
}

# Main execution
main() {
    setup_test_environment
    
    run_test "test_component_basic_functionality"
    run_test "test_component_error_handling"
    
    cleanup_test_environment
}

# Execute if run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

## Writing Unit Tests

Unit tests should be fast, isolated, and test single functions or small components.

### Example: Testing a Validation Function

```bash
#!/bin/bash

source "$(dirname "$0")/../../lib/test-runner.sh"
source "$(dirname "$0")/../../lib/assertions.sh"
source "$(dirname "$0")/../../lib/validation-engine.sh"

test_validate_wordpress_structure_success() {
    local description="Should pass validation for valid WordPress structure"
    
    # Arrange
    local mock_env=$(create_mock_env "wordpress_valid")
    create_mock_wordpress "plugins,themes" "wp-content" "$mock_env"
    
    # Act
    local result
    cd "$mock_env"
    result=$(validate_wordpress_structure)
    local exit_code=$?
    
    # Assert
    assert_equals 0 "$exit_code" "$description - exit code"
    assert_contains "$result" "PASS" "$description - result contains PASS"
    
    # Cleanup
    cleanup_mock_env "$mock_env"
}

test_validate_wordpress_structure_missing_directory() {
    local description="Should fail validation for missing wp-content"
    
    # Arrange
    local mock_env=$(create_mock_env "wordpress_invalid")
    mkdir -p "$mock_env/some_other_dir"
    
    # Act
    local result
    cd "$mock_env"
    result=$(validate_wordpress_structure 2>&1)
    local exit_code=$?
    
    # Assert
    assert_not_equals 0 "$exit_code" "$description - exit code"
    assert_contains "$result" "wp-content not found" "$description - error message"
    
    # Cleanup
    cleanup_mock_env "$mock_env"
}

# Run tests
run_test "test_validate_wordpress_structure_success"
run_test "test_validate_wordpress_structure_missing_directory"
```

### Best Practices for Unit Tests

1. **Test one thing**: Each test should validate one specific behavior
2. **Use descriptive names**: Test names should clearly indicate what's being tested
3. **Follow AAA pattern**: Arrange (setup), Act (execute), Assert (verify)
4. **Mock dependencies**: Use mock environments for file system operations
5. **Clean up**: Always clean up test artifacts

## Writing Integration Tests

Integration tests validate component interactions and complete workflows.

### Example: Testing Mode Operations

```bash
#!/bin/bash

source "$(dirname "$0")/../../lib/test-runner.sh"
source "$(dirname "$0")/../../lib/assertions.sh"
source "$(dirname "$0")/../../lib/mock-env.sh"

test_mode_1_complete_workflow() {
    local description="Mode 1 should complete full project setup"
    
    # Arrange
    local mock_env=$(create_mock_env "mode1_test")
    create_mock_wordpress "plugins,themes,mu-plugins" "wp-content" "$mock_env"
    mock_tool "jq" "success"
    mock_tool "composer" "success"
    
    # Create test configuration
    cat > "$mock_env/.project-config" << EOF
MODE=1
COMPONENTS=("plugins" "themes" "mu-plugins")
FORMAT_CODE=true
SETUP_COMPOSER=true
EOF
    
    # Act
    cd "$mock_env"
    local result
    result=$(bash "$PROJECT_ROOT/init-project.sh" 2>&1)
    local exit_code=$?
    
    # Assert
    assert_equals 0 "$exit_code" "$description - exit code"
    assert_file_exists "$mock_env/composer.json" "$description - composer.json created"
    assert_file_exists "$mock_env/phpcs.xml.dist" "$description - phpcs.xml.dist created"
    assert_file_exists "$mock_env/eslint.config.js" "$description - eslint.config.js created"
    
    # Verify file contents
    assert_file_contains "$mock_env/composer.json" "wp-coding-standards" "$description - composer includes coding standards"
    
    # Cleanup
    cleanup_mock_env "$mock_env"
}

test_mode_2_config_only_workflow() {
    local description="Mode 2 should setup configuration without formatting"
    
    # Arrange
    local mock_env=$(create_mock_env "mode2_test")
    create_mock_wordpress "plugins" "wp-content" "$mock_env"
    
    cat > "$mock_env/.project-config" << EOF
MODE=2
COMPONENTS=("plugins")
FORMAT_CODE=false
SETUP_COMPOSER=true
EOF
    
    # Act
    cd "$mock_env"
    local result
    result=$(bash "$PROJECT_ROOT/init-project.sh" 2>&1)
    local exit_code=$?
    
    # Assert
    assert_equals 0 "$exit_code" "$description - exit code"
    assert_file_exists "$mock_env/composer.json" "$description - composer.json created"
    assert_file_not_exists "$mock_env/phpcs.xml.dist" "$description - phpcs.xml.dist not created"
    assert_file_not_exists "$mock_env/eslint.config.js" "$description - eslint.config.js not created"
    
    # Cleanup
    cleanup_mock_env "$mock_env"
}

# Run tests
run_test "test_mode_1_complete_workflow"
run_test "test_mode_2_config_only_workflow"
```

### Best Practices for Integration Tests

1. **Test realistic scenarios**: Use complete workflows that users would actually perform
2. **Use comprehensive mocks**: Mock the full environment including external tools
3. **Verify side effects**: Check that files are created, modified, or deleted as expected
4. **Test error paths**: Include tests for failure scenarios and recovery
5. **Keep tests independent**: Each test should be able to run in isolation

## Writing End-to-End Tests

E2E tests validate complete user scenarios from start to finish.

### Example: New Project Setup

```bash
#!/bin/bash

source "$(dirname "$0")/../../lib/test-runner.sh"
source "$(dirname "$0")/../../lib/assertions.sh"
source "$(dirname "$0")/../../lib/mock-env.sh"

test_new_project_complete_setup() {
    local description="New project setup should work end-to-end"
    
    # Arrange - Create a realistic new project environment
    local mock_env=$(create_mock_env "new_project_e2e")
    
    # Create basic WordPress structure as a new project would have
    mkdir -p "$mock_env/wp-content/plugins"
    mkdir -p "$mock_env/wp-content/themes"
    mkdir -p "$mock_env/wp-content/mu-plugins"
    
    # Mock external tools
    mock_tool "jq" "success"
    mock_tool "composer" "success"
    mock_tool "npm" "success"
    
    # Act - Run the complete initialization as a user would
    cd "$mock_env"
    
    # Simulate user input for interactive mode
    echo -e "1\ny\ny\ny\n" | bash "$PROJECT_ROOT/init-project.sh"
    local exit_code=$?
    
    # Assert - Verify complete project setup
    assert_equals 0 "$exit_code" "$description - script completed successfully"
    
    # Verify all expected files are created
    local expected_files=(
        "composer.json"
        "phpcs.xml.dist"
        "eslint.config.js"
        "bitbucket-pipelines.yml"
        "Makefile"
        ".gitignore"
    )
    
    for file in "${expected_files[@]}"; do
        assert_file_exists "$mock_env/$file" "$description - $file created"
    done
    
    # Verify file contents are correct
    assert_file_contains "$mock_env/composer.json" "wp-coding-standards" "$description - composer includes coding standards"
    assert_file_contains "$mock_env/phpcs.xml.dist" "WordPress" "$description - phpcs configured for WordPress"
    assert_file_contains "$mock_env/eslint.config.js" "@wordpress/eslint-plugin" "$description - eslint configured for WordPress"
    
    # Verify project structure is maintained
    assert_directory_exists "$mock_env/wp-content/plugins" "$description - plugins directory preserved"
    assert_directory_exists "$mock_env/wp-content/themes" "$description - themes directory preserved"
    
    # Cleanup
    cleanup_mock_env "$mock_env"
}

test_existing_project_integration() {
    local description="Existing project integration should preserve existing files"
    
    # Arrange - Create existing project with some files
    local mock_env=$(create_mock_env "existing_project_e2e")
    create_mock_wordpress "plugins,themes" "wp-content" "$mock_env"
    
    # Create existing files that should be preserved
    echo "existing content" > "$mock_env/existing-file.txt"
    cat > "$mock_env/composer.json" << EOF
{
    "name": "existing/project",
    "existing": "content"
}
EOF
    
    # Act
    cd "$mock_env"
    echo -e "2\ny\n" | bash "$PROJECT_ROOT/init-project.sh"
    local exit_code=$?
    
    # Assert
    assert_equals 0 "$exit_code" "$description - script completed successfully"
    assert_file_exists "$mock_env/existing-file.txt" "$description - existing file preserved"
    assert_file_contains "$mock_env/existing-file.txt" "existing content" "$description - existing content preserved"
    
    # Verify composer.json was merged, not replaced
    assert_file_contains "$mock_env/composer.json" "existing/project" "$description - existing composer content preserved"
    assert_file_contains "$mock_env/composer.json" "wp-coding-standards" "$description - new content added"
    
    # Cleanup
    cleanup_mock_env "$mock_env"
}

# Run tests
run_test "test_new_project_complete_setup"
run_test "test_existing_project_integration"
```

### Best Practices for E2E Tests

1. **Test real user scenarios**: Simulate actual user workflows
2. **Use realistic data**: Create test environments that mirror real projects
3. **Test cross-platform**: Ensure tests work on different operating systems
4. **Include error scenarios**: Test what happens when things go wrong
5. **Verify complete outcomes**: Check all side effects and final state

## Using Mock Environments

Mock environments provide isolated testing without affecting the real system.

### Creating Mock Environments

```bash
# Basic mock environment
local mock_env=$(create_mock_env "test_name")

# Mock WordPress structure
create_mock_wordpress "plugins,themes,mu-plugins" "wp-content" "$mock_env"

# Mock with specific WordPress version
create_mock_wordpress "plugins" "wordpress/wp-content" "$mock_env" "6.0"
```

### Mocking External Tools

```bash
# Mock successful tool
mock_tool "jq" "success"

# Mock failing tool
mock_tool "composer" "failure"

# Mock missing tool
mock_tool "npm" "not_found"

# Custom mock behavior
mock_tool_custom "jq" "echo 'custom output'"
```

### Mock Environment Best Practices

1. **Always clean up**: Use `cleanup_mock_env` in test cleanup
2. **Use specific names**: Give mock environments descriptive names
3. **Mock realistically**: Create mock environments that match real scenarios
4. **Test isolation**: Ensure mocks don't interfere with each other
5. **Resource management**: Be mindful of disk space and cleanup

## Assertion Reference

### Basic Assertions

```bash
# Equality
assert_equals "expected" "$actual" "description"
assert_not_equals "unexpected" "$actual" "description"

# Boolean
assert_true "$condition" "description"
assert_false "$condition" "description"

# Null/Empty
assert_null "$variable" "description"
assert_not_null "$variable" "description"
assert_empty "$string" "description"
assert_not_empty "$string" "description"
```

### String Assertions

```bash
# Contains
assert_contains "$haystack" "needle" "description"
assert_not_contains "$haystack" "needle" "description"

# Patterns
assert_matches "$string" "regex_pattern" "description"
assert_not_matches "$string" "regex_pattern" "description"

# Case
assert_starts_with "$string" "prefix" "description"
assert_ends_with "$string" "suffix" "description"
```

### File System Assertions

```bash
# File existence
assert_file_exists "/path/to/file" "description"
assert_file_not_exists "/path/to/file" "description"

# Directory existence
assert_directory_exists "/path/to/dir" "description"
assert_directory_not_exists "/path/to/dir" "description"

# File content
assert_file_contains "/path/to/file" "search_text" "description"
assert_file_not_contains "/path/to/file" "search_text" "description"

# File properties
assert_file_executable "/path/to/file" "description"
assert_file_readable "/path/to/file" "description"
assert_file_writable "/path/to/file" "description"

# Directory properties
assert_directory_empty "/path/to/dir" "description"
assert_directory_not_empty "/path/to/dir" "description"
```

### Command Assertions

```bash
# Command execution
assert_command_succeeds "command arg1 arg2" "description"
assert_command_fails "command arg1 arg2" "description"

# Command output
assert_command_output "expected_output" "command" "description"
assert_command_output_contains "partial_output" "command" "description"

# Exit codes
assert_exit_code 0 "command" "description"
assert_exit_code_not 1 "command" "description"
```

### Numeric Assertions

```bash
# Comparison
assert_greater_than 10 "$value" "description"
assert_less_than 5 "$value" "description"
assert_greater_or_equal 10 "$value" "description"
assert_less_or_equal 5 "$value" "description"

# Range
assert_in_range 1 10 "$value" "description"
assert_not_in_range 1 10 "$value" "description"
```

## Debugging Tests

### Enabling Debug Mode

```bash
# In your test file
source "$TEST_LIB_DIR/debugger.sh"
enable_debug_mode

# Add breakpoints
debug_breakpoint "Before validation"

# Inspect variables
debug_inspect_var "result" "$result"
debug_inspect_array "components" "${components[@]}"
```

### Verbose Output

```bash
# Run with verbose output
./tests/run-tests.sh --verbose

# Or set environment variable
export TEST_VERBOSE=true
./tests/run-tests.sh
```

### Logging

```bash
# Source logger
source "$TEST_LIB_DIR/logger.sh"

# Log at different levels
log_debug "Detailed debugging information"
log_info "General information"
log_warn "Warning conditions"
log_error "Error conditions"
```

## Performance Considerations

### Writing Fast Tests

1. **Minimize file I/O**: Use in-memory operations when possible
2. **Avoid external commands**: Use bash built-ins instead of external tools
3. **Parallel-safe**: Ensure tests can run concurrently
4. **Resource cleanup**: Clean up promptly to free resources

### Performance Testing

```bash
# Enable performance tracking
export TEST_PERFORMANCE_TRACKING=true

# Run with timing
./tests/run-tests.sh --timing

# Check for performance regressions
./tests/lib/trend-analyzer.sh --check-regression
```

## Common Patterns

### Testing Configuration Files

```bash
test_config_file_generation() {
    local description="Should generate valid configuration file"
    
    # Arrange
    local mock_env=$(create_mock_env "config_test")
    local config_data='{"key": "value"}'
    
    # Act
    cd "$mock_env"
    generate_config_file "$config_data" "config.json"
    
    # Assert
    assert_file_exists "$mock_env/config.json" "$description - file created"
    assert_file_contains "$mock_env/config.json" '"key": "value"' "$description - content correct"
    
    # Validate JSON syntax
    assert_command_succeeds "jq . '$mock_env/config.json'" "$description - valid JSON"
    
    # Cleanup
    cleanup_mock_env "$mock_env"
}
```

### Testing Error Conditions

```bash
test_error_handling() {
    local description="Should handle missing dependencies gracefully"
    
    # Arrange
    local mock_env=$(create_mock_env "error_test")
    mock_tool "required_tool" "not_found"
    
    # Act & Assert
    cd "$mock_env"
    assert_command_fails "function_requiring_tool" "$description - fails when tool missing"
    
    # Verify error message
    local error_output
    error_output=$(function_requiring_tool 2>&1)
    assert_contains "$error_output" "required_tool not found" "$description - error message"
    
    # Cleanup
    cleanup_mock_env "$mock_env"
}
```

### Testing File Modifications

```bash
test_file_modification() {
    local description="Should modify existing file correctly"
    
    # Arrange
    local mock_env=$(create_mock_env "modify_test")
    echo "original content" > "$mock_env/test.txt"
    
    # Act
    cd "$mock_env"
    modify_file "test.txt" "new content"
    
    # Assert
    assert_file_exists "$mock_env/test.txt" "$description - file still exists"
    assert_file_contains "$mock_env/test.txt" "new content" "$description - content updated"
    assert_file_not_contains "$mock_env/test.txt" "original content" "$description - old content removed"
    
    # Cleanup
    cleanup_mock_env "$mock_env"
}
```

## Troubleshooting

### Common Issues

**Test fails with "command not found"**:
- Ensure the function/command is sourced or in PATH
- Check if external tools need to be mocked
- Verify the command exists in the mock environment

**Mock environment issues**:
- Check that `cleanup_mock_env` is called
- Verify mock environment path is correct
- Ensure sufficient disk space for mock environments

**Assertion failures**:
- Use `--verbose` to see detailed assertion output
- Add debug statements to inspect variable values
- Check that expected values match actual output format

**Parallel execution issues**:
- Ensure tests don't share state or resources
- Use unique mock environment names
- Avoid hardcoded paths or temporary files

### Getting Help

1. **Check existing tests**: Look at similar tests for patterns
2. **Use verbose mode**: Run with `--verbose` for detailed output
3. **Enable debugging**: Use debug utilities to inspect test execution
4. **Review documentation**: Check this guide and the main README
5. **Ask for help**: Reach out to the team with specific questions

## Contributing

### Code Review Checklist

- [ ] Tests follow naming conventions
- [ ] Tests are properly categorized (unit/integration/e2e)
- [ ] Mock environments are used appropriately
- [ ] All assertions have descriptive messages
- [ ] Tests clean up after themselves
- [ ] Tests are independent and can run in parallel
- [ ] Performance considerations are addressed
- [ ] Error cases are tested
- [ ] Documentation is updated if needed

### Submitting Tests

1. **Write tests**: Follow the patterns in this guide
2. **Run locally**: Ensure tests pass on your machine
3. **Check performance**: Verify tests meet performance requirements
4. **Update documentation**: Add any new patterns or utilities
5. **Submit PR**: Include test results and performance metrics