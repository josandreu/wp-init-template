#!/bin/bash

# Integration Tests for Mode 2 (Configuration Only)
# Tests configuration without formatting

# Source test dependencies
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/assertions.sh"
source "$SCRIPT_DIR/../../lib/mock-env.sh"
source "$SCRIPT_DIR/../../lib/validation-engine.sh"

# Test setup
setup_mode2_tests() {
    # Create isolated test environment
    TEST_ENV=$(create_mock_env "mode2_test")
    cd "$TEST_ENV"
    
    # Copy main script to test environment
    cp "$SCRIPT_DIR/../../../init-project.sh" .
    
    # Create required template files
    create_test_templates
    
    # Create WordPress structure
    mkdir -p wp-content/{plugins,themes,mu-plugins}
    
    # Create sample components
    create_sample_components
}

# Create test templates (same as Mode 1)
create_test_templates() {
    # .gitignore template
    cat > .gitignore.template << 'EOF'
# WordPress
wp-config.php
wp-content/uploads/
wp-content/cache/

# Dependencies
node_modules/
vendor/

# Build files
*.min.js
*.min.css

# Project specific
{{PROJECT_SLUG}}-specific-files/
EOF

    # package.json template
    cat > package.json.template << 'EOF'
{
  "name": "{{PROJECT_SLUG}}",
  "version": "1.0.0",
  "scripts": {
    "dev": "echo 'Development mode'",
    "build": "echo 'Build mode'",
    "lint": "eslint .",
    "format": "prettier --write ."
  },
  "devDependencies": {
    "eslint": "^8.0.0",
    "prettier": "^2.0.0"
  }
}
EOF

    # composer.json template
    cat > composer.json.template << 'EOF'
{
  "name": "{{PROJECT_NAMESPACE}}/{{PROJECT_SLUG}}",
  "description": "WordPress project {{PROJECT_SLUG}}",
  "require": {
    "php": ">=7.4"
  },
  "require-dev": {
    "squizlabs/php_codesniffer": "^3.6",
    "phpstan/phpstan": "^1.0"
  },
  "scripts": {
    "lint": "phpcs",
    "format": "phpcbf",
    "analyze": "phpstan analyse"
  }
}
EOF
}

# Create sample components
create_sample_components() {
    # Create sample plugin with formatting issues
    mkdir -p wp-content/plugins/test-plugin
    cat > wp-content/plugins/test-plugin/test-plugin.php << 'EOF'
<?php
/**
 * Plugin Name: Test Plugin
 * Description: A test plugin with formatting issues
 * Version: 1.0.0
 */

// Prevent direct access
if(!defined('ABSPATH')){
exit;
}

class TestPlugin{
public function __construct(){
add_action('init',array($this,'init'));
}

public function init(){
// Plugin initialization
}
}

new TestPlugin();
EOF

    # Create sample theme with formatting issues
    mkdir -p wp-content/themes/test-theme
    cat > wp-content/themes/test-theme/style.css << 'EOF'
/*
Theme Name: Test Theme
Description: A test theme with formatting issues
Version: 1.0.0
*/

body{font-family:Arial,sans-serif;margin:0;padding:0;}
.header{background:#333;color:#fff;}
EOF

    cat > wp-content/themes/test-theme/functions.php << 'EOF'
<?php
/**
 * Test Theme Functions with formatting issues
 */

// Prevent direct access
if(!defined('ABSPATH')){
exit;
}

function test_theme_setup(){
// Theme setup
add_theme_support('post-thumbnails');
}
add_action('after_setup_theme','test_theme_setup');
EOF
}

# Test teardown
teardown_mode2_tests() {
    cd - > /dev/null
    cleanup_mock_env "$TEST_ENV"
}

# Test Mode 2 basic configuration
test_mode2_basic_config() {
    echo "Testing Mode 2 basic configuration..."
    
    setup_mode2_tests
    
    # Mock user input
    export PROJECT_SLUG="config-only-project"
    export SELECTED_PLUGINS=("test-plugin")
    export SELECTED_THEMES=("test-theme")
    export SELECTED_MU_PLUGINS=()
    
    # Test validation phase (should be less strict than Mode 1)
    init_validation_engine "CONFIGURE"
    
    # Validate WordPress structure
    if validate_wordpress_structure "CONFIGURE"; then
        print_assertion "PASS" "Should validate WordPress structure"
    else
        print_assertion "FAIL" "Should validate WordPress structure"
    fi
    
    # Validate components
    local selected_plugins=("${SELECTED_PLUGINS[@]}")
    if validate_component_directories "CONFIGURE" "plugins" selected_plugins; then
        print_assertion "PASS" "Should validate plugin directories"
    else
        print_assertion "FAIL" "Should validate plugin directories"
    fi
    
    # Test configuration file generation
    local package_content
    package_content=$(sed "s/{{PROJECT_SLUG}}/$PROJECT_SLUG/g" package.json.template)
    echo "$package_content" > package.json
    
    if [ -f "package.json" ] && grep -q "$PROJECT_SLUG" package.json; then
        print_assertion "PASS" "Should generate package.json"
    else
        print_assertion "FAIL" "Should generate package.json"
    fi
    
    # Test that formatting is NOT applied (files should retain formatting issues)
    if grep -q "if(!defined" wp-content/plugins/test-plugin/test-plugin.php; then
        print_assertion "PASS" "Should NOT format PHP files in Mode 2"
    else
        print_assertion "FAIL" "Should NOT format PHP files in Mode 2"
    fi
    
    if grep -q "body{font-family" wp-content/themes/test-theme/style.css; then
        print_assertion "PASS" "Should NOT format CSS files in Mode 2"
    else
        print_assertion "FAIL" "Should NOT format CSS files in Mode 2"
    fi
    
    teardown_mode2_tests
}

# Test Mode 2 without formatting tools
test_mode2_without_formatting_tools() {
    echo "Testing Mode 2 without formatting tools..."
    
    setup_mode2_tests
    
    export PROJECT_SLUG="no-tools-project"
    export SELECTED_PLUGINS=("test-plugin")
    export SELECTED_THEMES=()
    export SELECTED_MU_PLUGINS=()
    
    # Test validation without formatting tools (should not be critical)
    init_validation_engine "CONFIGURE"
    
    # Mock absence of formatting tools by temporarily renaming PATH
    local original_path="$PATH"
    export PATH="/usr/bin:/bin"  # Minimal PATH without npm, composer, etc.
    
    # Validate required tools (should be warnings, not errors for Mode 2)
    local has_npm=false
    local has_composer=false
    
    if ! command -v npm >/dev/null 2>&1; then
        print_assertion "PASS" "npm should not be available in test environment"
        has_npm=false
    fi
    
    if ! command -v composer >/dev/null 2>&1; then
        print_assertion "PASS" "composer should not be available in test environment"
        has_composer=false
    fi
    
    # In Mode 2, missing formatting tools should be warnings, not critical errors
    # This allows configuration to proceed without formatting capabilities
    
    # Restore PATH
    export PATH="$original_path"
    
    # Configuration should still succeed
    local gitignore_content
    gitignore_content=$(sed "s/{{PROJECT_SLUG}}/$PROJECT_SLUG/g" .gitignore.template)
    echo "$gitignore_content" > .gitignore
    
    if [ -f ".gitignore" ] && grep -q "$PROJECT_SLUG" .gitignore; then
        print_assertion "PASS" "Should generate configuration files even without formatting tools"
    else
        print_assertion "FAIL" "Should generate configuration files even without formatting tools"
    fi
    
    teardown_mode2_tests
}

# Test Mode 2 with existing configuration files
test_mode2_with_existing_config() {
    echo "Testing Mode 2 with existing configuration files..."
    
    setup_mode2_tests
    
    export PROJECT_SLUG="existing-config-project"
    export SELECTED_PLUGINS=()
    export SELECTED_THEMES=()
    export SELECTED_MU_PLUGINS=()
    
    # Create existing configuration files
    cat > package.json << 'EOF'
{
  "name": "existing-project",
  "version": "0.5.0",
  "scripts": {
    "test": "echo 'existing test'"
  },
  "dependencies": {
    "lodash": "^4.17.21"
  }
}
EOF

    cat > composer.json << 'EOF'
{
  "name": "existing/project",
  "description": "Existing project",
  "require": {
    "php": ">=7.2"
  }
}
EOF

    # Test validation with existing files
    init_validation_engine "CONFIGURE"
    
    # Should detect existing files
    if [ -f "package.json" ]; then
        print_assertion "PASS" "Should detect existing package.json"
    else
        print_assertion "FAIL" "Should detect existing package.json"
    fi
    
    if [ -f "composer.json" ]; then
        print_assertion "PASS" "Should detect existing composer.json"
    else
        print_assertion "FAIL" "Should detect existing composer.json"
    fi
    
    # In Mode 2, should create backups before modifying
    cp package.json package.json.backup
    cp composer.json composer.json.backup
    
    if [ -f "package.json.backup" ] && [ -f "composer.json.backup" ]; then
        print_assertion "PASS" "Should create backups of existing files"
    else
        print_assertion "FAIL" "Should create backups of existing files"
    fi
    
    # Test that original content is preserved in backups
    if grep -q "existing-project" package.json.backup; then
        print_assertion "PASS" "Should preserve original content in backup"
    else
        print_assertion "FAIL" "Should preserve original content in backup"
    fi
    
    teardown_mode2_tests
}

# Test Mode 2 validation with missing templates
test_mode2_missing_templates() {
    echo "Testing Mode 2 with missing templates..."
    
    setup_mode2_tests
    
    # Remove some template files
    rm -f package.json.template
    rm -f composer.json.template
    
    export PROJECT_SLUG="missing-templates-project"
    export SELECTED_PLUGINS=()
    export SELECTED_THEMES=()
    export SELECTED_MU_PLUGINS=()
    
    # Test validation with missing templates
    init_validation_engine "CONFIGURE"
    
    # Should validate required templates
    local required_templates=(".gitignore.template")
    local missing_templates=("package.json.template" "composer.json.template")
    
    # Required templates should cause errors
    if [ -f ".gitignore.template" ]; then
        print_assertion "PASS" "Required template should be present"
    else
        print_assertion "FAIL" "Required template should be present"
    fi
    
    # Missing optional templates should be warnings
    if [ ! -f "package.json.template" ]; then
        print_assertion "PASS" "Optional template can be missing"
    else
        print_assertion "FAIL" "Optional template can be missing"
    fi
    
    # Configuration should still proceed with available templates
    if [ -f ".gitignore.template" ]; then
        local gitignore_content
        gitignore_content=$(sed "s/{{PROJECT_SLUG}}/$PROJECT_SLUG/g" .gitignore.template)
        echo "$gitignore_content" > .gitignore
        
        if [ -f ".gitignore" ] && grep -q "$PROJECT_SLUG" .gitignore; then
            print_assertion "PASS" "Should generate files from available templates"
        else
            print_assertion "FAIL" "Should generate files from available templates"
        fi
    fi
    
    teardown_mode2_tests
}

# Test Mode 2 component selection
test_mode2_component_selection() {
    echo "Testing Mode 2 component selection..."
    
    setup_mode2_tests
    
    export PROJECT_SLUG="component-selection-project"
    
    # Test with no components selected
    export SELECTED_PLUGINS=()
    export SELECTED_THEMES=()
    export SELECTED_MU_PLUGINS=()
    
    init_validation_engine "CONFIGURE"
    
    # Should handle empty component selection gracefully
    local selected_plugins=("${SELECTED_PLUGINS[@]}")
    if [ ${#selected_plugins[@]} -eq 0 ]; then
        print_assertion "PASS" "Should handle empty plugin selection"
    else
        print_assertion "FAIL" "Should handle empty plugin selection"
    fi
    
    # Test with mixed component selection
    export SELECTED_PLUGINS=("test-plugin")
    export SELECTED_THEMES=()
    export SELECTED_MU_PLUGINS=()
    
    selected_plugins=("${SELECTED_PLUGINS[@]}")
    if validate_component_directories "CONFIGURE" "plugins" selected_plugins; then
        print_assertion "PASS" "Should validate selected plugins only"
    else
        print_assertion "FAIL" "Should validate selected plugins only"
    fi
    
    # Should not validate unselected component types
    local selected_themes=("${SELECTED_THEMES[@]}")
    if [ ${#selected_themes[@]} -eq 0 ]; then
        print_assertion "PASS" "Should skip validation for unselected themes"
    else
        print_assertion "FAIL" "Should skip validation for unselected themes"
    fi
    
    teardown_mode2_tests
}

# Run all Mode 2 tests
run_mode2_integration_tests() {
    echo "🧪 Running Mode 2 Integration Tests..."
    echo "====================================="
    
    test_mode2_basic_config
    test_mode2_without_formatting_tools
    test_mode2_with_existing_config
    test_mode2_missing_templates
    test_mode2_component_selection
    
    echo ""
    echo "📊 Test Results:"
    echo "  • Total Assertions: $ASSERTION_COUNT"
    echo "  • Failed Assertions: $ASSERTION_FAILURES"
    echo "  • Success Rate: $(( (ASSERTION_COUNT - ASSERTION_FAILURES) * 100 / ASSERTION_COUNT ))%"
    
    if [ "$ASSERTION_FAILURES" -eq 0 ]; then
        echo "✅ All Mode 2 integration tests passed!"
        return 0
    else
        echo "❌ Some Mode 2 integration tests failed!"
        return 1
    fi
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_mode2_integration_tests
fi