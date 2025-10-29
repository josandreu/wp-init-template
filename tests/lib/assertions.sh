#!/bin/bash

# Comprehensive Assertion Functions for Testing
# Provides a wide range of assertion functions for test validation

# Global test state
declare -i ASSERTION_COUNT=0
declare -i ASSERTION_FAILURES=0
declare -a ASSERTION_MESSAGES=()

# Colors for output
readonly ASSERT_RED='\033[0;31m'
readonly ASSERT_GREEN='\033[0;32m'
readonly ASSERT_YELLOW='\033[1;33m'
readonly ASSERT_NC='\033[0m' # No Color

# Print assertion result
print_assertion() {
    local status="$1"
    local message="$2"
    local details="${3:-}"
    
    ((ASSERTION_COUNT++))
    
    if [ "$status" = "PASS" ]; then
        printf "${ASSERT_GREEN}✓${ASSERT_NC} %s\n" "$message"
    else
        printf "${ASSERT_RED}✗${ASSERT_NC} %s\n" "$message"
        if [ -n "$details" ]; then
            printf "  ${ASSERT_YELLOW}Details:${ASSERT_NC} %s\n" "$details"
        fi
        ((ASSERTION_FAILURES++))
        ASSERTION_MESSAGES+=("$message: $details")
    fi
}

# Basic equality assertions
assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-"Expected '$expected', got '$actual'"}"
    
    if [ "$expected" = "$actual" ]; then
        print_assertion "PASS" "$message"
        return 0
    else
        print_assertion "FAIL" "$message" "Expected: '$expected', Actual: '$actual'"
        return 1
    fi
}

assert_not_equals() {
    local not_expected="$1"
    local actual="$2"
    local message="${3:-"Expected not '$not_expected', but got '$actual'"}"
    
    if [ "$not_expected" != "$actual" ]; then
        print_assertion "PASS" "$message"
        return 0
    else
        print_assertion "FAIL" "$message" "Should not equal: '$not_expected'"
        return 1
    fi
}

# Numeric assertions
assert_greater_than() {
    local threshold="$1"
    local actual="$2"
    local message="${3:-"Expected $actual > $threshold"}"
    
    if (( $(echo "$actual > $threshold" | bc -l) )); then
        print_assertion "PASS" "$message"
        return 0
    else
        print_assertion "FAIL" "$message" "Expected: > $threshold, Actual: $actual"
        return 1
    fi
}

assert_less_than() {
    local threshold="$1"
    local actual="$2"
    local message="${3:-"Expected $actual < $threshold"}"
    
    if (( $(echo "$actual < $threshold" | bc -l) )); then
        print_assertion "PASS" "$message"
        return 0
    else
        print_assertion "FAIL" "$message" "Expected: < $threshold, Actual: $actual"
        return 1
    fi
}

assert_greater_or_equal() {
    local threshold="$1"
    local actual="$2"
    local message="${3:-"Expected $actual >= $threshold"}"
    
    if (( $(echo "$actual >= $threshold" | bc -l) )); then
        print_assertion "PASS" "$message"
        return 0
    else
        print_assertion "FAIL" "$message" "Expected: >= $threshold, Actual: $actual"
        return 1
    fi
}

# String assertions
assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-"Expected '$haystack' to contain '$needle'"}"
    
    if [[ "$haystack" == *"$needle"* ]]; then
        print_assertion "PASS" "$message"
        return 0
    else
        print_assertion "FAIL" "$message" "String '$haystack' does not contain '$needle'"
        return 1
    fi
}

assert_not_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-"Expected '$haystack' to not contain '$needle'"}"
    
    if [[ "$haystack" != *"$needle"* ]]; then
        print_assertion "PASS" "$message"
        return 0
    else
        print_assertion "FAIL" "$message" "String '$haystack' contains '$needle'"
        return 1
    fi
}

assert_starts_with() {
    local string="$1"
    local prefix="$2"
    local message="${3:-"Expected '$string' to start with '$prefix'"}"
    
    if [[ "$string" == "$prefix"* ]]; then
        print_assertion "PASS" "$message"
        return 0
    else
        print_assertion "FAIL" "$message" "String '$string' does not start with '$prefix'"
        return 1
    fi
}

assert_ends_with() {
    local string="$1"
    local suffix="$2"
    local message="${3:-"Expected '$string' to end with '$suffix'"}"
    
    if [[ "$string" == *"$suffix" ]]; then
        print_assertion "PASS" "$message"
        return 0
    else
        print_assertion "FAIL" "$message" "String '$string' does not end with '$suffix'"
        return 1
    fi
}

assert_matches_regex() {
    local string="$1"
    local pattern="$2"
    local message="${3:-"Expected '$string' to match pattern '$pattern'"}"
    
    if [[ "$string" =~ $pattern ]]; then
        print_assertion "PASS" "$message"
        return 0
    else
        print_assertion "FAIL" "$message" "String '$string' does not match pattern '$pattern'"
        return 1
    fi
}

# Boolean assertions
assert_true() {
    local condition="$1"
    local message="${2:-"Expected condition to be true"}"
    
    if [ "$condition" = "true" ] || [ "$condition" = "0" ] || [ -n "$condition" ]; then
        print_assertion "PASS" "$message"
        return 0
    else
        print_assertion "FAIL" "$message" "Condition evaluated to false: '$condition'"
        return 1
    fi
}

assert_false() {
    local condition="$1"
    local message="${2:-"Expected condition to be false"}"
    
    if [ "$condition" = "false" ] || [ "$condition" = "1" ] || [ -z "$condition" ]; then
        print_assertion "PASS" "$message"
        return 0
    else
        print_assertion "FAIL" "$message" "Condition evaluated to true: '$condition'"
        return 1
    fi
}

# File system assertions
assert_file_exists() {
    local file_path="$1"
    local message="${2:-"Expected file to exist: $file_path"}"
    
    if [ -f "$file_path" ]; then
        print_assertion "PASS" "$message"
        return 0
    else
        print_assertion "FAIL" "$message" "File does not exist: $file_path"
        return 1
    fi
}

assert_file_not_exists() {
    local file_path="$1"
    local message="${2:-"Expected file to not exist: $file_path"}"
    
    if [ ! -f "$file_path" ]; then
        print_assertion "PASS" "$message"
        return 0
    else
        print_assertion "FAIL" "$message" "File exists: $file_path"
        return 1
    fi
}

assert_directory_exists() {
    local dir_path="$1"
    local message="${2:-"Expected directory to exist: $dir_path"}"
    
    if [ -d "$dir_path" ]; then
        print_assertion "PASS" "$message"
        return 0
    else
        print_assertion "FAIL" "$message" "Directory does not exist: $dir_path"
        return 1
    fi
}

assert_directory_not_exists() {
    local dir_path="$1"
    local message="${2:-"Expected directory to not exist: $dir_path"}"
    
    if [ ! -d "$dir_path" ]; then
        print_assertion "PASS" "$message"
        return 0
    else
        print_assertion "FAIL" "$message" "Directory exists: $dir_path"
        return 1
    fi
}

assert_file_contains() {
    local file_path="$1"
    local expected_content="$2"
    local message="${3:-"Expected file to contain content"}"
    
    if [ ! -f "$file_path" ]; then
        print_assertion "FAIL" "$message" "File does not exist: $file_path"
        return 1
    fi
    
    if grep -q "$expected_content" "$file_path"; then
        print_assertion "PASS" "$message"
        return 0
    else
        print_assertion "FAIL" "$message" "File '$file_path' does not contain '$expected_content'"
        return 1
    fi
}

assert_file_not_contains() {
    local file_path="$1"
    local unexpected_content="$2"
    local message="${3:-"Expected file to not contain content"}"
    
    if [ ! -f "$file_path" ]; then
        print_assertion "FAIL" "$message" "File does not exist: $file_path"
        return 1
    fi
    
    if ! grep -q "$unexpected_content" "$file_path"; then
        print_assertion "PASS" "$message"
        return 0
    else
        print_assertion "FAIL" "$message" "File '$file_path' contains '$unexpected_content'"
        return 1
    fi
}

assert_file_empty() {
    local file_path="$1"
    local message="${2:-"Expected file to be empty: $file_path"}"
    
    if [ ! -f "$file_path" ]; then
        print_assertion "FAIL" "$message" "File does not exist: $file_path"
        return 1
    fi
    
    if [ ! -s "$file_path" ]; then
        print_assertion "PASS" "$message"
        return 0
    else
        print_assertion "FAIL" "$message" "File is not empty: $file_path"
        return 1
    fi
}

assert_file_not_empty() {
    local file_path="$1"
    local message="${2:-"Expected file to not be empty: $file_path"}"
    
    if [ ! -f "$file_path" ]; then
        print_assertion "FAIL" "$message" "File does not exist: $file_path"
        return 1
    fi
    
    if [ -s "$file_path" ]; then
        print_assertion "PASS" "$message"
        return 0
    else
        print_assertion "FAIL" "$message" "File is empty: $file_path"
        return 1
    fi
}

# Command execution assertions
assert_command_success() {
    local command="$1"
    local message="${2:-"Expected command to succeed: $command"}"
    
    if eval "$command" >/dev/null 2>&1; then
        print_assertion "PASS" "$message"
        return 0
    else
        local exit_code=$?
        print_assertion "FAIL" "$message" "Command failed with exit code: $exit_code"
        return 1
    fi
}

assert_command_fails() {
    local command="$1"
    local message="${2:-"Expected command to fail: $command"}"
    
    if ! eval "$command" >/dev/null 2>&1; then
        print_assertion "PASS" "$message"
        return 0
    else
        print_assertion "FAIL" "$message" "Command succeeded unexpectedly"
        return 1
    fi
}

assert_command_output() {
    local command="$1"
    local expected_output="$2"
    local message="${3:-"Expected command output to match"}"
    
    local actual_output
    actual_output="$(eval "$command" 2>&1)"
    local exit_code=$?
    
    if [ $exit_code -ne 0 ]; then
        print_assertion "FAIL" "$message" "Command failed with exit code: $exit_code"
        return 1
    fi
    
    if [ "$actual_output" = "$expected_output" ]; then
        print_assertion "PASS" "$message"
        return 0
    else
        print_assertion "FAIL" "$message" "Expected: '$expected_output', Actual: '$actual_output'"
        return 1
    fi
}

assert_command_output_contains() {
    local command="$1"
    local expected_substring="$2"
    local message="${3:-"Expected command output to contain substring"}"
    
    local actual_output
    actual_output="$(eval "$command" 2>&1)"
    local exit_code=$?
    
    if [ $exit_code -ne 0 ]; then
        print_assertion "FAIL" "$message" "Command failed with exit code: $exit_code"
        return 1
    fi
    
    if [[ "$actual_output" == *"$expected_substring"* ]]; then
        print_assertion "PASS" "$message"
        return 0
    else
        print_assertion "FAIL" "$message" "Output does not contain: '$expected_substring'. Actual: '$actual_output'"
        return 1
    fi
}

# Array assertions
assert_array_contains() {
    local needle="$1"
    shift
    local haystack=("$@")
    local message="Expected array to contain '$needle'"
    
    for item in "${haystack[@]}"; do
        if [ "$item" = "$needle" ]; then
            print_assertion "PASS" "$message"
            return 0
        fi
    done
    
    print_assertion "FAIL" "$message" "Array does not contain '$needle': (${haystack[*]})"
    return 1
}

assert_array_length() {
    local expected_length="$1"
    shift
    local array=("$@")
    local actual_length=${#array[@]}
    local message="Expected array length to be $expected_length"
    
    if [ "$actual_length" -eq "$expected_length" ]; then
        print_assertion "PASS" "$message"
        return 0
    else
        print_assertion "FAIL" "$message" "Expected: $expected_length, Actual: $actual_length"
        return 1
    fi
}

# Test result functions
get_assertion_count() {
    echo "$ASSERTION_COUNT"
}

get_assertion_failures() {
    echo "$ASSERTION_FAILURES"
}

get_assertion_success_rate() {
    if [ "$ASSERTION_COUNT" -eq 0 ]; then
        echo "0"
        return
    fi
    
    local success_count=$((ASSERTION_COUNT - ASSERTION_FAILURES))
    local rate
    rate=$(echo "scale=2; $success_count * 100 / $ASSERTION_COUNT" | bc -l)
    echo "$rate"
}

# Reset test state (useful for running multiple test functions)
reset_assertions() {
    ASSERTION_COUNT=0
    ASSERTION_FAILURES=0
    ASSERTION_MESSAGES=()
}

# Print test summary
print_assertion_summary() {
    local success_count=$((ASSERTION_COUNT - ASSERTION_FAILURES))
    local success_rate
    success_rate=$(get_assertion_success_rate)
    
    echo ""
    echo "Assertion Summary:"
    printf "  Total: %d\n" "$ASSERTION_COUNT"
    printf "  ${ASSERT_GREEN}Passed: %d${ASSERT_NC}\n" "$success_count"
    printf "  ${ASSERT_RED}Failed: %d${ASSERT_NC}\n" "$ASSERTION_FAILURES"
    printf "  Success Rate: %s%%\n" "$success_rate"
    
    if [ "$ASSERTION_FAILURES" -gt 0 ]; then
        echo ""
        printf "${ASSERT_RED}Failed Assertions:${ASSERT_NC}\n"
        for message in "${ASSERTION_MESSAGES[@]}"; do
            printf "  - %s\n" "$message"
        done
    fi
    
    return "$ASSERTION_FAILURES"
}

# Utility function to fail a test with a custom message
fail() {
    local message="$1"
    print_assertion "FAIL" "Test failed" "$message"
    return 1
}

# Utility function to skip a test
skip() {
    local message="${1:-"Test skipped"}"
    printf "${ASSERT_YELLOW}⊘${ASSERT_NC} %s\n" "$message"
    exit 0
}