#!/bin/bash

# Main Test Execution Script
# Unified entry point for running all types of tests

set -euo pipefail

# Configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LIB_DIR="$SCRIPT_DIR/lib"

# Validate configuration values
validate_config() {
    # Validate numeric values
    if [ -n "${TEST_PARALLEL_JOBS:-}" ] && ! [[ "${TEST_PARALLEL_JOBS}" =~ ^[0-9]+$ ]]; then
        echo "Error: TEST_PARALLEL_JOBS must be a positive integer" >&2
        return 1
    fi
    
    if [ -n "${TEST_TIMEOUT:-}" ] && ! [[ "${TEST_TIMEOUT}" =~ ^[0-9]+$ ]]; then
        echo "Error: TEST_TIMEOUT must be a positive integer" >&2
        return 1
    fi
    
    # Validate boolean values
    local bool_vars=("TEST_VERBOSE" "TEST_QUIET" "MOCK_CLEANUP_ON_EXIT" "TEST_PERFORMANCE_TRACKING" "TEST_TREND_ANALYSIS" "TEST_REGRESSION_CHECK" "CI_MODE" "CI_FAIL_FAST")
    for var in "${bool_vars[@]}"; do
        local value="${!var:-}"
        if [ -n "$value" ] && [[ ! "$value" =~ ^(true|false)$ ]]; then
            echo "Error: $var must be 'true' or 'false'" >&2
            return 1
        fi
    done
    
    # Validate format
    if [ -n "${TEST_DEFAULT_FORMAT:-}" ] && [[ ! "${TEST_DEFAULT_FORMAT}" =~ ^(console|json|html|all)$ ]]; then
        echo "Error: TEST_DEFAULT_FORMAT must be one of: console, json, html, all" >&2
        return 1
    fi
    
    # Validate suite type
    if [ -n "${TEST_DEFAULT_SUITE:-}" ] && [[ ! "${TEST_DEFAULT_SUITE}" =~ ^(unit|integration|e2e|all)$ ]]; then
        echo "Error: TEST_DEFAULT_SUITE must be one of: unit, integration, e2e, all" >&2
        return 1
    fi
    
    return 0
}

# Load configuration file if it exists
load_config() {
    local config_files=(
        "$SCRIPT_DIR/test-config.conf"
        "$SCRIPT_DIR/test-config.local"
        "$HOME/.wp-init-test-config"
        "./.test-config"
    )
    
    for config_file in "${config_files[@]}"; do
        if [ -f "$config_file" ]; then
            echo "Loading configuration from: $config_file"
            # shellcheck source=/dev/null
            source "$config_file"
            
            # Validate configuration after loading
            if ! validate_config; then
                echo "Error: Invalid configuration in $config_file" >&2
                exit 1
            fi
            break
        fi
    done
}

# Load configuration first
load_config

# Source required libraries
source "$LIB_DIR/test-runner.sh"
source "$LIB_DIR/performance-tracker.sh"
source "$LIB_DIR/trend-analyzer.sh"
source "$LIB_DIR/reporters.sh"

# Default values (can be overridden by config file)
DEFAULT_SUITE_TYPE="${TEST_DEFAULT_SUITE:-all}"
DEFAULT_PATTERN="${TEST_DEFAULT_PATTERN:-*}"
DEFAULT_OPTIONS=""

# Apply config file defaults
if [ "${TEST_VERBOSE:-false}" = "true" ]; then
    DEFAULT_OPTIONS="$DEFAULT_OPTIONS verbose"
fi

if [ "${TEST_QUIET:-false}" = "true" ]; then
    DEFAULT_OPTIONS="$DEFAULT_OPTIONS quiet"
fi

# Show usage information
show_usage() {
    cat <<EOF
WordPress Init Test Suite Runner

Usage: $0 [OPTIONS] [SUITE_TYPE] [PATTERN]

SUITE_TYPES:
    unit         Run unit tests only
    integration  Run integration tests only
    e2e          Run end-to-end tests only
    all          Run all tests (default)

OPTIONS:
    -p, --pattern PATTERN    Test file pattern (default: ${TEST_DEFAULT_PATTERN:-*})
    -g, --tags TAGS          Filter tests by tags (comma-separated)
    -j, --jobs NUMBER        Number of parallel jobs (default: ${TEST_PARALLEL_JOBS:-4})
    -t, --timeout SECONDS    Test timeout in seconds (default: ${TEST_TIMEOUT:-60})
    -v, --verbose            Enable verbose output
    -q, --quiet              Suppress non-essential output
    -f, --format FORMAT      Report format: console, json, html, all (default: ${TEST_DEFAULT_FORMAT:-console})
    -o, --output DIR         Output directory for reports (default: ${TEST_REPORTS_DIR:-./test-reports})
    -c, --config FILE        Use specific configuration file
    --no-cleanup             Don't cleanup mock environments on exit
    --performance            Enable detailed performance tracking
    --trends                 Generate trend analysis and forecasts
    --regression             Check for performance regressions
    --ci                     Enable CI mode (optimized output for CI/CD)
    --fail-fast              Stop on first failure
    --list                   List available test files and exit
    -h, --help               Show this help message

EXAMPLES:
    $0                                    # Run all tests
    $0 unit                              # Run only unit tests
    $0 integration -v                    # Run integration tests with verbose output
    $0 unit -p "validation*"             # Run unit tests matching pattern
    $0 unit -g "validation,core"         # Run unit tests with validation or core tags
    $0 all -j 8 -t 120                   # Run all tests with 8 jobs and 2min timeout
    $0 e2e --format html                 # Run e2e tests and generate HTML report
    $0 -c custom-config.conf all         # Run all tests with custom configuration
    $0 --ci --fail-fast integration       # Run integration tests in CI mode

ENVIRONMENT VARIABLES:
    TEST_PARALLEL_JOBS       Number of parallel jobs (default: 4)
    TEST_TIMEOUT             Test timeout in seconds (default: 60)
    TEST_REPORTS_DIR         Directory for test reports (default: ./test-reports)
    TEST_MOCK_DIR            Directory for mock environments (default: /tmp/wp-init-test-mocks)
    MOCK_CLEANUP_ON_EXIT     Cleanup mocks on exit (default: true)

CONFIGURATION FILES (loaded in order):
    tests/test-config.conf   Project-specific configuration
    tests/test-config.local  Local overrides (git-ignored)
    ~/.wp-init-test-config   User-global configuration
    ./.test-config           Directory-specific configuration
EOF
}

# Parse command line arguments
parse_arguments() {
    local suite_type="$DEFAULT_SUITE_TYPE"
    local pattern="$DEFAULT_PATTERN"
    local tags=""
    local options="$DEFAULT_OPTIONS"
    local jobs=""
    local timeout=""
    local format="console"
    local output_dir=""
    local list_only=false
    local enable_performance="${TEST_PERFORMANCE_TRACKING:-false}"
    local enable_trends="${TEST_TREND_ANALYSIS:-false}"
    local check_regression="${TEST_REGRESSION_CHECK:-false}"
    local ci_mode="${CI_MODE:-false}"
    local fail_fast="${CI_FAIL_FAST:-false}"
    local custom_config=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -p|--pattern)
                pattern="$2"
                shift 2
                ;;
            -g|--tags)
                tags="$2"
                shift 2
                ;;
            -j|--jobs)
                jobs="$2"
                shift 2
                ;;
            -t|--timeout)
                timeout="$2"
                shift 2
                ;;
            -v|--verbose)
                options="$options verbose"
                shift
                ;;
            -q|--quiet)
                options="$options quiet"
                shift
                ;;
            -f|--format)
                format="$2"
                shift 2
                ;;
            -o|--output)
                output_dir="$2"
                shift 2
                ;;
            -c|--config)
                custom_config="$2"
                shift 2
                ;;
            --ci)
                ci_mode=true
                shift
                ;;
            --fail-fast)
                fail_fast=true
                shift
                ;;
            --no-cleanup)
                export MOCK_CLEANUP_ON_EXIT=false
                shift
                ;;
            --performance)
                enable_performance=true
                shift
                ;;
            --trends)
                enable_trends=true
                shift
                ;;
            --regression)
                check_regression=true
                shift
                ;;
            --list)
                list_only=true
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            unit|integration|e2e|all)
                suite_type="$1"
                shift
                ;;
            -*)
                echo "Error: Unknown option $1" >&2
                show_usage
                exit 1
                ;;
            *)
                # Assume it's a pattern if no suite type is set yet
                if [ "$suite_type" = "$DEFAULT_SUITE_TYPE" ] && [ "$pattern" = "$DEFAULT_PATTERN" ]; then
                    pattern="$1"
                else
                    echo "Error: Unexpected argument $1" >&2
                    show_usage
                    exit 1
                fi
                shift
                ;;
        esac
    done
    
    # Set environment variables if provided
    if [ -n "$jobs" ]; then
        export TEST_PARALLEL_JOBS="$jobs"
    fi
    
    if [ -n "$timeout" ]; then
        export TEST_TIMEOUT="$timeout"
    fi
    
    if [ -n "$output_dir" ]; then
        export TEST_REPORTS_DIR="$output_dir"
    fi
    
    # Load custom configuration if specified
    if [ -n "$custom_config" ]; then
        if [ -f "$custom_config" ]; then
            echo "Loading custom configuration from: $custom_config"
            # shellcheck source=/dev/null
            source "$custom_config"
        else
            echo "Error: Configuration file not found: $custom_config" >&2
            exit 1
        fi
    fi
    
    # Apply CI mode settings
    if [ "$ci_mode" = true ]; then
        export CI_MODE=true
        options="$options ci"
        if [ "$fail_fast" = true ]; then
            export CI_FAIL_FAST=true
            options="$options fail-fast"
        fi
    fi
    
    # Handle list option
    if [ "$list_only" = true ]; then
        list_available_tests "$suite_type" "$pattern" "$tags"
        exit 0
    fi
    
    # Execute tests
    execute_tests "$suite_type" "$pattern" "$tags" "$options" "$format" "$enable_performance" "$enable_trends" "$check_regression"
}

# List available test files
list_available_tests() {
    local suite_type="$1"
    local pattern="$2"
    local tags="${3:-}"
    
    echo "Available test files:"
    echo ""
    
    case "$suite_type" in
        "unit"|"all")
            echo "Unit Tests:"
            find "$SCRIPT_DIR/unit" -name "test_${pattern}.sh" -type f 2>/dev/null | sort | sed 's/^/  /' || echo "  None found"
            echo ""
            ;;
    esac
    
    case "$suite_type" in
        "integration"|"all")
            echo "Integration Tests:"
            find "$SCRIPT_DIR/integration" -name "test_${pattern}.sh" -type f 2>/dev/null | sort | sed 's/^/  /' || echo "  None found"
            echo ""
            ;;
    esac
    
    case "$suite_type" in
        "e2e"|"all")
            echo "End-to-End Tests:"
            find "$SCRIPT_DIR/e2e" -name "test_${pattern}.sh" -type f 2>/dev/null | sort | sed 's/^/  /' || echo "  None found"
            echo ""
            ;;
    esac
}

# Execute tests with specified parameters
execute_tests() {
    local suite_type="$1"
    local pattern="$2"
    local tags="${3:-}"
    local options="$4"
    local format="$5"
    local enable_performance="${6:-false}"
    local enable_trends="${7:-false}"
    local check_regression="${8:-false}"
    
    # Validate format
    case "$format" in
        console|json|html|all)
            ;;
        *)
            echo "Error: Invalid format '$format'. Use: console, json, html, all" >&2
            exit 1
            ;;
    esac
    
    # Print configuration if verbose
    if [[ "$options" == *"verbose"* ]]; then
        echo "Test Configuration:"
        echo "  Suite Type: $suite_type"
        echo "  Pattern: $pattern"
        echo "  Tags: ${tags:-none}"
        echo "  Parallel Jobs: ${TEST_PARALLEL_JOBS:-4}"
        echo "  Timeout: ${TEST_TIMEOUT:-60}s"
        echo "  Report Format: $format"
        echo "  Reports Dir: ${TEST_REPORTS_DIR:-./test-reports}"
        echo "  Mock Dir: ${TEST_MOCK_DIR:-/tmp/wp-init-test-mocks}"
        echo "  Performance Tracking: $enable_performance"
        echo "  Trend Analysis: $enable_trends"
        echo "  Regression Check: $check_regression"
        echo ""
    fi
    
    # Run tests using the test runner
    local exit_code=0
    local test_results=()
    
    # Capture test results for advanced reporting
    if [ "$enable_performance" = true ] || [ "$enable_trends" = true ] || [ "$check_regression" = true ] || [ "$format" != "console" ]; then
        # Run tests and capture results
        if ! test_results=($(run_test_suite_with_results "$suite_type" "$pattern" "$tags" "$options")); then
            exit_code=$?
        fi
    else
        # Run tests normally
        if ! run_test_suite "$suite_type" "$pattern" "$tags" "$options"; then
            exit_code=$?
        fi
    fi
    
    # Generate advanced reports and analysis if requested
    if [ ${#test_results[@]} -gt 0 ]; then
        echo ""
        
        # Performance analysis
        if [ "$enable_performance" = true ]; then
            echo "Generating performance analysis..."
            local perf_summary
            perf_summary=$(generate_performance_summary "${test_results[@]}")
            echo "Performance summary generated"
            
            # Generate performance benchmark
            generate_performance_benchmark >/dev/null 2>&1 || true
        fi
        
        # Trend analysis
        if [ "$enable_trends" = true ]; then
            echo "Recording trend data and generating analysis..."
            record_trend_data "${test_results[@]}"
            
            local trend_analysis
            trend_analysis=$(analyze_trends 2>/dev/null)
            if [ $? -eq 0 ]; then
                echo "Trend analysis completed"
                
                # Generate forecast
                generate_trend_forecast "$trend_analysis" >/dev/null 2>&1 || true
            fi
        fi
        
        # Regression check
        if [ "$check_regression" = true ]; then
            echo "Checking for performance regressions..."
            local regression_report
            regression_report=$(detect_performance_regressions "${test_results[@]}" 2>/dev/null)
            if [ $? -eq 0 ]; then
                local regressions_count
                regressions_count=$(echo "$regression_report" | jq -r '.analysis.regressions_detected')
                if [ "$regressions_count" -gt 0 ]; then
                    echo "⚠️  $regressions_count performance regressions detected!"
                    echo "$regression_report" | jq -r '.regressions[] | "  - \(.test_name): +\(.performance_degradation_ms)ms (\(.severity) severity)"'
                else
                    echo "✅ No performance regressions detected"
                fi
            fi
        fi
        
        # Generate reports in requested formats
        if [ "$format" != "console" ]; then
            echo "Generating reports in $format format..."
            case "$format" in
                json)
                    local json_file
                    json_file=$(generate_json_report "${test_results[@]}")
                    echo "JSON report: $json_file"
                    ;;
                html)
                    local html_file
                    html_file=$(generate_html_report "${test_results[@]}")
                    echo "HTML report: $html_file"
                    ;;
                all)
                    generate_all_reports "${test_results[@]}"
                    ;;
            esac
        fi
        
        # Cleanup old data
        cleanup_performance_data
        cleanup_trend_data
        cleanup_historical_data
    fi
    
    return $exit_code
}

# Validate environment
validate_environment() {
    # Check if required tools are available (unless we're testing their absence)
    local missing_tools=()
    
    # Check for basic tools needed by the test framework itself
    if ! command -v bc >/dev/null 2>&1; then
        missing_tools+=("bc")
    fi
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        echo "Error: Missing required tools for test framework:" >&2
        printf "  %s\n" "${missing_tools[@]}" >&2
        echo "" >&2
        echo "Please install the missing tools and try again." >&2
        exit 1
    fi
    
    # Create necessary directories
    mkdir -p "${TEST_REPORTS_DIR:-./test-reports}"
    mkdir -p "${TEST_MOCK_DIR:-/tmp/wp-init-test-mocks}"
}

# Main execution
main() {
    # Validate environment first
    validate_environment
    
    # Handle no arguments case
    if [ $# -eq 0 ]; then
        echo "Running all tests with default settings..."
        echo "Use '$0 --help' for more options."
        echo ""
        execute_tests "$DEFAULT_SUITE_TYPE" "$DEFAULT_PATTERN" "" "$DEFAULT_OPTIONS" "console"
    else
        parse_arguments "$@"
    fi
}

# Only run main if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi