#!/bin/bash

# Comprehensive Test Runner
# Runs all test suites: unit, integration, and end-to-end

# Source test dependencies
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/assertions.sh"

# Colors for output
readonly TEST_GREEN='\033[0;32m'
readonly TEST_RED='\033[0;31m'
readonly TEST_YELLOW='\033[1;33m'
readonly TEST_BLUE='\033[0;34m'
readonly TEST_NC='\033[0m'

# Test results tracking
TOTAL_SUITES=0
PASSED_SUITES=0
FAILED_SUITES=()

# Print test header
print_test_header() {
    echo ""
    echo "🧪 WordPress Init - Comprehensive Test Suite"
    echo "============================================="
    echo ""
}

# Print section header
print_section_header() {
    local section="$1"
    echo ""
    echo -e "${TEST_BLUE}📋 $section${TEST_NC}"
    echo "$(printf '=%.0s' {1..50})"
}

# Run test suite and track results
run_test_suite() {
    local suite_name="$1"
    local test_script="$2"
    
    echo ""
    echo -e "${TEST_YELLOW}Running $suite_name...${TEST_NC}"
    
    ((TOTAL_SUITES++))
    
    if [ -f "$test_script" ] && [ -x "$test_script" ]; then
        if "$test_script"; then
            echo -e "${TEST_GREEN}✅ $suite_name PASSED${TEST_NC}"
            ((PASSED_SUITES++))
        else
            echo -e "${TEST_RED}❌ $suite_name FAILED${TEST_NC}"
            FAILED_SUITES+=("$suite_name")
        fi
    else
        echo -e "${TEST_RED}❌ $suite_name SKIPPED (script not found or not executable)${TEST_NC}"
        FAILED_SUITES+=("$suite_name (not found)")
    fi
}

# Print final summary
print_final_summary() {
    echo ""
    echo "📊 Final Test Results"
    echo "===================="
    echo "  • Total Test Suites: $TOTAL_SUITES"
    echo "  • Passed: $PASSED_SUITES"
    echo "  • Failed: $((TOTAL_SUITES - PASSED_SUITES))"
    echo ""
    
    if [ ${#FAILED_SUITES[@]} -eq 0 ]; then
        echo -e "${TEST_GREEN}🎉 All test suites passed!${TEST_NC}"
        echo ""
        return 0
    else
        echo -e "${TEST_RED}❌ Failed test suites:${TEST_NC}"
        for suite in "${FAILED_SUITES[@]}"; do
            echo "  • $suite"
        done
        echo ""
        return 1
    fi
}

# Main test execution
main() {
    print_test_header
    
    # Unit Tests
    print_section_header "Unit Tests"
    
    # Make scripts executable
    chmod +x "$SCRIPT_DIR/unit/validation/test_validation_engine.sh" 2>/dev/null || true
    chmod +x "$SCRIPT_DIR/unit/utils/test_utility_functions.sh" 2>/dev/null || true
    chmod +x "$SCRIPT_DIR/unit/components/test_component_detection.sh" 2>/dev/null || true
    
    run_test_suite "Validation Engine" "$SCRIPT_DIR/unit/validation/test_validation_engine.sh"
    run_test_suite "Utility Functions" "$SCRIPT_DIR/unit/utils/test_utility_functions.sh"
    run_test_suite "Component Detection" "$SCRIPT_DIR/unit/components/test_component_detection.sh"
    
    # Integration Tests
    print_section_header "Integration Tests"
    
    # Make scripts executable
    chmod +x "$SCRIPT_DIR/integration/modes/test_mode_1_complete.sh" 2>/dev/null || true
    chmod +x "$SCRIPT_DIR/integration/modes/test_mode_2_config_only.sh" 2>/dev/null || true
    chmod +x "$SCRIPT_DIR/integration/workflows/test_error_recovery.sh" 2>/dev/null || true
    
    run_test_suite "Mode 1 Complete" "$SCRIPT_DIR/integration/modes/test_mode_1_complete.sh"
    run_test_suite "Mode 2 Config Only" "$SCRIPT_DIR/integration/modes/test_mode_2_config_only.sh"
    run_test_suite "Error Recovery" "$SCRIPT_DIR/integration/workflows/test_error_recovery.sh"
    
    # End-to-End Tests
    print_section_header "End-to-End Tests"
    
    # Make scripts executable
    chmod +x "$SCRIPT_DIR/e2e/scenarios/test_new_project_setup.sh" 2>/dev/null || true
    chmod +x "$SCRIPT_DIR/e2e/regression/test_regression_scenarios.sh" 2>/dev/null || true
    
    run_test_suite "New Project Setup" "$SCRIPT_DIR/e2e/scenarios/test_new_project_setup.sh"
    run_test_suite "Regression Scenarios" "$SCRIPT_DIR/e2e/regression/test_regression_scenarios.sh"
    
    # Print final results
    print_final_summary
}

# Run main function
main "$@"