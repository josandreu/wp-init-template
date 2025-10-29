# WordPress Init Testing System

## Overview

This directory contains a comprehensive testing system for the WordPress Init project. The system provides modular, robust testing capabilities with advanced features like parallel execution, mock environments, error recovery, and detailed reporting.

## Architecture

The testing system follows a layered architecture:

```
tests/
├── lib/                    # Core testing libraries
├── unit/                   # Fast, isolated tests
├── integration/            # Component interaction tests  
├── e2e/                    # End-to-end user scenarios
├── fixtures/               # Test data and mocks
├── examples/               # Usage examples and demos
├── run-tests.sh           # Main test runner
└── run-comprehensive-tests.sh  # Full system validation
```

## Quick Start

### Running Tests

```bash
# Run all tests
./tests/run-tests.sh

# Run specific test suite
./tests/run-tests.sh --suite unit
./tests/run-tests.sh --suite integration
./tests/run-tests.sh --suite e2e

# Run with specific options
./tests/run-tests.sh --verbose --parallel 8 --format json
```

### Basic Test Structure

```bash
#!/bin/bash
source "$(dirname "$0")/../lib/test-runner.sh"

test_my_function() {
    # Setup
    local test_input="example"
    
    # Execute
    local result=$(my_function "$test_input")
    
    # Assert
    assert_equals "expected_output" "$result" "Function should return expected output"
}

# Run the test
run_test "test_my_function"
```

## Test Categories

### Unit Tests (`tests/unit/`)

Fast, isolated tests that validate individual functions and components:

- **Purpose**: Test single functions in isolation
- **Speed**: < 1 second per test
- **Dependencies**: Minimal, use mocks for external dependencies
- **Coverage**: Core logic, edge cases, error conditions

**Example Structure**:
```bash
tests/unit/
├── validation/
│   └── test_validation_engine.sh
├── utils/
│   └── test_utility_functions.sh
└── components/
    └── test_component_detection.sh
```

### Integration Tests (`tests/integration/`)

Tests that validate component interactions and workflows:

- **Purpose**: Test component integration and workflows
- **Speed**: < 10 seconds per test
- **Dependencies**: Mock environments, real file operations
- **Coverage**: Mode operations, file generation, error recovery

**Example Structure**:
```bash
tests/integration/
├── modes/
│   ├── test_mode_1_complete.sh
│   └── test_mode_2_config_only.sh
├── workflows/
│   └── test_error_recovery.sh
└── file-generation/
    └── test_template_processing.sh
```

### End-to-End Tests (`tests/e2e/`)

Complete user scenario tests:

- **Purpose**: Test complete user workflows
- **Speed**: < 60 seconds per test
- **Dependencies**: Full mock WordPress environments
- **Coverage**: User scenarios, regression prevention, cross-platform validation

**Example Structure**:
```bash
tests/e2e/
├── scenarios/
│   └── test_new_project_setup.sh
└── regression/
    └── test_regression_scenarios.sh
```

## Core Libraries

### Test Runner (`tests/lib/test-runner.sh`)

Main test execution engine with parallel processing:

```bash
# Run single test
run_test "test_function_name"

# Run test suite
run_test_suite "unit" "pattern*"

# Configure parallel execution
export TEST_PARALLEL_JOBS=8
```

### Assertions (`tests/lib/assertions.sh`)

Comprehensive assertion functions:

```bash
# Basic assertions
assert_equals "expected" "$actual"
assert_not_equals "unexpected" "$actual"
assert_true "$condition"
assert_false "$condition"

# File assertions
assert_file_exists "/path/to/file"
assert_file_not_exists "/path/to/file"
assert_file_contains "/path/to/file" "search_text"

# Directory assertions
assert_directory_exists "/path/to/dir"
assert_directory_empty "/path/to/dir"

# Command assertions
assert_command_succeeds "command arg1 arg2"
assert_command_fails "command arg1 arg2"
assert_command_output "expected_output" "command"
```

### Mock Environment (`tests/lib/mock-env.sh`)

Isolated testing environments:

```bash
# Create mock environment
create_mock_env "test_name" "config_options"

# Mock WordPress structure
create_mock_wordpress "plugins,themes" "wp-content"

# Mock external tools
mock_tool "jq" "success"  # or "failure", "not_found"
mock_tool "composer" "not_found"

# Cleanup
cleanup_mock_env "$env_path"
```

### Validation Engine (`tests/lib/validation-engine.sh`)

Modular validation system:

```bash
# Run validations
validate_system "CONFIGURE" "components_array" "mode_1"
validate_context "TEMPLATE" "config_data"

# Check validation results
if validation_passed; then
    echo "All validations passed"
fi
```

### Recovery Manager (`tests/lib/recovery-manager.sh`)

Backup and rollback system:

```bash
# Create recovery point
recovery_id=$(create_recovery_point "operation_name" "files_to_backup")

# Execute rollback if needed
if [ "$operation_failed" = "true" ]; then
    execute_rollback "$recovery_id"
fi
```

## Configuration

### Environment Variables

```bash
# Test execution
export TEST_PARALLEL_JOBS=4        # Number of parallel test processes
export TEST_TIMEOUT=60             # Test timeout in seconds
export TEST_VERBOSE=true           # Enable verbose output
export TEST_QUIET=false            # Disable most output

# Mock environment
export MOCK_CLEANUP_ON_EXIT=true   # Auto-cleanup mock environments
export MOCK_WORDPRESS_VERSION="6.0" # WordPress version to mock

# Reporting
export TEST_DEFAULT_FORMAT="console" # console, json, html, all
export TEST_REPORT_DIR="test-reports" # Report output directory

# Performance tracking
export TEST_PERFORMANCE_TRACKING=true
export TEST_TREND_ANALYSIS=true
export TEST_REGRESSION_CHECK=true

# CI/CD integration
export CI_MODE=false               # Enable CI-specific behavior
export CI_FAIL_FAST=true          # Stop on first failure in CI
```

### Configuration File

Create `tests/test-config` (copy from `tests/test-config.example`):

```bash
# Test Configuration File
TEST_PARALLEL_JOBS=4
TEST_VERBOSE=false
TEST_DEFAULT_FORMAT="console"
MOCK_CLEANUP_ON_EXIT=true
TEST_PERFORMANCE_TRACKING=true
```

## Reporting

### Console Output

Default colorized console output with progress indicators:

```
Running Unit Tests...
✓ test_validation_engine_basic_validation
✓ test_validation_engine_error_categorization
✗ test_validation_engine_recovery_points
  Details: Expected recovery point creation, but none found

Test Results:
  Passed: 15
  Failed: 1
  Skipped: 0
  Duration: 2.3s
```

### JSON Reports

Structured data for CI/CD integration:

```json
{
  "summary": {
    "total": 16,
    "passed": 15,
    "failed": 1,
    "skipped": 0,
    "duration": 2.3
  },
  "tests": [
    {
      "name": "test_validation_engine_basic_validation",
      "status": "PASS",
      "duration": 0.1,
      "assertions": {"total": 5, "passed": 5, "failed": 0}
    }
  ]
}
```

### HTML Reports

Visual reports with charts and detailed breakdowns (generated in `test-reports/`).

## Performance Tracking

The system includes built-in performance monitoring:

- **Execution Time Tracking**: Per-test and suite-level timing
- **Historical Trends**: Track performance over time
- **Regression Detection**: Alert on performance degradation
- **Resource Usage**: Monitor memory and disk usage

Access performance data:

```bash
# Enable performance tracking
export TEST_PERFORMANCE_TRACKING=true

# View performance trends
./tests/lib/trend-analyzer.sh --show-trends

# Check for regressions
./tests/lib/trend-analyzer.sh --check-regression
```

## Debugging

### Verbose Mode

Enable detailed debugging output:

```bash
./tests/run-tests.sh --verbose
# or
export TEST_VERBOSE=true
```

### Debug Utilities

```bash
# Source debugging utilities
source tests/lib/debugger.sh

# Enable debug mode in tests
enable_debug_mode

# Add debug breakpoints
debug_breakpoint "Checking file generation"

# Inspect variables
debug_inspect_var "result" "$result"
```

### Log Analysis

Structured logging with multiple levels:

```bash
# Source logger
source tests/lib/logger.sh

# Log at different levels
log_debug "Detailed debugging information"
log_info "General information"
log_warn "Warning conditions"
log_error "Error conditions"
log_critical "Critical failures"
```

## Best Practices

### Writing Tests

1. **Keep tests focused**: One concept per test function
2. **Use descriptive names**: `test_validation_engine_handles_missing_wordpress_structure`
3. **Follow AAA pattern**: Arrange, Act, Assert
4. **Clean up resources**: Use mock environments and cleanup functions
5. **Make tests independent**: Tests should not depend on each other

### Test Organization

1. **Group related tests**: Use subdirectories for logical grouping
2. **Use consistent naming**: `test_<component>_<scenario>.sh`
3. **Document complex tests**: Add comments for non-obvious logic
4. **Use fixtures**: Store test data in `tests/fixtures/`

### Performance

1. **Keep unit tests fast**: < 1 second per test
2. **Use mocks appropriately**: Mock external dependencies
3. **Parallel-safe tests**: Avoid shared state between tests
4. **Resource cleanup**: Always clean up temporary files

## Troubleshooting

### Common Issues

**Tests hanging or timing out**:
- Check for infinite loops or blocking operations
- Verify mock environments are properly isolated
- Increase timeout with `TEST_TIMEOUT` environment variable

**Permission errors**:
- Ensure test directories are writable
- Check mock environment permissions
- Verify cleanup functions are working

**Flaky tests**:
- Check for race conditions in parallel execution
- Verify test isolation and cleanup
- Use deterministic test data

**Performance issues**:
- Reduce parallel job count: `TEST_PARALLEL_JOBS=2`
- Check for resource leaks in mock environments
- Profile slow tests with performance tracking

### Getting Help

1. **Enable verbose mode**: `--verbose` flag for detailed output
2. **Check logs**: Review structured logs in debug mode
3. **Use debugging utilities**: Add breakpoints and variable inspection
4. **Run single tests**: Isolate problematic tests for debugging

## Integration with CI/CD

### GitHub Actions Example

```yaml
- name: Run Tests
  run: |
    export CI_MODE=true
    export TEST_DEFAULT_FORMAT=json
    ./tests/run-tests.sh --suite all
    
- name: Upload Test Reports
  uses: actions/upload-artifact@v3
  with:
    name: test-reports
    path: test-reports/
```

### Test Coverage

The system provides comprehensive coverage tracking:

- **Function Coverage**: Which functions are tested
- **Branch Coverage**: Which code paths are executed
- **Integration Coverage**: Which component interactions are tested

## Migration from Old System

If migrating from the old testing approach:

1. **Review existing tests**: Identify what needs to be preserved
2. **Use migration utilities**: Available in `tests/lib/`
3. **Update test scripts**: Convert to new assertion system
4. **Verify coverage**: Ensure no functionality is lost

See the [Migration Guide](MIGRATION.md) for detailed steps.