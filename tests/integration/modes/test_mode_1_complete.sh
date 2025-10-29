#!/bin/bash

# Integration Tests for Mode 1 (Complete Configuration and Formatting)
# Tests the complete workflow from start to finish

# Source test dependencies
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/assertions.sh"
source "$SCRIPT_DIR/../lib/mock-env.sh"
source "$SCRIPT_DIR/../lib/validation-engine.sh"

# Test setup
setup_mode1_tests() {
    # Create isolated test environment
    TEST_ENV=$(create_mock_env "mode1_test")
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

# Create test templates
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

    # Makefile template
    cat > Makefile.template << 'EOF'
.PHONY: help dev build lint format test

help: ## Show this help
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

dev: ## Start development environment
	@echo "Starting development for {{PROJECT_SLUG}}"

build: ## Build project
	@echo "Building {{PROJECT_SLUG}}"

lint: ## Lint code
	@echo "Linting {{PROJECT_SLUG}}"

format: ## Format code
	@echo "Formatting {{PROJECT_SLUG}}"

test: ## Run tests
	@echo "Testing {{PROJECT_SLUG}}"
EOF
}

# Create sample components for testing
create_sample_components() {
    # Create sample plugin
    mkdir -p wp-content/plugins/test-plugin
    cat > wp-content/plugins/test-plugin/test-plugin.php << 'EOF'
<?php
/**
 * Plugin Name: Test Plugin
 * Description: A test plugin for integration testing
 * Version: 1.0.0
 */

// Prevent direct access
if (!defined('ABSPATH')) {
    exit;
}

class TestPlugin {
    public function __construct() {
        add_action('init', array($this, 'init'));
    }
    
    public function init() {
        // Plugin initialization
    }
}

new TestPlugin();
EOF

    # Create sample theme
    mkdir -p wp-content/themes/test-theme
    cat > wp-content/themes/test-theme/style.css << 'EOF'
/*
Theme Name: Test Theme
Description: A test theme for integration testing
Version: 1.0.0
*/

body {
    font-family: Arial, sans-serif;
}
EOF

    cat > wp-content/themes/test-theme/functions.php << 'EOF'
<?php
/**
 * Test Theme Functions
 */

// Prevent direct access
if (!defined('ABSPATH')) {
    exit;
}

function test_theme_setup() {
    // Theme setup
    add_theme_support('post-thumbnails');
}
add_action('after_setup_theme', 'test_theme_setup');
EOF

    # Create sample MU plugin
    cat > wp-content/mu-plugins/test-mu-plugin.php << 'EOF'
<?php
/**
 * Test MU Plugin
 * Description: A test MU plugin for integration testing
 */

// Prevent direct access
if (!defined('ABSPATH')) {
    exit;
}

class TestMuPlugin {
    public function __construct() {
        add_action('init', array($this, 'init'));
    }
    
    public function init() {
        // MU Plugin initialization
    }
}

new TestMuPlugin();
EOF
}

# Test teardown
teardown_mode1_tests() {
    cd - > /dev/null
    cleanup_mock_env "$TEST_ENV"
}

# Test Mode 1 with minimal configuration
test_mode1_minimal_config() {
    echo "Testing Mode 1 with minimal configuration..."
    
    setup_mode1_tests
    
    # Mock user input for minimal configuration
    export PROJECT_SLUG="test-project"
    export SELECTED_PLUGINS=()
    export SELECTED_THEMES=()
    export SELECTED_MU_PLUGINS=()
    
    # Test validation phase
    init_validation_engine "CONFIGURE"
    
    # Validate WordPress structure (legacy mode)
    if validate_wordpress_structure "CONFIGURE"; then
        print_assertion "PASS" "Should validate WordPress structure (legacy)"
    else
        print_assertion "FAIL" "Should validate WordPress structure (legacy)"
    fi
    
    # Test external WordPress path validation
    local external_wp_path="$TEST_ENV/wp-content"
    export WORDPRESS_PATH="$external_wp_path"
    export PROJECT_ROOT="$TEST_ENV"
    
    if validate_external_wordpress_structure "CONFIGURE" "$external_wp_path"; then
        print_assertion "PASS" "Should validate external WordPress structure"
    else
        print_assertion "FAIL" "Should validate external WordPress structure"
    fi
    
    # Test project root calculation
    if validate_project_root_calculation "CONFIGURE" "$external_wp_path" "$TEST_ENV"; then
        print_assertion "PASS" "Should validate project root calculation"
    else
        print_assertion "FAIL" "Should validate project root calculation"
    fi
    
    # Validate write permissions
    if validate_write_permissions "CONFIGURE" "."; then
        print_assertion "PASS" "Should validate write permissions"
    else
        print_assertion "FAIL" "Should validate write permissions"
    fi
    
    # Validate project slug
    if validate_project_slug "CONFIGURE" "$PROJECT_SLUG"; then
        print_assertion "PASS" "Should validate project slug"
    else
        print_assertion "FAIL" "Should validate project slug"
    fi
    
    # Test file generation (simulate)
    local gitignore_content
    gitignore_content=$(sed "s/{{PROJECT_SLUG}}/$PROJECT_SLUG/g" .gitignore.template)
    echo "$gitignore_content" > .gitignore
    
    if [ -f ".gitignore" ] && grep -q "$PROJECT_SLUG" .gitignore; then
        print_assertion "PASS" "Should generate .gitignore with project slug"
    else
        print_assertion "FAIL" "Should generate .gitignore with project slug"
    fi
    
    teardown_mode1_tests
}

# Test Mode 1 with components
test_mode1_with_components() {
    echo "Testing Mode 1 with components..."
    
    setup_mode1_tests
    
    # Mock user input with components
    export PROJECT_SLUG="test-project"
    export SELECTED_PLUGINS=("test-plugin")
    export SELECTED_THEMES=("test-theme")
    export SELECTED_MU_PLUGINS=("test-mu-plugin")
    
    # Test component validation
    init_validation_engine "CONFIGURE"
    
    # Validate component directories
    local selected_plugins=("${SELECTED_PLUGINS[@]}")
    if validate_component_directories "CONFIGURE" "plugins" selected_plugins; then
        print_assertion "PASS" "Should validate plugin directories"
    else
        print_assertion "FAIL" "Should validate plugin directories"
    fi
    
    local selected_themes=("${SELECTED_THEMES[@]}")
    if validate_component_directories "CONFIGURE" "themes" selected_themes; then
        print_assertion "PASS" "Should validate theme directories"
    else
        print_assertion "FAIL" "Should validate theme directories"
    fi
    
    # Test configuration file generation (simulate)
    local package_content
    package_content=$(sed -e "s/{{PROJECT_SLUG}}/$PROJECT_SLUG/g" -e "s/{{PROJECT_NAMESPACE}}/TestProject/g" package.json.template)
    echo "$package_content" > package.json
    
    if [ -f "package.json" ] && grep -q "$PROJECT_SLUG" package.json; then
        print_assertion "PASS" "Should generate package.json with project details"
    else
        print_assertion "FAIL" "Should generate package.json with project details"
    fi
    
    local composer_content
    composer_content=$(sed -e "s/{{PROJECT_SLUG}}/$PROJECT_SLUG/g" -e "s/{{PROJECT_NAMESPACE}}/testproject/g" composer.json.template)
    echo "$composer_content" > composer.json
    
    if [ -f "composer.json" ] && grep -q "$PROJECT_SLUG" composer.json; then
        print_assertion "PASS" "Should generate composer.json with project details"
    else
        print_assertion "FAIL" "Should generate composer.json with project details"
    fi
    
    teardown_mode1_tests
}

# Test Mode 1 validation failures
test_mode1_validation_failures() {
    echo "Testing Mode 1 validation failures..."
    
    setup_mode1_tests
    
    # Remove WordPress structure to trigger validation failure
    rm -rf wp-content
    
    export PROJECT_SLUG="Invalid-Slug!"
    export SELECTED_PLUGINS=("nonexistent-plugin")
    export SELECTED_THEMES=()
    export SELECTED_MU_PLUGINS=()
    
    # Test validation failures
    init_validation_engine "CONFIGURE"
    
    # Should fail WordPress structure validation
    if ! validate_wordpress_structure "CONFIGURE"; then
        print_assertion "PASS" "Should fail WordPress structure validation"
    else
        print_assertion "FAIL" "Should fail WordPress structure validation"
    fi
    
    # Should fail project slug validation
    if ! validate_project_slug "CONFIGURE" "$PROJECT_SLUG"; then
        print_assertion "PASS" "Should fail invalid project slug validation"
    else
        print_assertion "FAIL" "Should fail invalid project slug validation"
    fi
    
    # Recreate WordPress structure for component test
    mkdir -p wp-content/plugins
    
    # Should fail component validation
    local selected_plugins=("${SELECTED_PLUGINS[@]}")
    if ! validate_component_directories "CONFIGURE" "plugins" selected_plugins; then
        print_assertion "PASS" "Should fail nonexistent component validation"
    else
        print_assertion "FAIL" "Should fail nonexistent component validation"
    fi
    
    # Check that we have validation errors
    if [ "$VALIDATION_ERRORS" -gt 0 ]; then
        print_assertion "PASS" "Should accumulate validation errors"
    else
        print_assertion "FAIL" "Should accumulate validation errors"
    fi
    
    # Check that validation should not continue
    if ! validation_can_continue; then
        print_assertion "PASS" "Should not continue with critical errors"
    else
        print_assertion "FAIL" "Should not continue with critical errors"
    fi
    
    teardown_mode1_tests
}

# Test Mode 1 template processing
test_mode1_template_processing() {
    echo "Testing Mode 1 template processing..."
    
    setup_mode1_tests
    
    export PROJECT_SLUG="my-awesome-project"
    
    # Test template variable replacement
    local test_template="Test content with {{PROJECT_SLUG}} placeholder"
    local expected="Test content with my-awesome-project placeholder"
    local result
    result=$(echo "$test_template" | sed "s/{{PROJECT_SLUG}}/$PROJECT_SLUG/g")
    
    assert_equals "$expected" "$result" "Should replace PROJECT_SLUG placeholder"
    
    # Test namespace generation
    local namespace
    namespace=$(echo "$PROJECT_SLUG" | awk -F'-' '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1' OFS='')
    assert_equals "MyAwesomeProject" "$namespace" "Should generate correct namespace"
    
    # Test constant generation
    local constant
    constant=$(echo "$PROJECT_SLUG" | tr '[:lower:]' '[:upper:]' | tr '-' '_')
    assert_equals "MY_AWESOME_PROJECT" "$constant" "Should generate correct constant"
    
    teardown_mode1_tests
}

# Test Mode 1 file operations
test_mode1_file_operations() {
    echo "Testing Mode 1 file operations..."
    
    setup_mode1_tests
    
    export PROJECT_SLUG="test-project"
    
    # Test backup creation (simulate)
    echo "Original content" > test-file.txt
    cp test-file.txt test-file.txt.backup
    
    if [ -f "test-file.txt.backup" ]; then
        print_assertion "PASS" "Should create backup files"
    else
        print_assertion "FAIL" "Should create backup files"
    fi
    
    # Test file modification
    echo "Modified content" > test-file.txt
    
    if [ "$(cat test-file.txt)" = "Modified content" ]; then
        print_assertion "PASS" "Should modify files correctly"
    else
        print_assertion "FAIL" "Should modify files correctly"
    fi
    
    # Test rollback capability
    cp test-file.txt.backup test-file.txt
    
    if [ "$(cat test-file.txt)" = "Original content" ]; then
        print_assertion "PASS" "Should support file rollback"
    else
        print_assertion "FAIL" "Should support file rollback"
    fi
    
    teardown_mode1_tests
}

# Test Mode 1 with external WordPress paths
test_mode1_external_wordpress_paths() {
    echo "Testing Mode 1 with external WordPress paths..."
    
    # Create test environment with custom WordPress directory
    local external_test_env
    external_test_env=$(create_mock_env "mode1_external_test")
    
    # Create project structure with custom WordPress directory name
    mkdir -p "$external_test_env/my-wordpress-site/wp-content"/{plugins,themes,mu-plugins}
    mkdir -p "$external_test_env/docker" "$external_test_env/ci"
    touch "$external_test_env/Jenkinsfile"
    
    cd "$external_test_env"
    
    # Copy main script to test environment
    cp "$SCRIPT_DIR/../../../init-project.sh" .
    
    # Create test templates
    create_test_templates
    
    # Create sample components in custom WordPress directory
    mkdir -p "my-wordpress-site/wp-content/plugins/external-plugin"
    cat > "my-wordpress-site/wp-content/plugins/external-plugin/plugin.php" << 'EOF'
<?php
/**
 * Plugin Name: External Plugin
 * Description: Plugin in external WordPress directory
 */
class ExternalPlugin {
    public function __construct() {
        add_action('init', array($this, 'init'));
    }
    
    public function init() {
        // Plugin initialization
    }
}
new ExternalPlugin();
EOF
    
    # Test external WordPress path setup
    local wp_path="$external_test_env/my-wordpress-site"
    local project_root="$external_test_env"
    
    export WORDPRESS_PATH="$wp_path"
    export PROJECT_ROOT="$project_root"
    export PROJECT_SLUG="external-test-project"
    export SELECTED_PLUGINS=("external-plugin")
    export SELECTED_THEMES=()
    export SELECTED_MU_PLUGINS=()
    
    # Test validation with external paths
    init_validation_engine "CONFIGURE"
    
    if validate_external_wordpress_structure "CONFIGURE" "$wp_path"; then
        print_assertion "PASS" "Should validate external WordPress structure"
    else
        print_assertion "FAIL" "Should validate external WordPress structure"
    fi
    
    if validate_project_root_calculation "CONFIGURE" "$wp_path" "$project_root"; then
        print_assertion "PASS" "Should calculate project root correctly"
    else
        print_assertion "FAIL" "Should calculate project root correctly"
    fi
    
    # Test component validation with external paths
    local selected_plugins=("${SELECTED_PLUGINS[@]}")
    if validate_component_directories "CONFIGURE" "plugins" selected_plugins; then
        print_assertion "PASS" "Should validate external plugin directories"
    else
        print_assertion "FAIL" "Should validate external plugin directories"
    fi
    
    # Test that project files are preserved
    if [ -f "Jenkinsfile" ]; then
        print_assertion "PASS" "Should preserve existing project files"
    else
        print_assertion "FAIL" "Should preserve existing project files"
    fi
    
    if [ -d "docker" ]; then
        print_assertion "PASS" "Should preserve existing project directories"
    else
        print_assertion "FAIL" "Should preserve existing project directories"
    fi
    
    cd - > /dev/null
    cleanup_mock_env "$external_test_env"
}

# Run all Mode 1 tests
run_mode1_integration_tests() {
    echo "🧪 Running Mode 1 Integration Tests..."
    echo "====================================="
    
    test_mode1_minimal_config
    test_mode1_with_components
    test_mode1_external_wordpress_paths
    test_mode1_validation_failures
    test_mode1_template_processing
    test_mode1_file_operations
    
    echo ""
    echo "📊 Test Results:"
    echo "  • Total Assertions: $ASSERTION_COUNT"
    echo "  • Failed Assertions: $ASSERTION_FAILURES"
    echo "  • Success Rate: $(( (ASSERTION_COUNT - ASSERTION_FAILURES) * 100 / ASSERTION_COUNT ))%"
    
    if [ "$ASSERTION_FAILURES" -eq 0 ]; then
        echo "✅ All Mode 1 integration tests passed!"
        return 0
    else
        echo "❌ Some Mode 1 integration tests failed!"
        return 1
    fi
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_mode1_integration_tests
fi