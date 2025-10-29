# Debugging and Troubleshooting Guide

## Overview

This guide provides comprehensive debugging and troubleshooting information for the WordPress Init testing system. It covers common issues, debugging techniques, and tools available for diagnosing problems.

## Quick Debugging Checklist

When a test fails, follow this checklist:

1. **Run with verbose output**: `./tests/run-tests.sh --verbose`
2. **Check the specific test**: Run only the failing test
3. **Examine mock environment**: Verify mock setup is correct
4. **Check dependencies**: Ensure all required tools are mocked
5. **Review logs**: Check structured logs for detailed information
6. **Use debug utilities**: Add breakpoints and variable inspection

## Debugging Tools

### Verbose Mode

Enable detailed output to see what's happening during test execution:

```bash
# Command line flag
./tests/run-tests.sh --verbose

# Environment variable
export TEST_VERBOSE=true
./tests/run-tests.sh

# In individual test files
export TEST_VERBOSE=true
```

**Verbose output includes**:
- Detailed assertion results
- Mock environment creation/cleanup
- Command execution traces
- Variable values at key points
- Timing information

### Debug Utilities

The debugging system provides interactive debugging capabilities:

```bash
# Source debugging utilities in your test
source "$TEST_LIB_DIR/debugger.sh"

# Enable debug mode
enable_debug_mode

# Add breakpoints
debug_breakpoint "Before validation check"
debug_breakpoint "After file generation" "$variable_to_inspect"

# Inspect variables
debug_inspect_var "result" "$result"
debug_inspect_array "components" "${components[@]}"
debug_inspect_env "PATH"

# Conditional debugging
if [ "$TEST_DEBUG" = "true" ]; then
    debug_breakpoint "Only shown in debug mode"
fi
```

**Debug breakpoint features**:
- Pause execution for inspection
- Display current variable values
- Show call stack
- Allow interactive shell access

### Structured Logging

The logging system provides detailed execution traces:

```bash
# Source logger in your test
source "$TEST_LIB_DIR/logger.sh"

# Set log level
export LOG_LEVEL="DEBUG"  # DEBUG, INFO, WARN, ERROR, CRITICAL

# Log at different levels
log_debug "Detailed debugging information"
log_info "General information about test progress"
log_warn "Warning conditions that might cause issues"
log_error "Error conditions that need attention"
log_critical "Critical failures that stop execution"

# Structured logging with context
log_with_context "validation" "INFO" "Starting validation process" \
    "mode=$mode" "components=${components[*]}"
```

**Log output formats**:
- **Console**: Colorized output for human reading
- **JSON**: Structured data for machine processing
- **File**: Persistent logs for later analysis

### Performance Profiling

Track performance to identify slow tests or bottlenecks:

```bash
# Enable performance tracking
export TEST_PERFORMANCE_TRACKING=true

# Run with timing information
./tests/run-tests.sh --timing

# Profile specific operations
source "$TEST_LIB_DIR/performance-tracker.sh"

start_performance_timer "validation_phase"
# ... code to profile ...
end_performance_timer "validation_phase"

# Get timing results
get_performance_stats "validation_phase"
```

## Common Issues and Solutions

### Test Execution Issues

#### Tests Hanging or Timing Out

**Symptoms**:
- Tests never complete
- Process appears stuck
- Timeout errors

**Causes and Solutions**:

1. **Infinite loops in test code**:
```bash
# Debug: Add breakpoints to identify where hanging occurs
debug_breakpoint "Before potentially hanging operation"

# Solution: Review loop conditions and exit criteria
while [ "$condition" = "true" ]; do
    # Ensure condition can become false
    if [ "$counter" -gt 100 ]; then
        break  # Safety exit
    fi
    ((counter++))
done
```

2. **Blocking operations**:
```bash
# Problem: Waiting for user input in non-interactive mode
read -p "Enter value: " value

# Solution: Use mock input or environment variables
if [ -n "${TEST_INPUT:-}" ]; then
    value="$TEST_INPUT"
else
    read -p "Enter value: " value
fi
```

3. **External command hanging**:
```bash
# Problem: External command waiting for input
some_external_command

# Solution: Mock the command or provide input
mock_tool "some_external_command" "success"
# or
echo "input" | some_external_command
```

#### Permission Errors

**Symptoms**:
- "Permission denied" errors
- Cannot create/modify files
- Directory access failures

**Causes and Solutions**:

1. **Mock environment permissions**:
```bash
# Debug: Check permissions
ls -la "$mock_env"

# Solution: Ensure proper permissions in mock setup
create_mock_env() {
    local env_path="$1"
    mkdir -p "$env_path"
    chmod 755 "$env_path"  # Ensure writable
}
```

2. **System directory access**:
```bash
# Problem: Trying to write to system directories
echo "test" > /etc/test.conf

# Solution: Use mock environment
local mock_env=$(create_mock_env "test")
echo "test" > "$mock_env/test.conf"
```

#### Mock Environment Issues

**Symptoms**:
- Mock environments not cleaned up
- Tests interfering with each other
- Disk space issues

**Debugging mock environments**:
```bash
# Check mock environment contents
debug_inspect_directory "$mock_env"

# Verify cleanup
ls -la /tmp/test_mock_*  # Should be empty after tests

# Manual cleanup if needed
cleanup_all_mock_envs
```

**Solutions**:

1. **Ensure cleanup in all exit paths**:
```bash
test_function() {
    local mock_env=$(create_mock_env "test")
    
    # Use trap to ensure cleanup on any exit
    trap "cleanup_mock_env '$mock_env'" EXIT
    
    # Test code here...
    
    # Explicit cleanup (trap will also run)
    cleanup_mock_env "$mock_env"
}
```

2. **Use unique mock environment names**:
```bash
# Problem: Tests using same mock name
local mock_env=$(create_mock_env "test")

# Solution: Use unique names
local mock_env=$(create_mock_env "test_${FUNCNAME[0]}_$$")
```

### Assertion Failures

#### Unexpected Values

**Debugging assertion failures**:
```bash
# Enable verbose assertions
export ASSERT_VERBOSE=true

# Add debug output before assertions
debug_inspect_var "expected" "$expected"
debug_inspect_var "actual" "$actual"
assert_equals "$expected" "$actual" "description"

# Use assertion with detailed comparison
assert_equals_verbose "$expected" "$actual" "description"
```

**Common causes**:

1. **Whitespace differences**:
```bash
# Problem: Extra whitespace in output
expected="value"
actual="value "  # Trailing space

# Solution: Trim whitespace
actual=$(echo "$actual" | xargs)  # Trim whitespace
assert_equals "$expected" "$actual" "description"
```

2. **Path differences**:
```bash
# Problem: Absolute vs relative paths
expected="./file.txt"
actual="/full/path/to/file.txt"

# Solution: Normalize paths
expected=$(realpath "$expected")
actual=$(realpath "$actual")
assert_equals "$expected" "$actual" "description"
```

3. **Case sensitivity**:
```bash
# Problem: Case differences
expected="Value"
actual="value"

# Solution: Use case-insensitive comparison
assert_equals_case_insensitive "$expected" "$actual" "description"
```

#### File Assertion Issues

**Debugging file assertions**:
```bash
# Check if file exists
if [ ! -f "$file_path" ]; then
    debug_inspect_directory "$(dirname "$file_path")"
    log_error "File not found: $file_path"
fi

# Check file contents
debug_inspect_file "$file_path"
assert_file_contains "$file_path" "expected_content" "description"
```

**Common issues**:

1. **File not created**:
```bash
# Debug: Check if directory exists
assert_directory_exists "$(dirname "$file_path")" "Parent directory should exist"

# Debug: Check file creation process
log_debug "Creating file: $file_path"
create_file "$file_path"
log_debug "File created successfully"
```

2. **Content not matching**:
```bash
# Debug: Show actual file contents
log_debug "File contents:"
cat "$file_path" | while read -r line; do
    log_debug "  $line"
done

# Use partial matching if needed
assert_file_contains "$file_path" "partial_content" "description"
```

### Performance Issues

#### Slow Test Execution

**Identifying slow tests**:
```bash
# Run with timing
./tests/run-tests.sh --timing

# Profile specific tests
export TEST_PERFORMANCE_TRACKING=true
./tests/run-tests.sh --suite unit --pattern "*slow*"

# Check performance trends
./tests/lib/trend-analyzer.sh --show-trends
```

**Common causes and solutions**:

1. **Excessive file I/O**:
```bash
# Problem: Creating many files
for i in {1..1000}; do
    echo "content" > "file_$i.txt"
done

# Solution: Use in-memory operations or reduce iterations
for i in {1..10}; do  # Reduce iterations
    echo "content" > "file_$i.txt"
done
```

2. **External command overhead**:
```bash
# Problem: Calling external commands repeatedly
for file in *.txt; do
    jq '.key' "$file"
done

# Solution: Batch operations or use mocks
mock_tool "jq" "success"
for file in *.txt; do
    jq '.key' "$file"  # Now uses mock
done
```

3. **Large mock environments**:
```bash
# Problem: Creating large WordPress structures
create_mock_wordpress "all_components" "full_structure"

# Solution: Create minimal required structure
create_mock_wordpress "plugins" "wp-content"  # Only what's needed
```

#### Memory Usage Issues

**Monitoring memory usage**:
```bash
# Enable memory tracking
export TEST_MEMORY_TRACKING=true

# Check memory usage during tests
source "$TEST_LIB_DIR/performance-tracker.sh"
track_memory_usage "test_phase"
```

**Solutions**:
1. **Clean up variables**: Unset large arrays and variables
2. **Limit mock environment size**: Create only necessary files
3. **Use streaming**: Process large files line by line instead of loading entirely

### Mock Tool Issues

#### Tool Not Found Errors

**Debugging mock tools**:
```bash
# Check if tool is properly mocked
which jq  # Should point to mock version

# Verify mock tool behavior
mock_tool "jq" "success"
jq --version  # Should work without error

# Debug mock tool setup
debug_inspect_var "PATH" "$PATH"
ls -la "$MOCK_TOOLS_DIR"
```

**Solutions**:

1. **Ensure mock is created before use**:
```bash
# Wrong order
some_function_using_jq
mock_tool "jq" "success"

# Correct order
mock_tool "jq" "success"
some_function_using_jq
```

2. **Check mock tool permissions**:
```bash
# Ensure mock tools are executable
chmod +x "$MOCK_TOOLS_DIR/jq"
```

#### Mock Tool Behavior Issues

**Testing mock behavior**:
```bash
# Test different mock behaviors
mock_tool "jq" "success"
assert_command_succeeds "jq --version" "jq mock should succeed"

mock_tool "jq" "failure"
assert_command_fails "jq --version" "jq mock should fail"

mock_tool "jq" "not_found"
assert_command_fails "which jq" "jq should not be found"
```

## Advanced Debugging Techniques

### Interactive Debugging

Start an interactive shell during test execution:

```bash
# Add interactive breakpoint
debug_interactive_shell "Investigate issue here"

# This will:
# 1. Pause test execution
# 2. Show current context
# 3. Start interactive bash shell
# 4. Resume test when you exit shell
```

### Test Isolation Debugging

Identify tests that interfere with each other:

```bash
# Run tests individually
./tests/run-tests.sh --suite unit --pattern "test_specific_function"

# Run in different orders
./tests/run-tests.sh --shuffle

# Check for shared state
debug_inspect_globals_before_test
run_test "test_function"
debug_inspect_globals_after_test
```

### Mock Environment Inspection

Deep dive into mock environment issues:

```bash
# Create persistent mock environment for inspection
export MOCK_PERSIST=true
local mock_env=$(create_mock_env "debug_env")

# Inspect mock environment
debug_inspect_mock_env "$mock_env"

# Manual inspection
cd "$mock_env"
find . -type f -exec ls -la {} \;
```

### Log Analysis

Analyze structured logs for patterns:

```bash
# Generate JSON logs
export TEST_DEFAULT_FORMAT=json
./tests/run-tests.sh > test_results.json

# Analyze logs
jq '.tests[] | select(.status == "FAIL")' test_results.json
jq '.tests[] | select(.duration > 5)' test_results.json  # Slow tests
```

## Debugging Specific Components

### Validation Engine Debugging

```bash
# Enable validation debugging
export VALIDATION_DEBUG=true

# Test specific validations
source "$TEST_LIB_DIR/validation-engine.sh"
validate_wordpress_structure
echo "Validation result: $?"

# Check validation context
debug_inspect_validation_context
```

### Recovery System Debugging

```bash
# Enable recovery debugging
export RECOVERY_DEBUG=true

# Test recovery operations
source "$TEST_LIB_DIR/recovery-manager.sh"
recovery_id=$(create_recovery_point "test_operation" "file1 file2")
debug_inspect_recovery_point "$recovery_id"
```

### Reporter Debugging

```bash
# Test different report formats
source "$TEST_LIB_DIR/reporters.sh"

generate_console_report "$test_results"
generate_json_report "$test_results" "debug_report.json"
generate_html_report "$test_results" "debug_report.html"
```

## Performance Debugging

### Profiling Test Execution

```bash
# Enable detailed profiling
export TEST_DETAILED_PROFILING=true

# Profile specific operations
profile_operation "file_generation" "generate_all_files"
profile_operation "validation" "validate_all_components"

# Analyze profiling results
./tests/lib/performance-tracker.sh --analyze-profile
```

### Memory Profiling

```bash
# Track memory usage
export TEST_MEMORY_PROFILING=true

# Monitor memory during test
start_memory_monitor "test_name"
# ... test operations ...
stop_memory_monitor "test_name"

# Check for memory leaks
check_memory_leaks
```

## Continuous Integration Debugging

### CI-Specific Issues

```bash
# Enable CI debugging mode
export CI_DEBUG=true

# Simulate CI environment locally
export CI_MODE=true
export TEST_PARALLEL_JOBS=2  # Reduce for CI
./tests/run-tests.sh
```

### Artifact Collection

```bash
# Generate debug artifacts for CI
export TEST_GENERATE_ARTIFACTS=true
./tests/run-tests.sh

# Artifacts generated:
# - test-reports/debug-logs.json
# - test-reports/performance-data.json
# - test-reports/mock-env-snapshots/
```

## Getting Help

### Self-Diagnosis

1. **Check system requirements**: Ensure bash version and dependencies
2. **Verify test environment**: Run system validation tests
3. **Review recent changes**: Check git history for related changes
4. **Compare with working tests**: Look at similar working tests

### Reporting Issues

When reporting issues, include:

1. **Test command used**: Exact command that failed
2. **Environment details**: OS, bash version, relevant environment variables
3. **Error output**: Complete error messages and stack traces
4. **Reproduction steps**: Minimal steps to reproduce the issue
5. **Debug output**: Results from verbose mode and debug utilities

### Debug Information Collection

Use this script to collect comprehensive debug information:

```bash
#!/bin/bash
# collect-debug-info.sh

echo "=== System Information ==="
uname -a
bash --version
echo "PWD: $PWD"

echo "=== Environment Variables ==="
env | grep TEST_ | sort

echo "=== Test Directory Structure ==="
find tests/ -type f -name "*.sh" | head -20

echo "=== Recent Test Results ==="
if [ -f "test-reports/latest.json" ]; then
    jq '.summary' test-reports/latest.json
fi

echo "=== Mock Environment Status ==="
ls -la /tmp/test_mock_* 2>/dev/null || echo "No mock environments found"

echo "=== Performance Data ==="
if [ -f "test-reports/performance.json" ]; then
    jq '.slow_tests' test-reports/performance.json
fi
```

Run this script and include the output when seeking help.

## Best Practices for Debugging

1. **Start simple**: Begin with the most basic test case
2. **Use verbose mode**: Always run with `--verbose` when debugging
3. **Isolate the problem**: Run only the failing test
4. **Check assumptions**: Verify that your assumptions about the system are correct
5. **Use version control**: Compare with known working versions
6. **Document solutions**: Add comments explaining fixes for future reference
7. **Test the fix**: Ensure your fix doesn't break other tests
8. **Share knowledge**: Update this guide with new debugging techniques