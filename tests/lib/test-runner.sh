#!/bin/bash

# Test Runner with Parallel Execution
# Provides core test execution functionality with parallel processing

set -euo pipefail

# Configuration
if [ -z "${SCRIPT_DIR:-}" ]; then
    readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi
if [ -z "${TESTS_DIR:-}" ]; then
    # If SCRIPT_DIR ends with /lib, go up one more level
    if [[ "$SCRIPT_DIR" == */lib ]]; then
        readonly TESTS_DIR="$(dirname "$SCRIPT_DIR")"
    else
        readonly TESTS_DIR="$SCRIPT_DIR"
    fi
fi
readonly MAX_PARALLEL_JOBS="${TEST_PARALLEL_JOBS:-4}"
readonly TEST_TIMEOUT="${TEST_TIMEOUT:-60}"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Global variables
declare -a RUNNING_JOBS=()
declare -a TEST_RESULTS=()
declare -i TESTS_PASSED=0
declare -i TESTS_FAILED=0
declare -i TESTS_SKIPPED=0

# Source dependencies
# Determine the correct lib directory
if [ -z "${TEST_LIB_DIR:-}" ]; then
    if [ -f "$SCRIPT_DIR/lib/assertions.sh" ]; then
        TEST_LIB_DIR="$SCRIPT_DIR/lib"
    else
        TEST_LIB_DIR="$SCRIPT_DIR"
    fi
fi

source "$TEST_LIB_DIR/assertions.sh"
source "$TEST_LIB_DIR/reporters.sh"

# Print colored output
print_color() {
    local color="$1"
    local message="$2"
    printf "${color}%s${NC}\n" "$message"
}

# Print test runner header
print_header() {
    if [ "${CI_MODE:-false}" = "true" ]; then
        echo "::group::WordPress Init Test Runner"
        echo "Max parallel jobs: $MAX_PARALLEL_JOBS"
        echo "Test timeout: ${TEST_TIMEOUT}s"
        if [ "${CI_FAIL_FAST:-false}" = "true" ]; then
            echo "Fail-fast mode: enabled"
        fi
        echo "::endgroup::"
    else
        echo "=================================="
        print_color "$BLUE" "WordPress Init Test Runner"
        echo "=================================="
        echo "Max parallel jobs: $MAX_PARALLEL_JOBS"
        echo "Test timeout: ${TEST_TIMEOUT}s"
        echo ""
    fi
}

# Find test files matching pattern and tags
find_test_files() {
    local suite_type="$1"
    local pattern="${2:-*}"
    local tags="${3:-}"
    
    local test_files=()
    
    case "$suite_type" in
        "unit")
            if [ "$pattern" = "*" ]; then
                while IFS= read -r file; do
                    [ -n "$file" ] && test_files+=("$file")
                done < <(find "$TESTS_DIR/unit" -name "*.sh" -type f 2>/dev/null || true)
            else
                while IFS= read -r file; do
                    [ -n "$file" ] && test_files+=("$file")
                done < <(find "$TESTS_DIR/unit" -name "*.sh" -type f 2>/dev/null | grep "$pattern" || true)
            fi
            ;;
        "integration")
            if [ "$pattern" = "*" ]; then
                while IFS= read -r file; do
                    [ -n "$file" ] && test_files+=("$file")
                done < <(find "$TESTS_DIR/integration" -name "*.sh" -type f 2>/dev/null || true)
            else
                while IFS= read -r file; do
                    [ -n "$file" ] && test_files+=("$file")
                done < <(find "$TESTS_DIR/integration" -name "*.sh" -type f 2>/dev/null | grep "$pattern" || true)
            fi
            ;;
        "e2e")
            if [ "$pattern" = "*" ]; then
                while IFS= read -r file; do
                    [ -n "$file" ] && test_files+=("$file")
                done < <(find "$TESTS_DIR/e2e" -name "*.sh" -type f 2>/dev/null || true)
            else
                while IFS= read -r file; do
                    [ -n "$file" ] && test_files+=("$file")
                done < <(find "$TESTS_DIR/e2e" -name "*.sh" -type f 2>/dev/null | grep "$pattern" || true)
            fi
            ;;
        "all")
            if [ "$pattern" = "*" ]; then
                while IFS= read -r file; do
                    [ -n "$file" ] && test_files+=("$file")
                done < <(find "$TESTS_DIR" -name "*.sh" -type f 2>/dev/null || true)
            else
                while IFS= read -r file; do
                    [ -n "$file" ] && test_files+=("$file")
                done < <(find "$TESTS_DIR" -name "*.sh" -type f 2>/dev/null | grep "$pattern" || true)
            fi
            ;;
        *)
            echo "Error: Unknown suite type '$suite_type'" >&2
            return 1
            ;;
    esac
    
    # Filter by tags if specified
    if [ -n "$tags" ] && [ ${#test_files[@]} -gt 0 ]; then
        local filtered_files=()
        local tag_array
        IFS=',' read -ra tag_array <<< "$tags"
        
        for test_file in "${test_files[@]}"; do
            if [ -f "$test_file" ]; then
                # Check if test file contains any of the specified tags
                local has_tag=false
                for tag in "${tag_array[@]}"; do
                    tag=$(echo "$tag" | xargs) # trim whitespace
                    if grep -q "# @tag $tag" "$test_file" 2>/dev/null; then
                        has_tag=true
                        break
                    fi
                done
                
                if [ "$has_tag" = true ]; then
                    filtered_files+=("$test_file")
                fi
            fi
        done
        
        if [ ${#filtered_files[@]} -gt 0 ]; then
            printf '%s\n' "${filtered_files[@]}"
        fi
    else
        if [ ${#test_files[@]} -gt 0 ]; then
            printf '%s\n' "${test_files[@]}"
        fi
    fi
}

# Execute a single test file
execute_test_file() {
    local test_file="$1"
    local test_name
    test_name="$(basename "$test_file" .sh)"
    
    local start_time
    start_time="$(date +%s)"
    
    local temp_output
    temp_output="$(mktemp)"
    
    local exit_code=0
    
    # Execute test with timeout (using background process and kill for macOS compatibility)
    bash "$test_file" > "$temp_output" 2>&1 &
    local test_pid=$!
    
    # Wait for test to complete or timeout
    local count=0
    while [ $count -lt "$TEST_TIMEOUT" ] && kill -0 "$test_pid" 2>/dev/null; do
        sleep 1
        ((count++))
    done
    
    if kill -0 "$test_pid" 2>/dev/null; then
        # Test is still running, kill it
        kill "$test_pid" 2>/dev/null
        wait "$test_pid" 2>/dev/null
        echo "Test timed out after ${TEST_TIMEOUT} seconds" >> "$temp_output"
        exit_code=124  # Standard timeout exit code
    else
        # Test completed, get exit code
        wait "$test_pid"
        exit_code=$?
    fi
    
    local end_time
    end_time="$(date +%s)"
    local duration=$((end_time - start_time))
    
    # Store result
    local result_json
    result_json=$(cat <<EOF
{
    "test_name": "$test_name",
    "test_file": "$test_file",
    "status": "$([ $exit_code -eq 0 ] && echo "PASS" || echo "FAIL")",
    "duration": $duration,
    "exit_code": $exit_code,
    "output_file": "$temp_output"
}
EOF
)
    
    echo "$result_json"
    return $exit_code
}

# Wait for running jobs to complete
wait_for_jobs() {
    local max_wait="${1:-0}"  # 0 means wait for all
    
    while [ ${#RUNNING_JOBS[@]} -gt $max_wait ]; do
        local new_jobs=()
        
        if [ ${#RUNNING_JOBS[@]} -gt 0 ]; then
            for job_info in "${RUNNING_JOBS[@]}"; do
            local pid="${job_info%%:*}"
            local temp_file="${job_info##*:}"
            
            if kill -0 "$pid" 2>/dev/null; then
                # Job still running
                new_jobs+=("$job_info")
            else
                # Job completed
                wait "$pid"
                local exit_code=$?
                
                if [ -f "$temp_file" ]; then
                    local result
                    result="$(cat "$temp_file")"
                    TEST_RESULTS+=("$result")
                    
                    # Update counters
                    if [ $exit_code -eq 0 ]; then
                        ((TESTS_PASSED++))
                        if [ "${CI_MODE:-false}" = "true" ]; then
                            echo "::notice::Test passed: $(echo "$result" | jq -r '.test_name')"
                        else
                            print_color "$GREEN" "✓ $(echo "$result" | jq -r '.test_name')"
                        fi
                    else
                        ((TESTS_FAILED++))
                        local test_name
                        test_name="$(echo "$result" | jq -r '.test_name')"
                        
                        if [ "${CI_MODE:-false}" = "true" ]; then
                            echo "::error::Test failed: $test_name"
                        else
                            print_color "$RED" "✗ $test_name"
                        fi
                        
                        # Check for fail-fast mode
                        if [ "${CI_FAIL_FAST:-false}" = "true" ]; then
                            echo "Fail-fast mode enabled. Stopping on first failure."
                            # Kill remaining jobs
                            for remaining_job in "${RUNNING_JOBS[@]}"; do
                                local remaining_pid="${remaining_job%%:*}"
                                kill "$remaining_pid" 2>/dev/null || true
                            done
                            return 1
                        fi
                    fi
                    
                    rm -f "$temp_file"
                fi
            fi
            done
        fi
        
        if [ ${#new_jobs[@]} -gt 0 ]; then
            RUNNING_JOBS=("${new_jobs[@]}")
        else
            RUNNING_JOBS=()
        fi
        
        if [ ${#RUNNING_JOBS[@]} -gt $max_wait ]; then
            sleep 0.1
        fi
    done
}

# Run test suite
run_test_suite() {
    local suite_type="$1"
    local pattern="${2:-*}"
    local tags="${3:-}"
    local options="${4:-}"
    
    print_header
    
    local test_files=()
    while IFS= read -r file; do
        [ -n "$file" ] && test_files+=("$file")
    done < <(find_test_files "$suite_type" "$pattern" "$tags")
    
    if [ ${#test_files[@]} -eq 0 ]; then
        local filter_desc="pattern: $pattern"
        if [ -n "$tags" ]; then
            filter_desc="$filter_desc, tags: $tags"
        fi
        print_color "$YELLOW" "No test files found for $filter_desc"
        return 0
    fi
    
    print_color "$BLUE" "Found ${#test_files[@]} test files"
    echo ""
    
    # Execute tests
    for test_file in "${test_files[@]}"; do
        # Wait if we have too many jobs running
        wait_for_jobs $((MAX_PARALLEL_JOBS - 1))
        
        # Start new test job
        local temp_result
        temp_result="$(mktemp)"
        
        (execute_test_file "$test_file" > "$temp_result") &
        local job_pid=$!
        
        RUNNING_JOBS+=("$job_pid:$temp_result")
        
        if [[ "$options" == *"verbose"* ]]; then
            print_color "$BLUE" "Started: $(basename "$test_file")"
        fi
    done
    
    # Wait for all jobs to complete
    wait_for_jobs 0
    
    # Generate final report
    generate_summary_report
}

# Run a single test function from a file
run_single_test() {
    local test_file="$1"
    local test_function="${2:-}"
    
    if [ ! -f "$test_file" ]; then
        print_color "$RED" "Test file not found: $test_file"
        return 1
    fi
    
    print_color "$BLUE" "Running single test: $(basename "$test_file")"
    
    if [ -n "$test_function" ]; then
        print_color "$BLUE" "Function: $test_function"
        # Source the file and run specific function
        source "$test_file"
        if declare -f "$test_function" > /dev/null; then
            "$test_function"
        else
            print_color "$RED" "Function '$test_function' not found in $test_file"
            return 1
        fi
    else
        # Run entire file
        bash "$test_file"
    fi
}

# Run test suite and return results for advanced reporting
run_test_suite_with_results() {
    local suite_type="$1"
    local pattern="${2:-*}"
    local tags="${3:-}"
    local options="${4:-}"
    
    # Reset global variables
    TESTS_PASSED=0
    TESTS_FAILED=0
    TESTS_SKIPPED=0
    TEST_RESULTS=()
    RUNNING_JOBS=()
    
    print_header
    
    local test_files=()
    while IFS= read -r file; do
        [ -n "$file" ] && test_files+=("$file")
    done < <(find_test_files "$suite_type" "$pattern" "$tags")
    
    if [ ${#test_files[@]} -eq 0 ]; then
        local filter_desc="pattern: $pattern"
        if [ -n "$tags" ]; then
            filter_desc="$filter_desc, tags: $tags"
        fi
        print_color "$YELLOW" "No test files found for $filter_desc"
        return 0
    fi
    
    print_color "$BLUE" "Found ${#test_files[@]} test files"
    echo ""
    
    # Execute tests
    for test_file in "${test_files[@]}"; do
        # Wait if we have too many jobs running
        wait_for_jobs $((MAX_PARALLEL_JOBS - 1))
        
        # Start new test job
        local temp_result
        temp_result="$(mktemp)"
        
        (execute_test_file "$test_file" > "$temp_result") &
        local job_pid=$!
        
        RUNNING_JOBS+=("$job_pid:$temp_result")
        
        if [[ "$options" == *"verbose"* ]]; then
            print_color "$BLUE" "Started: $(basename "$test_file")"
        fi
    done
    
    # Wait for all jobs to complete
    wait_for_jobs 0
    
    # Generate final report
    generate_summary_report
    
    # Return test results for advanced reporting
    printf '%s\n' "${TEST_RESULTS[@]}"
    
    # Return appropriate exit code
    if [ $TESTS_FAILED -gt 0 ]; then
        return 1
    else
        return 0
    fi
}

# Generate summary report
generate_summary_report() {
    echo ""
    echo "=================================="
    print_color "$BLUE" "Test Results Summary"
    echo "=================================="
    
    local total_tests=$((TESTS_PASSED + TESTS_FAILED + TESTS_SKIPPED))
    
    print_color "$GREEN" "Passed: $TESTS_PASSED"
    print_color "$RED" "Failed: $TESTS_FAILED"
    print_color "$YELLOW" "Skipped: $TESTS_SKIPPED"
    echo "Total: $total_tests"
    
    if [ $TESTS_FAILED -gt 0 ]; then
        echo ""
        print_color "$RED" "Failed Tests:"
        for result in "${TEST_RESULTS[@]}"; do
            local status
            status="$(echo "$result" | jq -r '.status')"
            if [ "$status" = "FAIL" ]; then
                local test_name
                test_name="$(echo "$result" | jq -r '.test_name')"
                local output_file
                output_file="$(echo "$result" | jq -r '.output_file')"
                
                print_color "$RED" "  - $test_name"
                if [ -f "$output_file" ]; then
                    echo "    Output:"
                    sed 's/^/      /' "$output_file"
                    rm -f "$output_file"
                fi
            fi
        done
    fi
    
    # Clean up remaining output files
    for result in "${TEST_RESULTS[@]}"; do
        local output_file
        output_file="$(echo "$result" | jq -r '.output_file')"
        rm -f "$output_file" 2>/dev/null || true
    done
    
    return $TESTS_FAILED
}

# Show usage information
show_usage() {
    cat <<EOF
Usage: $0 <command> [options]

Commands:
    suite <type> [pattern] [options]  Run test suite
    single <file> [function]          Run single test
    help                             Show this help

Suite Types:
    unit         Run unit tests
    integration  Run integration tests  
    e2e          Run end-to-end tests
    all          Run all tests

Options:
    verbose      Show verbose output
    
Examples:
    $0 suite unit                    # Run all unit tests
    $0 suite integration "*mode*"    # Run integration tests matching pattern
    $0 single tests/unit/test_validation.sh
    $0 single tests/unit/test_validation.sh test_specific_function

Environment Variables:
    TEST_PARALLEL_JOBS    Number of parallel jobs (default: 4)
    TEST_TIMEOUT          Test timeout in seconds (default: 60)
EOF
}

# Main execution
main() {
    if [ $# -eq 0 ]; then
        show_usage
        exit 1
    fi
    
    local command="$1"
    shift
    
    case "$command" in
        "suite")
            if [ $# -eq 0 ]; then
                echo "Error: Suite type required" >&2
                show_usage
                exit 1
            fi
            run_test_suite "$@"
            ;;
        "single")
            if [ $# -eq 0 ]; then
                echo "Error: Test file required" >&2
                show_usage
                exit 1
            fi
            run_single_test "$@"
            ;;
        "help"|"-h"|"--help")
            show_usage
            ;;
        *)
            echo "Error: Unknown command '$command'" >&2
            show_usage
            exit 1
            ;;
    esac
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi