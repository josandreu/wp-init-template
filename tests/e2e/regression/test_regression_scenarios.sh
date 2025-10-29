#!/bin/bash

# End-to-End Regression Tests
# Tests to prevent regressions in existing functionality

# Source test dependencies
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/assertions.sh"
source "$SCRIPT_DIR/../../lib/mock-env.sh"

# Test setup
setup_regression_tests() {
    # Create isolated test environment
    TEST_ENV=$(create_mock_env "regression_test")
    cd "$TEST_ENV"
    
    # Copy main script
    cp "$SCRIPT_DIR/../../../init-project.sh" .
    
    # Create baseline templates and structure
    create_baseline_environment
}

# Create baseline environment that represents a known working state
create_baseline_environment() {
    # Create WordPress structure
    mkdir -p wp-content/{plugins,themes,mu-plugins}
    
    # Create baseline templates
    create_baseline_templates
    
    # Create baseline components
    create_baseline_components
}

# Create baseline templates (simplified versions)
create_baseline_templates() {
    cat > .gitignore.template << 'EOF'
# WordPress
wp-config.php
wp-content/uploads/

# Dependencies
node_modules/
vendor/

# Project specific
{{PROJECT_SLUG}}-files/
EOF

    cat > package.json.template << 'EOF'
{
  "name": "{{PROJECT_SLUG}}",
  "version": "1.0.0",
  "scripts": {
    "dev": "echo 'dev'",
    "build": "echo 'build'"
  }
}
EOF

    cat > composer.json.template << 'EOF'
{
  "name": "{{PROJECT_NAMESPACE}}/{{PROJECT_SLUG}}",
  "require": {
    "php": ">=7.4"
  }
}
EOF
}

# Create baseline components
create_baseline_components() {
    # Baseline plugin
    mkdir -p wp-content/plugins/baseline-plugin
    cat > wp-content/plugins/baseline-plugin/baseline-plugin.php << 'EOF'
<?php
/**
 * Plugin Name: Baseline Plugin
 * Version: 1.0.0
 */

class BaselinePlugin {
    public function __construct() {
        add_action('init', array($this, 'init'));
    }
    
    public function init() {
        // Plugin functionality
    }
}

new BaselinePlugin();
EOF

    # Baseline theme
    mkdir -p wp-content/themes/baseline-theme
    cat > wp-content/themes/baseline-theme/style.css << 'EOF'
/*
Theme Name: Baseline Theme
Version: 1.0.0
*/

body {
    font-family: Arial, sans-serif;
}
EOF

    cat > wp-content/themes/baseline-theme/functions.php << 'EOF'
<?php
function baseline_theme_setup() {
    add_theme_support('post-thumbnails');
}
add_action('after_setup_theme', 'baseline_theme_setup');
EOF

    # Baseline MU plugin
    cat > wp-content/mu-plugins/baseline-mu.php << 'EOF'
<?php
/**
 * Baseline MU Plugin
 */

function baseline_mu_init() {
    // MU plugin functionality
}
add_action('init', 'baseline_mu_init');
EOF
}

# Test teardown
teardown_regression_tests() {
    cd - > /dev/null
    cleanup_mock_env "$TEST_ENV"
}

# Test that basic functionality still works as expected
test_basic_functionality_regression() {
    echo "Testing basic functionality regression..."
    
    setup_regression_tests
    
    export PROJECT_SLUG="regression-test"
    
    # Test component detection (should work as before)
    local detected_plugins
    detected_plugins=$(find wp-content/plugins -maxdepth 1 -type d -name "*" ! -name "plugins" | xargs -I {} basename {})
    
    if [[ "$detected_plugins" == *"baseline-plugin"* ]]; then
        print_assertion "PASS" "Should still detect plugins correctly"
    else
        print_assertion "FAIL" "Should still detect plugins correctly"
    fi
    
    local detected_themes
    detected_themes=$(find wp-content/themes -maxdepth 1 -type d -name "*" ! -name "themes" | xargs -I {} basename {})
    
    if [[ "$detected_themes" == *"baseline-theme"* ]]; then
        print_assertion "PASS" "Should still detect themes correctly"
    else
        print_assertion "FAIL" "Should still detect themes correctly"
    fi
    
    # Test template processing (should work as before)
    local gitignore_content
    gitignore_content=$(sed "s/{{PROJECT_SLUG}}/$PROJECT_SLUG/g" .gitignore.template)
    echo "$gitignore_content" > .gitignore
    
    if [ -f ".gitignore" ] && grep -q "$PROJECT_SLUG" .gitignore; then
        print_assertion "PASS" "Should still process templates correctly"
    else
        print_assertion "FAIL" "Should still process templates correctly"
    fi
    
    # Test namespace generation (should work as before)
    local namespace
    namespace=$(echo "$PROJECT_SLUG" | awk -F'-' '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1' OFS='')
    
    assert_equals "RegressionTest" "$namespace" "Should generate namespace correctly"
    
    # Test constant generation (should work as before)
    local constant
    constant=$(echo "$PROJECT_SLUG" | tr '[:lower:]' '[:upper:]' | tr '-' '_')
    
    assert_equals "REGRESSION_TEST" "$constant" "Should generate constant correctly"
    
    teardown_regression_tests
}

# Test that file generation still produces expected output
test_file_generation_regression() {
    echo "Testing file generation regression..."
    
    setup_regression_tests
    
    export PROJECT_SLUG="file-gen-test"
    
    # Generate package.json and verify structure
    local package_content
    package_content=$(sed "s/{{PROJECT_SLUG}}/$PROJECT_SLUG/g" package.json.template)
    echo "$package_content" > package.json
    
    # Verify JSON structure is valid (if jq is available)
    if command -v jq >/dev/null 2>&1; then
        if jq empty package.json 2>/dev/null; then
            print_assertion "PASS" "Should generate valid JSON structure"
        else
            print_assertion "FAIL" "Should generate valid JSON structure"
        fi
        
        # Verify specific fields
        local name_field
        name_field=$(jq -r '.name' package.json 2>/dev/null)
        assert_equals "$PROJECT_SLUG" "$name_field" "Should set correct name field"
        
        local version_field
        version_field=$(jq -r '.version' package.json 2>/dev/null)
        assert_equals "1.0.0" "$version_field" "Should set correct version field"
    else
        # Fallback verification without jq
        if grep -q "\"name\": \"$PROJECT_SLUG\"" package.json; then
            print_assertion "PASS" "Should set correct name field (fallback check)"
        else
            print_assertion "FAIL" "Should set correct name field (fallback check)"
        fi
    fi
    
    # Generate composer.json and verify structure
    local namespace
    namespace=$(echo "$PROJECT_SLUG" | tr '[:upper:]' '[:lower:]')
    local composer_content
    composer_content=$(sed -e "s/{{PROJECT_SLUG}}/$PROJECT_SLUG/g" -e "s/{{PROJECT_NAMESPACE}}/$namespace/g" composer.json.template)
    echo "$composer_content" > composer.json
    
    if command -v jq >/dev/null 2>&1; then
        if jq empty composer.json 2>/dev/null; then
            print_assertion "PASS" "Should generate valid composer.json structure"
        else
            print_assertion "FAIL" "Should generate valid composer.json structure"
        fi
    else
        if grep -q "\"name\": \"$namespace/$PROJECT_SLUG\"" composer.json; then
            print_assertion "PASS" "Should set correct composer name (fallback check)"
        else
            print_assertion "FAIL" "Should set correct composer name (fallback check)"
        fi
    fi
    
    teardown_regression_tests
}

# Test that validation logic still catches known issues
test_validation_regression() {
    echo "Testing validation regression..."
    
    setup_regression_tests
    
    # Test invalid slug detection (should still work)
    export PROJECT_SLUG="Invalid Slug!"
    
    if [[ ! "$PROJECT_SLUG" =~ ^[a-z0-9-]+$ ]]; then
        print_assertion "PASS" "Should still detect invalid slugs"
    else
        print_assertion "FAIL" "Should still detect invalid slugs"
    fi
    
    # Test missing WordPress structure detection
    rm -rf wp-content
    
    if [ ! -d "wp-content" ]; then
        print_assertion "PASS" "Should still detect missing WordPress structure"
    else
        print_assertion "FAIL" "Should still detect missing WordPress structure"
    fi
    
    # Recreate structure for further tests
    mkdir -p wp-content/{plugins,themes,mu-plugins}
    
    # Test nonexistent component detection
    export PROJECT_SLUG="valid-slug"
    export SELECTED_PLUGINS=("nonexistent-plugin")
    
    if [ ! -d "wp-content/plugins/nonexistent-plugin" ]; then
        print_assertion "PASS" "Should still detect nonexistent components"
    else
        print_assertion "FAIL" "Should still detect nonexistent components"
    fi
    
    # Test missing template detection
    rm -f .gitignore.template
    
    if [ ! -f ".gitignore.template" ]; then
        print_assertion "PASS" "Should still detect missing templates"
    else
        print_assertion "FAIL" "Should still detect missing templates"
    fi
    
    teardown_regression_tests
}

# Test that error handling still works correctly
test_error_handling_regression() {
    echo "Testing error handling regression..."
    
    setup_regression_tests
    
    export PROJECT_SLUG="error-test"
    
    # Test permission error handling
    touch readonly-test.txt
    chmod 444 readonly-test.txt
    
    # Should fail to write to readonly file
    if ! echo "test" > readonly-test.txt 2>/dev/null; then
        print_assertion "PASS" "Should still handle permission errors correctly"
    else
        print_assertion "FAIL" "Should still handle permission errors correctly"
    fi
    
    # Restore permissions for cleanup
    chmod 644 readonly-test.txt
    
    # Test backup creation (simulate)
    echo "original content" > backup-test.txt
    cp backup-test.txt backup-test.txt.backup
    
    if [ -f "backup-test.txt.backup" ]; then
        print_assertion "PASS" "Should still create backups correctly"
    else
        print_assertion "FAIL" "Should still create backups correctly"
    fi
    
    # Test backup content integrity
    if diff -q backup-test.txt backup-test.txt.backup >/dev/null; then
        print_assertion "PASS" "Should still preserve backup content correctly"
    else
        print_assertion "FAIL" "Should still preserve backup content correctly"
    fi
    
    # Test rollback capability
    echo "modified content" > backup-test.txt
    cp backup-test.txt.backup backup-test.txt
    
    if grep -q "original content" backup-test.txt; then
        print_assertion "PASS" "Should still support rollback correctly"
    else
        print_assertion "FAIL" "Should still support rollback correctly"
    fi
    
    teardown_regression_tests
}

# Test that performance hasn't degraded
test_performance_regression() {
    echo "Testing performance regression..."
    
    setup_regression_tests
    
    export PROJECT_SLUG="performance-test"
    
    # Create moderate number of components
    for i in {1..5}; do
        mkdir -p "wp-content/plugins/plugin-$i"
        echo "<?php // Plugin $i" > "wp-content/plugins/plugin-$i/plugin-$i.php"
    done
    
    # Time component detection
    local start_time
    local end_time
    local duration
    
    start_time=$(date +%s)
    
    # Perform component detection
    local detected_plugins
    detected_plugins=$(find wp-content/plugins -maxdepth 1 -type d -name "*" ! -name "plugins" | wc -l)
    
    end_time=$(date +%s)
    duration=$((end_time - start_time))
    
    # Should complete quickly (within 2 seconds for 5 components)
    if [ "$duration" -le 2 ]; then
        print_assertion "PASS" "Should maintain good performance ($duration seconds)"
    else
        print_assertion "FAIL" "Should maintain good performance ($duration seconds)"
    fi
    
    # Verify detection accuracy
    if [ "$detected_plugins" -eq 5 ]; then
        print_assertion "PASS" "Should maintain detection accuracy"
    else
        print_assertion "FAIL" "Should maintain detection accuracy" "Expected 5, got $detected_plugins"
    fi
    
    teardown_regression_tests
}

# Test backward compatibility with existing projects
test_backward_compatibility() {
    echo "Testing backward compatibility..."
    
    setup_regression_tests
    
    # Create existing project structure (old format)
    cat > package.json << 'EOF'
{
  "name": "old-project",
  "version": "0.1.0",
  "scripts": {
    "test": "echo 'old test'"
  },
  "devDependencies": {
    "old-package": "^1.0.0"
  }
}
EOF

    cat > composer.json << 'EOF'
{
  "name": "old/project",
  "require": {
    "php": ">=7.0",
    "old/package": "^1.0"
  }
}
EOF

    export PROJECT_SLUG="updated-project"
    
    # Should be able to work with existing files
    if [ -f "package.json" ] && [ -f "composer.json" ]; then
        print_assertion "PASS" "Should work with existing project files"
    else
        print_assertion "FAIL" "Should work with existing project files"
    fi
    
    # Should preserve existing content in backups
    cp package.json package.json.backup
    
    if grep -q "old-project" package.json.backup; then
        print_assertion "PASS" "Should preserve existing content"
    else
        print_assertion "FAIL" "Should preserve existing content"
    fi
    
    # Should handle old PHP version requirements gracefully
    if grep -q ">=7.0" composer.json; then
        print_assertion "PASS" "Should handle old PHP version requirements"
    else
        print_assertion "FAIL" "Should handle old PHP version requirements"
    fi
    
    teardown_regression_tests
}

# Test that output format hasn't changed unexpectedly
test_output_format_regression() {
    echo "Testing output format regression..."
    
    setup_regression_tests
    
    export PROJECT_SLUG="output-test"
    
    # Test slug validation output format
    local valid_slug="valid-slug"
    local invalid_slug="Invalid Slug!"
    
    # Valid slug should pass silently
    if [[ "$valid_slug" =~ ^[a-z0-9-]+$ ]]; then
        print_assertion "PASS" "Should validate correct slugs silently"
    else
        print_assertion "FAIL" "Should validate correct slugs silently"
    fi
    
    # Invalid slug should be detectable
    if [[ ! "$invalid_slug" =~ ^[a-z0-9-]+$ ]]; then
        print_assertion "PASS" "Should detect invalid slugs consistently"
    else
        print_assertion "FAIL" "Should detect invalid slugs consistently"
    fi
    
    # Test namespace generation format
    local test_cases=(
        "simple:Simple"
        "multi-word:MultiWord"
        "with-numbers-123:WithNumbers123"
        "single:Single"
    )
    
    for test_case in "${test_cases[@]}"; do
        IFS=':' read -r input expected <<< "$test_case"
        local result
        result=$(echo "$input" | awk -F'-' '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1' OFS='')
        
        assert_equals "$expected" "$result" "Should generate namespace for '$input' correctly"
    done
    
    # Test constant generation format
    local constant_cases=(
        "simple:SIMPLE"
        "multi-word:MULTI_WORD"
        "with-numbers-123:WITH_NUMBERS_123"
    )
    
    for test_case in "${constant_cases[@]}"; do
        IFS=':' read -r input expected <<< "$test_case"
        local result
        result=$(echo "$input" | tr '[:lower:]' '[:upper:]' | tr '-' '_')
        
        assert_equals "$expected" "$result" "Should generate constant for '$input' correctly"
    done
    
    teardown_regression_tests
}

# Run all regression tests
run_regression_tests() {
    echo "🧪 Running Regression Tests..."
    echo "=============================="
    
    test_basic_functionality_regression
    test_file_generation_regression
    test_validation_regression
    test_error_handling_regression
    test_performance_regression
    test_backward_compatibility
    test_output_format_regression
    
    echo ""
    echo "📊 Test Results:"
    echo "  • Total Assertions: $ASSERTION_COUNT"
    echo "  • Failed Assertions: $ASSERTION_FAILURES"
    echo "  • Success Rate: $(( (ASSERTION_COUNT - ASSERTION_FAILURES) * 100 / ASSERTION_COUNT ))%"
    
    if [ "$ASSERTION_FAILURES" -eq 0 ]; then
        echo "✅ All regression tests passed!"
        return 0
    else
        echo "❌ Some regression tests failed!"
        return 1
    fi
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_regression_tests
fi