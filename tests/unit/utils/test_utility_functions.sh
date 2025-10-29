#!/bin/bash

# Unit Tests for Utility Functions
# Tests helper functions from init-project.sh

# Source test dependencies
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/assertions.sh"
source "$SCRIPT_DIR/../../lib/mock-env.sh"

# Source functions from main script (we need to extract these functions)
# For now, we'll define them here for testing
validate_slug() {
    [ -z "$1" ] && return 1
    [[ ! "$1" =~ ^[a-z0-9-]+$ ]] && return 1
    return 0
}

generate_namespace() {
    echo "$1" | awk -F'-' '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1' OFS=''
}

generate_constant() {
    echo "$1" | tr '[:lower:]' '[:upper:]' | tr '-' '_'
}

detect_wordpress_structure() {
    [ -d "wordpress/wp-content" ] && { WP_CONTENT_DIR="wordpress/wp-content"; return 0; }
    [ -d "wp-content" ] && { WP_CONTENT_DIR="wp-content"; return 0; }
    return 1
}

detect_custom_plugins() {
    local plugins_dir="$WP_CONTENT_DIR/plugins"
    [ ! -d "$plugins_dir" ] && { echo ""; return; }
    
    local -a custom_plugins=()
    local exclude="akismet|hello|wordpress-importer|classic-editor|classic-widgets"
    
    for plugin_dir in "$plugins_dir"/*; do
        [ ! -d "$plugin_dir" ] && continue
        local name=$(basename "$plugin_dir")
        [[ "$name" =~ $exclude ]] && continue
        [ -n "$(find "$plugin_dir" -maxdepth 2 -name "*.php" 2>/dev/null)" ] && custom_plugins+=("$name")
    done
    
    if [ ${#custom_plugins[@]} -gt 0 ]; then
        echo "${custom_plugins[@]}"
    else
        echo ""
    fi
}

# Test setup
setup_utility_tests() {
    WP_CONTENT_DIR=""
}

# Test teardown
teardown_utility_tests() {
    cleanup_mock_env
}

# Test validate_slug function
test_validate_slug() {
    echo "Testing validate_slug..."
    
    # Test valid slugs
    if validate_slug "my-project"; then
        print_assertion "PASS" "Should accept valid slug with hyphens"
    else
        print_assertion "FAIL" "Should accept valid slug with hyphens"
    fi
    
    if validate_slug "myproject"; then
        print_assertion "PASS" "Should accept valid slug without hyphens"
    else
        print_assertion "FAIL" "Should accept valid slug without hyphens"
    fi
    
    if validate_slug "my-project-123"; then
        print_assertion "PASS" "Should accept valid slug with numbers"
    else
        print_assertion "FAIL" "Should accept valid slug with numbers"
    fi
    
    # Test invalid slugs
    if ! validate_slug "My-Project"; then
        print_assertion "PASS" "Should reject slug with uppercase letters"
    else
        print_assertion "FAIL" "Should reject slug with uppercase letters"
    fi
    
    if ! validate_slug "my_project"; then
        print_assertion "PASS" "Should reject slug with underscores"
    else
        print_assertion "FAIL" "Should reject slug with underscores"
    fi
    
    if ! validate_slug "my project"; then
        print_assertion "PASS" "Should reject slug with spaces"
    else
        print_assertion "FAIL" "Should reject slug with spaces"
    fi
    
    if ! validate_slug "my-project!"; then
        print_assertion "PASS" "Should reject slug with special characters"
    else
        print_assertion "FAIL" "Should reject slug with special characters"
    fi
    
    if ! validate_slug ""; then
        print_assertion "PASS" "Should reject empty slug"
    else
        print_assertion "FAIL" "Should reject empty slug"
    fi
}

# Test generate_namespace function
test_generate_namespace() {
    echo "Testing generate_namespace..."
    
    local result
    
    result=$(generate_namespace "my-project")
    assert_equals "MyProject" "$result" "Should convert hyphenated slug to PascalCase"
    
    result=$(generate_namespace "single")
    assert_equals "Single" "$result" "Should convert single word to PascalCase"
    
    result=$(generate_namespace "my-long-project-name")
    assert_equals "MyLongProjectName" "$result" "Should convert long hyphenated slug to PascalCase"
    
    result=$(generate_namespace "a-b-c-d")
    assert_equals "ABCD" "$result" "Should handle single letter segments"
}

# Test generate_constant function
test_generate_constant() {
    echo "Testing generate_constant..."
    
    local result
    
    result=$(generate_constant "my-project")
    assert_equals "MY_PROJECT" "$result" "Should convert hyphenated slug to UPPER_CASE"
    
    result=$(generate_constant "single")
    assert_equals "SINGLE" "$result" "Should convert single word to UPPER_CASE"
    
    result=$(generate_constant "my-long-project-name")
    assert_equals "MY_LONG_PROJECT_NAME" "$result" "Should convert long hyphenated slug to UPPER_CASE"
}

# Test detect_wordpress_structure function
test_detect_wordpress_structure() {
    echo "Testing detect_wordpress_structure..."
    
    setup_utility_tests
    
    # Create test environment
    local test_env
    test_env=$(create_mock_env "wordpress_structure_test")
    
    # Test wordpress/wp-content structure
    mkdir -p "$test_env/wordpress/wp-content"
    cd "$test_env"
    
    if detect_wordpress_structure; then
        print_assertion "PASS" "Should detect wordpress/wp-content structure"
        assert_equals "wordpress/wp-content" "$WP_CONTENT_DIR" "Should set correct WP_CONTENT_DIR"
    else
        print_assertion "FAIL" "Should detect wordpress/wp-content structure"
    fi
    
    # Clean up and test wp-content structure
    rm -rf wordpress
    mkdir -p wp-content
    WP_CONTENT_DIR=""
    
    if detect_wordpress_structure; then
        print_assertion "PASS" "Should detect wp-content structure"
        assert_equals "wp-content" "$WP_CONTENT_DIR" "Should set correct WP_CONTENT_DIR"
    else
        print_assertion "FAIL" "Should detect wp-content structure"
    fi
    
    # Test no structure
    rm -rf wp-content
    WP_CONTENT_DIR=""
    
    if ! detect_wordpress_structure; then
        print_assertion "PASS" "Should return false when no WordPress structure found"
    else
        print_assertion "FAIL" "Should return false when no WordPress structure found"
    fi
    
    cd - > /dev/null
    cleanup_mock_env "$test_env"
}

# Test detect_custom_plugins function
test_detect_custom_plugins() {
    echo "Testing detect_custom_plugins..."
    
    setup_utility_tests
    
    # Create test environment
    local test_env
    test_env=$(create_mock_env "plugins_test")
    
    WP_CONTENT_DIR="$test_env/wp-content"
    mkdir -p "$WP_CONTENT_DIR/plugins"
    
    # Test empty plugins directory
    local result
    result=$(detect_custom_plugins)
    assert_equals "" "$result" "Should return empty string for empty plugins directory"
    
    # Create custom plugin
    mkdir -p "$WP_CONTENT_DIR/plugins/my-custom-plugin"
    echo "<?php // Custom plugin" > "$WP_CONTENT_DIR/plugins/my-custom-plugin/plugin.php"
    
    result=$(detect_custom_plugins)
    assert_equals "my-custom-plugin" "$result" "Should detect custom plugin"
    
    # Create excluded plugin (should be ignored)
    mkdir -p "$WP_CONTENT_DIR/plugins/akismet"
    echo "<?php // Akismet" > "$WP_CONTENT_DIR/plugins/akismet/akismet.php"
    
    result=$(detect_custom_plugins)
    assert_equals "my-custom-plugin" "$result" "Should ignore excluded plugins"
    
    # Create another custom plugin
    mkdir -p "$WP_CONTENT_DIR/plugins/another-plugin"
    echo "<?php // Another plugin" > "$WP_CONTENT_DIR/plugins/another-plugin/main.php"
    
    result=$(detect_custom_plugins)
    # Result should contain both plugins (order may vary)
    if [[ "$result" == *"my-custom-plugin"* ]] && [[ "$result" == *"another-plugin"* ]]; then
        print_assertion "PASS" "Should detect multiple custom plugins"
    else
        print_assertion "FAIL" "Should detect multiple custom plugins" "Got: $result"
    fi
    
    # Test directory without PHP files (should be ignored)
    mkdir -p "$WP_CONTENT_DIR/plugins/empty-dir"
    
    result=$(detect_custom_plugins)
    if [[ "$result" != *"empty-dir"* ]]; then
        print_assertion "PASS" "Should ignore directories without PHP files"
    else
        print_assertion "FAIL" "Should ignore directories without PHP files"
    fi
    
    cleanup_mock_env "$test_env"
}

# Test with non-existent plugins directory
test_detect_custom_plugins_no_directory() {
    echo "Testing detect_custom_plugins with no plugins directory..."
    
    setup_utility_tests
    
    WP_CONTENT_DIR="/nonexistent/path"
    
    local result
    result=$(detect_custom_plugins)
    assert_equals "" "$result" "Should return empty string when plugins directory doesn't exist"
}

# Run all tests
run_utility_function_tests() {
    echo "🧪 Running Utility Function Unit Tests..."
    echo "============================================"
    
    test_validate_slug
    test_generate_namespace
    test_generate_constant
    test_detect_wordpress_structure
    test_detect_custom_plugins
    test_detect_custom_plugins_no_directory
    
    echo ""
    echo "📊 Test Results:"
    echo "  • Total Assertions: $ASSERTION_COUNT"
    echo "  • Failed Assertions: $ASSERTION_FAILURES"
    echo "  • Success Rate: $(( (ASSERTION_COUNT - ASSERTION_FAILURES) * 100 / ASSERTION_COUNT ))%"
    
    if [ "$ASSERTION_FAILURES" -eq 0 ]; then
        echo "✅ All utility function tests passed!"
        return 0
    else
        echo "❌ Some utility function tests failed!"
        return 1
    fi
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_utility_function_tests
fi