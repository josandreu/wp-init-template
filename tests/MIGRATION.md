# Migration Guide: Transitioning to the New Testing System

## Overview

This guide helps developers migrate from the old testing approach to the new comprehensive testing system. It covers the differences between systems, migration steps, and how to update existing tests.

## System Comparison

### Old System vs New System

| Aspect | Old System | New System |
|--------|------------|------------|
| **Structure** | Scripts in project root | Organized `/tests` directory |
| **Execution** | Individual script execution | Unified test runner |
| **Environment** | Real system modifications | Isolated mock environments |
| **Assertions** | Basic exit code checks | Comprehensive assertion library |
| **Reporting** | Simple console output | Multiple formats (JSON, HTML, console) |
| **Parallelization** | Sequential execution | Parallel test execution |
| **Error Handling** | Basic error detection | Categorized error handling with recovery |
| **Debugging** | Limited debugging tools | Advanced debugging utilities |

### File Mapping

| Old Location | New Location | Purpose |
|--------------|--------------|---------|
| `simple-workflow-test.sh` | `tests/integration/simple-workflow-test.sh` | Integration testing |
| `test-file-generation.sh` | `tests/integration/test-file-generation.sh` | File generation testing |
| `test-workflows.sh` | `tests/integration/test-workflows.sh` | Workflow testing |
| `validate-files.sh` | `tests/unit/validate-files.sh` | File validation testing |
| (new) | `tests/run-tests.sh` | Main test runner |
| (new) | `tests/lib/` | Testing libraries |

## Migration Steps

### Step 1: Understand the New Structure

First, familiarize yourself with the new testing structure:

```bash
# Explore the new structure
ls -la tests/
ls -la tests/lib/
ls -la tests/unit/
ls -la tests/integration/
ls -la tests/e2e/

# Read the documentation
cat tests/README.md
cat tests/DEVELOPER_GUIDE.md
```

### Step 2: Run the New System

Test the new system to understand its capabilities:

```bash
# Run all tests
./tests/run-tests.sh

# Run specific suites
./tests/run-tests.sh --suite unit
./tests/run-tests.sh --suite integration

# Try different options
./tests/run-tests.sh --verbose --parallel 2
```

### Step 3: Analyze Existing Tests

Review your existing tests to understand what needs to be migrated:

```bash
# List old test files (if any remain in root)
find . -maxdepth 1 -name "*test*.sh" -type f

# Analyze test content
for file in *test*.sh; do
    echo "=== $file ==="
    grep -n "function\|test_\|assert\|if.*then" "$file" | head -10
done
```

### Step 4: Migrate Tests by Category

#### Migrating Unit Tests

**Old style unit test**:
```bash
#!/bin/bash
# old-validation-test.sh

test_validation() {
    # Basic validation test
    if validate_function "input"; then
        echo "PASS: Validation succeeded"
        return 0
    else
        echo "FAIL: Validation failed"
        return 1
    fi
}

test_validation
```

**New style unit test**:
```bash
#!/bin/bash
# tests/unit/validation/test_validation_engine.sh

source "$(dirname "$0")/../../lib/test-runner.sh"
source "$(dirname "$0")/../../lib/assertions.sh"
source "$(dirname "$0")/../../lib/validation-engine.sh"

test_validation_basic_functionality() {
    local description="Validation should succeed with valid input"
    
    # Arrange
    local input="valid_input"
    
    # Act
    local result
    result=$(validate_function "$input")
    local exit_code=$?
    
    # Assert
    assert_equals 0 "$exit_code" "$description - exit code"
    assert_contains "$result" "success" "$description - result message"
}

test_validation_error_handling() {
    local description="Validation should fail with invalid input"
    
    # Arrange
    local invalid_input=""
    
    # Act & Assert
    assert_command_fails "validate_function '$invalid_input'" "$description"
}

# Run tests
run_test "test_validation_basic_functionality"
run_test "test_validation_error_handling"
```

#### Migrating Integration Tests

**Old style integration test**:
```bash
#!/bin/bash
# old-workflow-test.sh

echo "Testing complete workflow..."

# Setup
mkdir -p test_project/wp-content/plugins
cd test_project

# Run main script
../init-project.sh

# Check results
if [ -f "composer.json" ]; then
    echo "PASS: composer.json created"
else
    echo "FAIL: composer.json not created"
    exit 1
fi

# Cleanup
cd ..
rm -rf test_project
```

**New style integration test**:
```bash
#!/bin/bash
# tests/integration/workflows/test_complete_workflow.sh

source "$(dirname "$0")/../../lib/test-runner.sh"
source "$(dirname "$0")/../../lib/assertions.sh"
source "$(dirname "$0")/../../lib/mock-env.sh"

test_complete_workflow_mode_1() {
    local description="Complete workflow should work for mode 1"
    
    # Arrange
    local mock_env=$(create_mock_env "workflow_test")
    create_mock_wordpress "plugins,themes" "wp-content" "$mock_env"
    mock_tool "composer" "success"
    
    # Create configuration
    cat > "$mock_env/.project-config" << EOF
MODE=1
COMPONENTS=("plugins" "themes")
FORMAT_CODE=true
EOF
    
    # Act
    cd "$mock_env"
    local result
    result=$(bash "$PROJECT_ROOT/init-project.sh" 2>&1)
    local exit_code=$?
    
    # Assert
    assert_equals 0 "$exit_code" "$description - script succeeded"
    assert_file_exists "$mock_env/composer.json" "$description - composer.json created"
    assert_file_contains "$mock_env/composer.json" "wp-coding-standards" "$description - correct content"
    
    # Cleanup
    cleanup_mock_env "$mock_env"
}

run_test "test_complete_workflow_mode_1"
```

### Step 5: Update Test Patterns

#### Replace Basic Checks with Assertions

**Old pattern**:
```bash
if [ -f "expected_file.txt" ]; then
    echo "PASS: File exists"
else
    echo "FAIL: File does not exist"
    exit 1
fi
```

**New pattern**:
```bash
assert_file_exists "expected_file.txt" "File should be created"
```

#### Replace Manual Environment Setup with Mocks

**Old pattern**:
```bash
# Create test directory
mkdir -p test_env/wp-content/plugins
cd test_env

# ... run tests ...

# Manual cleanup
cd ..
rm -rf test_env
```

**New pattern**:
```bash
# Create mock environment
local mock_env=$(create_mock_env "test_name")
create_mock_wordpress "plugins" "wp-content" "$mock_env"

cd "$mock_env"
# ... run tests ...

# Automatic cleanup
cleanup_mock_env "$mock_env"
```

#### Replace External Tool Dependencies with Mocks

**Old pattern**:
```bash
# Requires jq to be installed
if ! command -v jq >/dev/null; then
    echo "SKIP: jq not available"
    exit 0
fi

result=$(echo '{"key":"value"}' | jq -r '.key')
```

**New pattern**:
```bash
# Mock jq for consistent testing
mock_tool "jq" "success"

# Test with mocked jq
result=$(echo '{"key":"value"}' | jq -r '.key')
assert_equals "value" "$result" "jq should extract value"
```

## Common Migration Patterns

### Pattern 1: Converting Simple Function Tests

**Before**:
```bash
test_my_function() {
    local result=$(my_function "input")
    if [ "$result" = "expected" ]; then
        echo "PASS"
    else
        echo "FAIL: Expected 'expected', got '$result'"
        return 1
    fi
}
```

**After**:
```bash
test_my_function() {
    local description="Function should return expected output"
    local result=$(my_function "input")
    assert_equals "expected" "$result" "$description"
}
```

### Pattern 2: Converting File Operation Tests

**Before**:
```bash
test_file_creation() {
    create_file "test.txt" "content"
    
    if [ ! -f "test.txt" ]; then
        echo "FAIL: File not created"
        return 1
    fi
    
    if ! grep -q "content" "test.txt"; then
        echo "FAIL: File content incorrect"
        return 1
    fi
    
    rm -f "test.txt"
    echo "PASS"
}
```

**After**:
```bash
test_file_creation() {
    local description="Should create file with correct content"
    local mock_env=$(create_mock_env "file_test")
    
    cd "$mock_env"
    create_file "test.txt" "content"
    
    assert_file_exists "test.txt" "$description - file created"
    assert_file_contains "test.txt" "content" "$description - correct content"
    
    cleanup_mock_env "$mock_env"
}
```

### Pattern 3: Converting Command Tests

**Before**:
```bash
test_command_execution() {
    if my_command arg1 arg2; then
        echo "PASS: Command succeeded"
    else
        echo "FAIL: Command failed"
        return 1
    fi
}
```

**After**:
```bash
test_command_execution() {
    local description="Command should execute successfully"
    assert_command_succeeds "my_command arg1 arg2" "$description"
}
```

### Pattern 4: Converting Error Tests

**Before**:
```bash
test_error_handling() {
    if my_function "invalid_input" 2>/dev/null; then
        echo "FAIL: Should have failed with invalid input"
        return 1
    else
        echo "PASS: Correctly failed with invalid input"
    fi
}
```

**After**:
```bash
test_error_handling() {
    local description="Should fail with invalid input"
    assert_command_fails "my_function 'invalid_input'" "$description"
}
```

## Updating Test Execution

### Old Execution Method

```bash
# Run individual test scripts
./simple-workflow-test.sh
./test-file-generation.sh
./validate-files.sh

# Manual result aggregation
echo "All tests completed"
```

### New Execution Method

```bash
# Run all tests with unified runner
./tests/run-tests.sh

# Run specific test categories
./tests/run-tests.sh --suite unit
./tests/run-tests.sh --suite integration

# Run with specific options
./tests/run-tests.sh --verbose --parallel 4 --format json
```

## Updating CI/CD Integration

### Old CI Configuration

```yaml
# Old approach - run individual scripts
- name: Run Tests
  run: |
    ./simple-workflow-test.sh
    ./test-file-generation.sh
    ./validate-files.sh
```

### New CI Configuration

```yaml
# New approach - unified test runner
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

## Migration Checklist

### Pre-Migration

- [ ] Backup existing test files
- [ ] Document current test coverage
- [ ] Identify test dependencies
- [ ] Review test execution workflow

### During Migration

- [ ] Create new test structure
- [ ] Migrate unit tests first
- [ ] Convert integration tests
- [ ] Add end-to-end tests
- [ ] Update CI/CD configuration
- [ ] Test new system thoroughly

### Post-Migration

- [ ] Remove old test files
- [ ] Update documentation
- [ ] Train team on new system
- [ ] Monitor test performance
- [ ] Gather feedback and iterate

## Troubleshooting Migration Issues

### Common Migration Problems

#### Tests Not Found

**Problem**: Tests don't run after migration
```bash
./tests/run-tests.sh
# No tests found
```

**Solution**: Check file naming and permissions
```bash
# Ensure test files are executable
chmod +x tests/unit/test_*.sh
chmod +x tests/integration/test_*.sh

# Check naming convention
ls tests/unit/test_*.sh
ls tests/integration/test_*.sh
```

#### Mock Environment Issues

**Problem**: Tests fail due to environment differences
```bash
# Error: /path/not/found
```

**Solution**: Update paths to use mock environments
```bash
# Old: Hardcoded paths
cd /some/absolute/path

# New: Use mock environment
local mock_env=$(create_mock_env "test")
cd "$mock_env"
```

#### Assertion Failures

**Problem**: Tests fail with new assertion system
```bash
# Expected 'value', got 'value '
```

**Solution**: Handle whitespace and formatting differences
```bash
# Trim whitespace
result=$(echo "$result" | xargs)
assert_equals "expected" "$result" "description"

# Or use contains for partial matches
assert_contains "$result" "expected_part" "description"
```

### Getting Help During Migration

1. **Review examples**: Look at migrated tests in the new system
2. **Use verbose mode**: Run with `--verbose` to see detailed output
3. **Check documentation**: Refer to README.md and DEVELOPER_GUIDE.md
4. **Start small**: Migrate simple tests first
5. **Ask for help**: Reach out to team members familiar with the new system

## Best Practices for Migration

### Incremental Migration

1. **Start with unit tests**: They're usually easier to migrate
2. **One test at a time**: Don't try to migrate everything at once
3. **Test as you go**: Verify each migrated test works before moving on
4. **Keep old tests**: Don't delete old tests until new ones are verified

### Quality Assurance

1. **Maintain test coverage**: Ensure no functionality is lost
2. **Improve tests**: Use migration as opportunity to improve test quality
3. **Add missing tests**: Identify and add tests for uncovered functionality
4. **Document changes**: Keep track of what was changed and why

### Team Coordination

1. **Communicate changes**: Keep team informed about migration progress
2. **Provide training**: Help team members understand new system
3. **Update processes**: Update development workflows and documentation
4. **Gather feedback**: Collect feedback and make improvements

## Post-Migration Benefits

After successful migration, you'll have:

- **Better test organization**: Clear structure and categorization
- **Improved reliability**: Isolated test environments prevent interference
- **Enhanced debugging**: Advanced debugging tools and verbose output
- **Better reporting**: Multiple output formats and detailed metrics
- **Faster execution**: Parallel test execution and performance optimization
- **Easier maintenance**: Modular design and comprehensive documentation

## Conclusion

Migrating to the new testing system requires effort but provides significant benefits in terms of reliability, maintainability, and developer experience. Follow this guide step by step, and don't hesitate to ask for help when needed.

The new system is designed to be more robust and developer-friendly while maintaining compatibility with existing functionality. Take advantage of the migration process to improve test coverage and quality.