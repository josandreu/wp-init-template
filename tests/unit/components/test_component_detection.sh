#!/bin/bash

# Unit Tests for Component Detection
# Tests component discovery and validation logic

# Source test dependencies
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/assertions.sh"
source "$SCRIPT_DIR/../../lib/mock-env.sh"

# Component detection functions (extracted from main script)
detect_custom_themes() {
    local themes_dir="$WP_CONTENT_DIR/themes"
    [ ! -d "$themes_dir" ] && { echo ""; return; }
    
    local -a custom_themes=()
    local exclude="twentytwentyone|twentytwentytwo|twentytwentythree|twentytwentyfour"
    
    for theme_dir in "$themes_dir"/*; do
        [ ! -d "$theme_dir" ] && continue
        local name=$(basename "$theme_dir")
        [[ "$name" =~ $exclude ]] && continue
        [ -f "$theme_dir/style.css" ] && custom_themes+=("$name")
    done
    
    echo "${custom_themes[@]}"
}

detect_custom_mu_plugins() {
    local mu_dir="$WP_CONTENT_DIR/mu-plugins"
    [ ! -d "$mu_dir" ] && { echo ""; return; }
    
    local -a custom_mu_plugins=()
    
    for mu_file in "$mu_dir"/*.php; do
        [ ! -f "$mu_file" ] && continue
        local name=$(basename "$mu_file" .php)
        custom_mu_plugins+=("$name")
    done
    
    for mu_dir_item in "$mu_dir"/*; do
        [ ! -d "$mu_dir_item" ] && continue
        local name=$(basename "$mu_dir_item")
        [ -n "$(find "$mu_dir_item" -maxdepth 2 -name "*.php" 2>/dev/null)" ] && custom_mu_plugins+=("$name")
    done
    
    echo "${custom_mu_plugins[@]}"
}

# Component validation function
validate_component_structure() {
    local component_type="$1"
    local component_name="$2"
    local component_path="$3"
    
    case "$component_type" in
        "plugin")
            # Plugin should have at least one PHP file
            if find "$component_path" -maxdepth 2 -name "*.php" -type f | head -1 | grep -q .; then
                return 0
            else
                return 1
            fi
            ;;
        "theme")
            # Theme should have style.css
            if [ -f "$component_path/style.css" ]; then
                return 0
            else
                return 1
            fi
            ;;
        "mu-plugin")
            # MU-Plugin should have PHP files
            if [ -f "$component_path.php" ] || find "$component_path" -maxdepth 2 -name "*.php" -type f 2>/dev/null | head -1 | grep -q .; then
                return 0
            else
                return 1
            fi
            ;;
        *)
            return 1
            ;;
    esac
}

# Test setup
setup_component_tests() {
    WP_CONTENT_DIR=""
}

# Test teardown
teardown_component_tests() {
    cleanup_mock_env
}

# Test detect_custom_themes function
test_detect_custom_themes() {
    echo "Testing detect_custom_themes..."
    
    setup_component_tests
    
    # Create test environment
    local test_env
    test_env=$(create_mock_env "themes_test")
    
    WP_CONTENT_DIR="$test_env/wp-content"
    mkdir -p "$WP_CONTENT_DIR/themes"
    
    # Test empty themes directory
    local result
    result=$(detect_custom_themes)
    assert_equals "" "$result" "Should return empty string for empty themes directory"
    
    # Create custom theme
    mkdir -p "$WP_CONTENT_DIR/themes/my-custom-theme"
    echo "/* Theme Name: My Custom Theme */" > "$WP_CONTENT_DIR/themes/my-custom-theme/style.css"
    
    result=$(detect_custom_themes)
    assert_equals "my-custom-theme" "$result" "Should detect custom theme"
    
    # Create excluded theme (should be ignored)
    mkdir -p "$WP_CONTENT_DIR/themes/twentytwentythree"
    echo "/* Theme Name: Twenty Twenty-Three */" > "$WP_CONTENT_DIR/themes/twentytwentythree/style.css"
    
    result=$(detect_custom_themes)
    assert_equals "my-custom-theme" "$result" "Should ignore excluded themes"
    
    # Create another custom theme
    mkdir -p "$WP_CONTENT_DIR/themes/another-theme"
    echo "/* Theme Name: Another Theme */" > "$WP_CONTENT_DIR/themes/another-theme/style.css"
    
    result=$(detect_custom_themes)
    # Result should contain both themes (order may vary)
    if [[ "$result" == *"my-custom-theme"* ]] && [[ "$result" == *"another-theme"* ]]; then
        print_assertion "PASS" "Should detect multiple custom themes"
    else
        print_assertion "FAIL" "Should detect multiple custom themes" "Got: $result"
    fi
    
    # Test directory without style.css (should be ignored)
    mkdir -p "$WP_CONTENT_DIR/themes/incomplete-theme"
    
    result=$(detect_custom_themes)
    if [[ "$result" != *"incomplete-theme"* ]]; then
        print_assertion "PASS" "Should ignore themes without style.css"
    else
        print_assertion "FAIL" "Should ignore themes without style.css"
    fi
    
    cleanup_mock_env "$test_env"
}

# Test detect_custom_mu_plugins function
test_detect_custom_mu_plugins() {
    echo "Testing detect_custom_mu_plugins..."
    
    setup_component_tests
    
    # Create test environment
    local test_env
    test_env=$(create_mock_env "mu_plugins_test")
    
    WP_CONTENT_DIR="$test_env/wp-content"
    mkdir -p "$WP_CONTENT_DIR/mu-plugins"
    
    # Test empty mu-plugins directory
    local result
    result=$(detect_custom_mu_plugins)
    assert_equals "" "$result" "Should return empty string for empty mu-plugins directory"
    
    # Create MU-plugin file
    echo "<?php // MU Plugin" > "$WP_CONTENT_DIR/mu-plugins/my-mu-plugin.php"
    
    result=$(detect_custom_mu_plugins)
    assert_equals "my-mu-plugin" "$result" "Should detect MU-plugin file"
    
    # Create MU-plugin directory
    mkdir -p "$WP_CONTENT_DIR/mu-plugins/my-mu-plugin-dir"
    echo "<?php // MU Plugin Dir" > "$WP_CONTENT_DIR/mu-plugins/my-mu-plugin-dir/init.php"
    
    result=$(detect_custom_mu_plugins)
    # Result should contain both MU-plugins (order may vary)
    if [[ "$result" == *"my-mu-plugin"* ]] && [[ "$result" == *"my-mu-plugin-dir"* ]]; then
        print_assertion "PASS" "Should detect both file and directory MU-plugins"
    else
        print_assertion "FAIL" "Should detect both file and directory MU-plugins" "Got: $result"
    fi
    
    # Test directory without PHP files (should be ignored)
    mkdir -p "$WP_CONTENT_DIR/mu-plugins/empty-dir"
    
    result=$(detect_custom_mu_plugins)
    if [[ "$result" != *"empty-dir"* ]]; then
        print_assertion "PASS" "Should ignore directories without PHP files"
    else
        print_assertion "FAIL" "Should ignore directories without PHP files"
    fi
    
    cleanup_mock_env "$test_env"
}

# Test validate_component_structure function
test_validate_component_structure() {
    echo "Testing validate_component_structure..."
    
    setup_component_tests
    
    # Create test environment
    local test_env
    test_env=$(create_mock_env "component_structure_test")
    
    # Test plugin validation
    mkdir -p "$test_env/test-plugin"
    echo "<?php // Plugin" > "$test_env/test-plugin/plugin.php"
    
    if validate_component_structure "plugin" "test-plugin" "$test_env/test-plugin"; then
        print_assertion "PASS" "Should validate plugin with PHP file"
    else
        print_assertion "FAIL" "Should validate plugin with PHP file"
    fi
    
    # Test plugin without PHP files
    mkdir -p "$test_env/empty-plugin"
    
    if ! validate_component_structure "plugin" "empty-plugin" "$test_env/empty-plugin"; then
        print_assertion "PASS" "Should reject plugin without PHP files"
    else
        print_assertion "FAIL" "Should reject plugin without PHP files"
    fi
    
    # Test theme validation
    mkdir -p "$test_env/test-theme"
    echo "/* Theme Name: Test */" > "$test_env/test-theme/style.css"
    
    if validate_component_structure "theme" "test-theme" "$test_env/test-theme"; then
        print_assertion "PASS" "Should validate theme with style.css"
    else
        print_assertion "FAIL" "Should validate theme with style.css"
    fi
    
    # Test theme without style.css
    mkdir -p "$test_env/empty-theme"
    
    if ! validate_component_structure "theme" "empty-theme" "$test_env/empty-theme"; then
        print_assertion "PASS" "Should reject theme without style.css"
    else
        print_assertion "FAIL" "Should reject theme without style.css"
    fi
    
    # Test MU-plugin validation (directory)
    mkdir -p "$test_env/test-mu-plugin"
    echo "<?php // MU Plugin" > "$test_env/test-mu-plugin/init.php"
    
    if validate_component_structure "mu-plugin" "test-mu-plugin" "$test_env/test-mu-plugin"; then
        print_assertion "PASS" "Should validate MU-plugin directory with PHP file"
    else
        print_assertion "FAIL" "Should validate MU-plugin directory with PHP file"
    fi
    
    # Test MU-plugin validation (file)
    echo "<?php // MU Plugin File" > "$test_env/test-mu-file.php"
    
    if validate_component_structure "mu-plugin" "test-mu-file" "$test_env/test-mu-file"; then
        print_assertion "PASS" "Should validate MU-plugin file"
    else
        print_assertion "FAIL" "Should validate MU-plugin file"
    fi
    
    # Test invalid component type
    if ! validate_component_structure "invalid" "test" "$test_env/test"; then
        print_assertion "PASS" "Should reject invalid component type"
    else
        print_assertion "FAIL" "Should reject invalid component type"
    fi
    
    cleanup_mock_env "$test_env"
}

# Test with non-existent directories
test_detect_components_no_directory() {
    echo "Testing component detection with non-existent directories..."
    
    setup_component_tests
    
    WP_CONTENT_DIR="/nonexistent/path"
    
    local result
    
    result=$(detect_custom_themes)
    assert_equals "" "$result" "Should return empty string when themes directory doesn't exist"
    
    result=$(detect_custom_mu_plugins)
    assert_equals "" "$result" "Should return empty string when mu-plugins directory doesn't exist"
}

# Test component detection with complex structures
test_detect_components_complex_structure() {
    echo "Testing component detection with complex structures..."
    
    setup_component_tests
    
    # Create test environment
    local test_env
    test_env=$(create_mock_env "complex_structure_test")
    
    WP_CONTENT_DIR="$test_env/wp-content"
    mkdir -p "$WP_CONTENT_DIR/themes"
    mkdir -p "$WP_CONTENT_DIR/mu-plugins"
    
    # Create theme with subdirectories
    mkdir -p "$WP_CONTENT_DIR/themes/complex-theme/assets/css"
    mkdir -p "$WP_CONTENT_DIR/themes/complex-theme/includes"
    echo "/* Theme Name: Complex Theme */" > "$WP_CONTENT_DIR/themes/complex-theme/style.css"
    echo "<?php // Functions" > "$WP_CONTENT_DIR/themes/complex-theme/functions.php"
    
    local result
    result=$(detect_custom_themes)
    assert_equals "complex-theme" "$result" "Should detect theme with complex structure"
    
    # Create MU-plugin with nested PHP files
    mkdir -p "$WP_CONTENT_DIR/mu-plugins/complex-mu/includes"
    echo "<?php // Main MU Plugin" > "$WP_CONTENT_DIR/mu-plugins/complex-mu/main.php"
    echo "<?php // Helper" > "$WP_CONTENT_DIR/mu-plugins/complex-mu/includes/helper.php"
    
    result=$(detect_custom_mu_plugins)
    assert_equals "complex-mu" "$result" "Should detect MU-plugin with nested structure"
    
    cleanup_mock_env "$test_env"
}

# Run all tests
run_component_detection_tests() {
    echo "🧪 Running Component Detection Unit Tests..."
    echo "============================================="
    
    test_detect_custom_themes
    test_detect_custom_mu_plugins
    test_validate_component_structure
    test_detect_components_no_directory
    test_detect_components_complex_structure
    
    echo ""
    echo "📊 Test Results:"
    echo "  • Total Assertions: $ASSERTION_COUNT"
    echo "  • Failed Assertions: $ASSERTION_FAILURES"
    echo "  • Success Rate: $(( (ASSERTION_COUNT - ASSERTION_FAILURES) * 100 / ASSERTION_COUNT ))%"
    
    if [ "$ASSERTION_FAILURES" -eq 0 ]; then
        echo "✅ All component detection tests passed!"
        return 0
    else
        echo "❌ Some component detection tests failed!"
        return 1
    fi
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_component_detection_tests
fi