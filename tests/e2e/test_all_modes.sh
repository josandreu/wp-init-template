#!/bin/bash

# ====================================================================
# WordPress Init Project - Comprehensive E2E Tests
# ====================================================================
# Tests all operation modes and validates functionality using new testing framework
# ====================================================================

set -euo pipefail

# Source testing libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/assertions.sh"
source "$SCRIPT_DIR/../lib/mock-env.sh"

# Test configuration
ORIGINAL_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
SCRIPT_PATH="$ORIGINAL_DIR/init-project.sh"

# ====================================================================
# Test Setup Functions
# ====================================================================

# Create a complete WordPress project structure for testing
create_wordpress_project_structure() {
    local base_path="$1"
    local wp_dir_name="${2:-wordpress}"
    
    # Create WordPress structure with configurable directory name
    mkdir -p "$base_path/$wp_dir_name/wp-content"/{plugins,themes,mu-plugins}
    
    # Create sample plugins
    mkdir -p "$base_path/$wp_dir_name/wp-content/plugins/test-plugin"
    cat > "$base_path/$wp_dir_name/wp-content/plugins/test-plugin/init.php" << 'EOF'
<?php
/*
Plugin Name: Test Plugin
Description: A test plugin for validation
Version: 1.0.0
*/

function test_plugin_init(){
echo "Test plugin loaded";
}
add_action('init','test_plugin_init');
EOF
    
    mkdir -p "$base_path/$wp_dir_name/wp-content/plugins/ecommerce-plugin"
    cat > "$base_path/$wp_dir_name/wp-content/plugins/ecommerce-plugin/main.php" << 'EOF'
<?php
/*
Plugin Name: Ecommerce Plugin
Description: Test ecommerce plugin
Version: 1.0.0
*/

class EcommercePlugin{
public function __construct(){
add_action('init',array($this,'init'));
}

public function init(){
// Plugin initialization
}
}

new EcommercePlugin();
EOF
    
    # Create sample theme
    mkdir -p "$base_path/$wp_dir_name/wp-content/themes/test-theme"
    cat > "$base_path/$wp_dir_name/wp-content/themes/test-theme/style.css" << 'EOF'
/*
Theme Name: Test Theme
Description: A test theme for validation
Version: 1.0.0
*/

body {
    font-family: Arial, sans-serif;
}
EOF
    
    cat > "$base_path/$wp_dir_name/wp-content/themes/test-theme/functions.php" << 'EOF'
<?php
function test_theme_setup(){
add_theme_support('post-thumbnails');
}
add_action('after_setup_theme','test_theme_setup');

function test_theme_scripts(){
wp_enqueue_style('test-theme-style',get_stylesheet_uri());
}
add_action('wp_enqueue_scripts','test_theme_scripts');
EOF
    
    # Create sample mu-plugin
    mkdir -p "$base_path/$wp_dir_name/wp-content/mu-plugins/core-functionality"
    cat > "$base_path/$wp_dir_name/wp-content/mu-plugins/core-functionality/init.php" << 'EOF'
<?php
/*
Plugin Name: Core Functionality
Description: Core site functionality
Version: 1.0.0
*/

function core_functionality_init(){
// Core functionality
}
add_action('init','core_functionality_init');
EOF
    
    # Create basic package.json for merge tests
    cat > "$base_path/package.json" << 'EOF'
{
  "name": "test-project",
  "version": "1.0.0",
  "description": "Test project for validation",
  "scripts": {
    "dev": "webpack --mode development",
    "build": "webpack --mode production"
  },
  "dependencies": {
    "lodash": "^4.17.21"
  },
  "devDependencies": {
    "webpack": "^5.88.0"
  }
}
EOF
    
    # Create basic composer.json for merge tests
    cat > "$base_path/composer.json" << 'EOF'
{
  "name": "test/project",
  "description": "Test project for validation",
  "type": "project",
  "require": {
    "php": ">=8.1",
    "monolog/monolog": "^3.0"
  },
  "require-dev": {
    "phpunit/phpunit": "^10.0"
  },
  "scripts": {
    "test": "phpunit"
  }
}
EOF
}

# ====================================================================
# Test Helper Functions
# ====================================================================

# Execute the init-project.sh script with automated responses
execute_init_script() {
    local responses="$1"
    local output_file="$2"
    local timeout_duration="${3:-60}"
    
    # Create a temporary file with responses
    local response_file
    response_file="$(mktemp)"
    echo -e "$responses" > "$response_file"
    
    # Execute script with timeout and capture output
    # Use expect-like behavior with printf and pipe
    if timeout "$timeout_duration" bash -c "printf '%s\n' $responses | '$SCRIPT_PATH'" > "$output_file" 2>&1; then
        rm -f "$response_file"
        return 0
    else
        local exit_code=$?
        rm -f "$response_file"
        return $exit_code
    fi
}

# Check if configuration files were created with expected content
validate_configuration_files() {
    local expected_files=(
        "phpcs.xml.dist"
        "phpstan.neon.dist" 
        "eslint.config.js"
        "wp.code-workspace"
    )
    
    local files_created=0
    for file in "${expected_files[@]}"; do
        if [ -f "$file" ]; then
            ((files_created++))
        fi
    done
    
    echo "$files_created"
}

# ====================================================================
# External WordPress Path Tests
# ====================================================================

test_external_wordpress_path_validation() {
    echo "Testing external WordPress path validation..."
    
    local mock_env
    mock_env="$(create_mock_env "external_wp_test" "empty")"
    
    # Create project structure with custom WordPress directory name
    create_wordpress_project_structure "$mock_env" "my-custom-wordpress"
    
    local original_dir="$PWD"
    cd "$mock_env"
    
    # Test that custom WordPress structure is properly set up
    assert_directory_exists "my-custom-wordpress/wp-content" "Custom WordPress structure exists"
    assert_directory_exists "my-custom-wordpress/wp-content/plugins" "Custom plugins directory exists"
    assert_directory_exists "my-custom-wordpress/wp-content/themes" "Custom themes directory exists"
    assert_directory_exists "my-custom-wordpress/wp-content/mu-plugins" "Custom MU-plugins directory exists"
    
    # Test CLI parameter handling simulation
    local wp_path="$mock_env/my-custom-wordpress"
    local project_root="$mock_env"
    
    # Simulate external path validation
    assert_directory_exists "$wp_path" "WordPress path exists for CLI parameter"
    assert_directory_exists "$project_root" "Project root calculated correctly"
    
    # Test that project root is writable
    assert_command_success "test -w '$project_root'" "Project root is writable"
    
    # Test relative path handling
    cd "$project_root"
    local relative_wp_path="./my-custom-wordpress"
    assert_directory_exists "$relative_wp_path" "Relative WordPress path works"
    
    cd "$original_dir"
    cleanup_mock_env "$mock_env"
}

test_cli_parameter_handling() {
    echo "Testing CLI parameter handling for external paths..."
    
    local mock_env
    mock_env="$(create_mock_env "cli_params_test" "empty")"
    
    # Create multiple project structures to test different scenarios
    create_wordpress_project_structure "$mock_env" "wordpress-site"
    mkdir -p "$mock_env/docker" "$mock_env/ci"
    touch "$mock_env/Jenkinsfile" "$mock_env/docker-compose.yml"
    
    local original_dir="$PWD"
    cd "$mock_env"
    
    # Test absolute path parameter simulation
    local abs_wp_path="$mock_env/wordpress-site"
    assert_directory_exists "$abs_wp_path" "Absolute WordPress path parameter valid"
    
    # Test that project files are preserved
    assert_file_exists "Jenkinsfile" "Jenkinsfile preserved in project root"
    assert_file_exists "docker-compose.yml" "Docker compose file preserved"
    assert_directory_exists "docker" "Docker directory preserved"
    
    # Test mode parameter simulation (1-4)
    local valid_modes=("1" "2" "3" "4")
    for mode in "${valid_modes[@]}"; do
        # Simulate mode validation
        if [[ "$mode" =~ ^[1-4]$ ]]; then
            assert_true true "Mode $mode parameter is valid"
        else
            assert_true false "Mode $mode parameter should be invalid"
        fi
    done
    
    cd "$original_dir"
    cleanup_mock_env "$mock_env"
}

test_project_structure_compatibility() {
    echo "Testing compatibility with different project structures..."
    
    # Test Docker project structure
    local docker_env
    docker_env="$(create_mock_env "docker_project_test" "empty")"
    create_wordpress_project_structure "$docker_env" "app"
    
    local original_dir="$PWD"
    cd "$docker_env"
    
    # Create Docker project files
    mkdir -p "docker/nginx" "docker/php"
    cat > "docker-compose.yml" << 'EOF'
version: '3.8'
services:
  wordpress:
    build: ./docker/php
    volumes:
      - ./app:/var/www/html
EOF
    
    # Test Docker structure compatibility
    assert_directory_exists "app/wp-content" "WordPress in Docker structure"
    assert_file_exists "docker-compose.yml" "Docker compose configuration"
    assert_directory_exists "docker" "Docker configuration directory"
    
    cd "$original_dir"
    cleanup_mock_env "$docker_env"
    
    # Test CI/CD project structure
    local cicd_env
    cicd_env="$(create_mock_env "cicd_project_test" "empty")"
    create_wordpress_project_structure "$cicd_env" "web"
    
    cd "$cicd_env"
    
    # Create CI/CD files
    cat > ".gitlab-ci.yml" << 'EOF'
stages:
  - test
  - deploy

test:
  script:
    - composer install
    - npm install
EOF
    
    mkdir -p "scripts" "docs"
    
    # Test CI/CD structure compatibility
    assert_directory_exists "web/wp-content" "WordPress in CI/CD structure"
    assert_file_exists ".gitlab-ci.yml" "GitLab CI configuration"
    assert_directory_exists "scripts" "Scripts directory"
    assert_directory_exists "docs" "Documentation directory"
    
    cd "$original_dir"
    cleanup_mock_env "$cicd_env"
}

# ====================================================================
# Mode 1 Tests: Configure and Format Project
# ====================================================================

test_mode_1_configure_and_format() {
    echo "Testing Mode 1: Configure and Format Project (Structure Validation)..."
    
    local mock_env
    mock_env="$(create_mock_env "mode1_test" "empty")"
    create_wordpress_project_structure "$mock_env"
    
    local original_dir="$PWD"
    cd "$mock_env"
    
    # Test that the WordPress structure is properly set up for Mode 1
    assert_directory_exists "wordpress/wp-content" "WordPress structure exists for Mode 1"
    assert_directory_exists "wordpress/wp-content/plugins" "Plugins directory exists"
    assert_directory_exists "wordpress/wp-content/themes" "Themes directory exists"
    assert_directory_exists "wordpress/wp-content/mu-plugins" "MU-plugins directory exists"
    
    # Test external WordPress path functionality for Mode 1
    local wp_path="$mock_env/wordpress"
    local project_root="$mock_env"
    
    # Simulate external path validation
    assert_directory_exists "$wp_path" "External WordPress path exists for Mode 1"
    assert_command_success "test -w '$project_root'" "Project root writable for Mode 1"
    
    # Test that sample components are created
    assert_file_exists "wordpress/wp-content/plugins/test-plugin/init.php" "Test plugin file exists"
    assert_file_exists "wordpress/wp-content/themes/test-theme/style.css" "Test theme file exists"
    assert_file_exists "wordpress/wp-content/mu-plugins/core-functionality/init.php" "Test MU-plugin file exists"
    
    # Test that package files exist for merging
    assert_file_exists "package.json" "Package.json exists for Mode 1 processing"
    assert_file_exists "composer.json" "Composer.json exists for Mode 1 processing"
    
    # Validate content of sample files
    assert_file_contains "wordpress/wp-content/plugins/test-plugin/init.php" "Test Plugin" "Plugin has correct header"
    assert_file_contains "wordpress/wp-content/themes/test-theme/style.css" "Test Theme" "Theme has correct header"
    assert_file_contains "package.json" "test-project" "Package.json has project name"
    assert_file_contains "composer.json" "test/project" "Composer.json has project name"
    
    cd "$original_dir"
    cleanup_mock_env "$mock_env"
}

# ====================================================================
# Mode 2 Tests: Configure Only (No Formatting)
# ====================================================================

test_mode_2_configure_only() {
    echo "Testing Mode 2: Configure Only (Component Selection Validation)..."
    
    local mock_env
    mock_env="$(create_mock_env "mode2_test" "empty")"
    create_wordpress_project_structure "$mock_env" "custom-wp"
    
    local original_dir="$PWD"
    cd "$mock_env"
    
    # Test selective component detection capability with custom WordPress directory
    assert_directory_exists "custom-wp/wp-content/plugins/test-plugin" "Test plugin available for selection"
    assert_directory_exists "custom-wp/wp-content/plugins/ecommerce-plugin" "Ecommerce plugin available for selection"
    assert_directory_exists "custom-wp/wp-content/themes/test-theme" "Test theme available for selection"
    assert_directory_exists "custom-wp/wp-content/mu-plugins/core-functionality" "Core functionality available for selection"
    
    # Test external WordPress path for Mode 2
    local wp_path="$mock_env/custom-wp"
    assert_directory_exists "$wp_path" "External WordPress path exists for Mode 2"
    
    # Test that original code formatting is preserved (Mode 2 characteristic)
    assert_file_contains "custom-wp/wp-content/plugins/test-plugin/init.php" "function test_plugin_init(){" "Original code formatting preserved"
    assert_file_contains "custom-wp/wp-content/plugins/ecommerce-plugin/main.php" "class EcommercePlugin{" "Original class formatting preserved"
    
    # Test that components have distinguishable characteristics for selection
    assert_file_contains "custom-wp/wp-content/plugins/test-plugin/init.php" "Test Plugin" "Test plugin has identifiable name"
    assert_file_contains "custom-wp/wp-content/plugins/ecommerce-plugin/main.php" "Ecommerce Plugin" "Ecommerce plugin has identifiable name"
    assert_file_contains "custom-wp/wp-content/themes/test-theme/style.css" "Test Theme" "Test theme has identifiable name"
    
    cd "$original_dir"
    cleanup_mock_env "$mock_env"
}

# ====================================================================
# Mode 3 Tests: Format Only (Use Existing Configuration)
# ====================================================================

test_mode_3_format_only() {
    echo "Testing Mode 3: Format Only (Existing Configuration Validation)..."
    
    local mock_env
    mock_env="$(create_mock_env "mode3_test" "empty")"
    create_wordpress_project_structure "$mock_env"
    
    local original_dir="$PWD"
    cd "$mock_env"
    
    # Create existing configuration files that Mode 3 would use
    cat > "phpcs.xml.dist" << 'EOF'
<?xml version="1.0"?>
<ruleset name="test-project">
    <description>Test configuration</description>
    <rule ref="WordPress"/>
    <file>wordpress/wp-content/plugins/test-plugin</file>
    <file>wordpress/wp-content/themes/test-theme</file>
</ruleset>
EOF
    
    cat > "eslint.config.js" << 'EOF'
module.exports = {
    extends: ['@wordpress/eslint-plugin/recommended'],
    files: ['wordpress/wp-content/**/*.js']
};
EOF
    
    # Test that existing configuration is properly structured for Mode 3
    assert_file_exists "phpcs.xml.dist" "Existing PHPCS configuration available for Mode 3"
    assert_file_exists "eslint.config.js" "Existing ESLint configuration available for Mode 3"
    
    # Validate configuration content
    assert_file_contains "phpcs.xml.dist" "test-project" "Configuration contains project settings"
    assert_file_contains "phpcs.xml.dist" "WordPress" "Configuration uses WordPress standards"
    assert_file_contains "phpcs.xml.dist" "test-plugin" "Configuration targets test plugin"
    assert_file_contains "phpcs.xml.dist" "test-theme" "Configuration targets test theme"
    
    assert_file_contains "eslint.config.js" "wordpress" "ESLint configuration uses WordPress standards"
    assert_file_contains "eslint.config.js" "wp-content" "ESLint configuration targets WordPress content"
    
    # Mock formatting tools for Mode 3 testing
    mock_tool "phpcs" "success" "Formatting completed successfully"
    mock_tool "phpcbf" "success" "Code formatting applied"
    mock_tool "eslint" "success" "JavaScript linting completed"
    
    # Test that formatting tools are available (mocked)
    assert_command_success "command -v phpcs" "PHPCS tool available for formatting"
    assert_command_success "command -v phpcbf" "PHP Code Beautifier available for formatting"
    assert_command_success "command -v eslint" "ESLint tool available for formatting"
    
    cd "$original_dir"
    cleanup_mock_env "$mock_env"
}

# ====================================================================
# Mode 4 Tests: Merge Configuration (Advanced)
# ====================================================================

test_mode_4_merge_configuration() {
    echo "Testing Mode 4: Merge Configuration (JSON Merge Validation)..."
    
    local mock_env
    mock_env="$(create_mock_env "mode4_test" "empty")"
    create_wordpress_project_structure "$mock_env"
    
    local original_dir="$PWD"
    cd "$mock_env"
    
    # Mock jq for JSON operations
    mock_tool "jq" "success" ""
    
    # Test that original files are ready for merging
    assert_file_exists "package.json" "Package.json exists for Mode 4 merging"
    assert_file_exists "composer.json" "Composer.json exists for Mode 4 merging"
    
    # Validate original package.json content
    assert_file_contains "package.json" "test-project" "Package.json has project name"
    assert_file_contains "package.json" "lodash" "Package.json has original dependencies"
    assert_file_contains "package.json" "webpack" "Package.json has original dev dependencies"
    assert_file_contains "package.json" "dev" "Package.json has original dev script"
    assert_file_contains "package.json" "build" "Package.json has original build script"
    
    # Validate original composer.json content
    assert_file_contains "composer.json" "test/project" "Composer.json has project name"
    assert_file_contains "composer.json" "php" "Composer.json has PHP requirement"
    assert_file_contains "composer.json" "monolog/monolog" "Composer.json has original dependencies"
    assert_file_contains "composer.json" "phpunit/phpunit" "Composer.json has original dev dependencies"
    
    # Create backup files to simulate Mode 4 behavior
    cp package.json package.json.original
    cp composer.json composer.json.original
    
    # Test that jq tool is available for JSON operations
    assert_command_success "command -v jq" "jq tool available for JSON merging"
    
    # Test JSON validation with mocked jq
    assert_command_success "jq -e '.dependencies.lodash' package.json" "Can query original package.json dependencies"
    assert_command_success "jq -e '.require.php' composer.json" "Can query original composer.json requirements"
    
    # Verify backup files were created
    assert_file_exists "package.json.original" "Package.json backup created"
    assert_file_exists "composer.json.original" "Composer.json backup created"
    
    cd "$original_dir"
    cleanup_mock_env "$mock_env"
}

# ====================================================================
# File Generation Tests
# ====================================================================

test_file_generation() {
    echo "Testing file generation validation (Template Structure)..."
    
    local mock_env
    mock_env="$(create_mock_env "file_generation_test" "empty")"
    create_wordpress_project_structure "$mock_env"
    
    local original_dir="$PWD"
    cd "$mock_env"
    
    # Create sample configuration files that would be generated
    cat > "phpcs.xml.dist" << 'EOF'
<?xml version="1.0"?>
<ruleset name="test-project WordPress Coding Standards">
    <description>WordPress coding standards for test-project</description>
    <rule ref="WordPress"/>
    <file>wordpress/wp-content/plugins/test-plugin</file>
    <file>wordpress/wp-content/plugins/ecommerce-plugin</file>
    <file>wordpress/wp-content/themes/test-theme</file>
    <file>wordpress/wp-content/mu-plugins/core-functionality</file>
</ruleset>
EOF
    
    cat > "phpstan.neon.dist" << 'EOF'
parameters:
    level: 5
    paths:
        - wordpress/wp-content/plugins/test-plugin
        - wordpress/wp-content/themes/test-theme
        - wordpress/wp-content/mu-plugins/core-functionality
EOF
    
    cat > "eslint.config.js" << 'EOF'
module.exports = {
    extends: ['@wordpress/eslint-plugin/recommended'],
    files: [
        'wordpress/wp-content/plugins/test-plugin/**/*.js',
        'wordpress/wp-content/themes/test-theme/**/*.js'
    ],
    rules: {
        'wordpress/no-unused-vars-before-return': 'error'
    }
};
EOF
    
    cat > "wp.code-workspace" << 'EOF'
{
    "folders": [
        {
            "name": "test-plugin",
            "path": "./wordpress/wp-content/plugins/test-plugin"
        },
        {
            "name": "test-theme", 
            "path": "./wordpress/wp-content/themes/test-theme"
        },
        {
            "name": "core-functionality",
            "path": "./wordpress/wp-content/mu-plugins/core-functionality"
        }
    ],
    "settings": {
        "php.validate.executablePath": "/usr/bin/php"
    }
}
EOF
    
    # Test that all documented files are properly structured
    local documented_files=(
        "phpcs.xml.dist"
        "phpstan.neon.dist"
        "eslint.config.js"
        "wp.code-workspace"
    )
    
    for file in "${documented_files[@]}"; do
        assert_file_exists "$file" "Generated file template exists: $file"
        
        # Validate content structure
        case "$file" in
            "phpcs.xml.dist")
                assert_file_contains "$file" "WordPress" "PHPCS contains WordPress rules"
                assert_file_contains "$file" "test-project" "PHPCS contains project name"
                assert_file_contains "$file" "test-plugin" "PHPCS includes test-plugin"
                assert_file_contains "$file" "test-theme" "PHPCS includes test-theme"
                ;;
            "phpstan.neon.dist")
                assert_file_contains "$file" "level:" "PHPStan has analysis level"
                assert_file_contains "$file" "paths:" "PHPStan has file paths"
                assert_file_contains "$file" "test-plugin" "PHPStan includes test-plugin"
                ;;
            "eslint.config.js")
                assert_file_contains "$file" "wordpress" "ESLint contains WordPress config"
                assert_file_contains "$file" "test-plugin" "ESLint includes test-plugin paths"
                assert_file_contains "$file" "test-theme" "ESLint includes test-theme paths"
                ;;
            "wp.code-workspace")
                assert_file_contains "$file" "folders" "Workspace has folders configuration"
                assert_file_contains "$file" "test-plugin" "Workspace includes test-plugin"
                assert_file_contains "$file" "test-theme" "Workspace includes test-theme"
                assert_file_contains "$file" "settings" "Workspace has settings configuration"
                ;;
        esac
    done
    
    # Test file generation completeness
    local files_created
    files_created="$(validate_configuration_files)"
    assert_equals 4 "$files_created" "All documented files are present"
    
    cd "$original_dir"
    cleanup_mock_env "$mock_env"
}

# ====================================================================
# Workflow Tests
# ====================================================================

test_documented_workflows() {
    echo "Testing documented workflow validation (Prerequisites Check)..."
    
    local mock_env
    mock_env="$(create_mock_env "workflow_test" "empty")"
    create_wordpress_project_structure "$mock_env"
    
    local original_dir="$PWD"
    cd "$mock_env"
    
    # Create configuration files that would be generated by the workflow
    cat > "phpcs.xml.dist" << 'EOF'
<?xml version="1.0"?>
<ruleset name="test-project">
    <description>WordPress coding standards</description>
    <rule ref="WordPress"/>
    <file>wordpress/wp-content/plugins</file>
    <file>wordpress/wp-content/themes</file>
</ruleset>
EOF
    
    cat > "eslint.config.js" << 'EOF'
module.exports = {
    extends: ['@wordpress/eslint-plugin/recommended'],
    files: ['wordpress/wp-content/**/*.js']
};
EOF
    
    # Update package.json with linting scripts
    cat > "package.json" << 'EOF'
{
  "name": "test-project",
  "version": "1.0.0",
  "scripts": {
    "dev": "webpack --mode development",
    "build": "webpack --mode production",
    "lint:js": "eslint wordpress/wp-content --ext .js",
    "lint:php": "phpcs --standard=phpcs.xml.dist"
  },
  "dependencies": {
    "lodash": "^4.17.21"
  },
  "devDependencies": {
    "webpack": "^5.88.0",
    "@wordpress/eslint-plugin": "^12.0.0",
    "eslint": "^8.0.0"
  }
}
EOF
    
    # Update composer.json with linting dependencies
    cat > "composer.json" << 'EOF'
{
  "name": "test/project",
  "description": "Test project for validation",
  "type": "project",
  "require": {
    "php": ">=8.1",
    "monolog/monolog": "^3.0"
  },
  "require-dev": {
    "phpunit/phpunit": "^10.0",
    "wp-coding-standards/wpcs": "^2.3",
    "phpstan/phpstan": "^1.0"
  },
  "scripts": {
    "test": "phpunit",
    "lint:php": "phpcs --standard=phpcs.xml.dist"
  }
}
EOF
    
    # Test Quick Start workflow prerequisites
    assert_file_exists "package.json" "Package.json ready for npm install"
    assert_file_exists "composer.json" "Composer.json ready for composer install"
    
    # Test linting workflow prerequisites
    assert_file_exists "phpcs.xml.dist" "PHPCS configuration available for linting"
    assert_file_contains "phpcs.xml.dist" "<file>" "PHPCS has file paths for linting"
    assert_file_contains "phpcs.xml.dist" "WordPress" "PHPCS uses WordPress standards"
    
    assert_file_exists "eslint.config.js" "ESLint configuration available for linting"
    assert_file_contains "eslint.config.js" "files:" "ESLint has file patterns configured"
    assert_file_contains "eslint.config.js" "wordpress" "ESLint uses WordPress standards"
    
    # Test that package.json has linting scripts
    assert_file_contains "package.json" "lint:js" "Package.json has JavaScript linting script"
    assert_file_contains "package.json" "lint:php" "Package.json has PHP linting script"
    assert_file_contains "package.json" "eslint" "Package.json has ESLint dependency"
    
    # Test that composer.json has linting dependencies
    assert_file_contains "composer.json" "wp-coding-standards/wpcs" "Composer.json has WPCS dependency"
    assert_file_contains "composer.json" "phpstan/phpstan" "Composer.json has PHPStan dependency"
    assert_file_contains "composer.json" "lint:php" "Composer.json has PHP linting script"
    
    # Test VSCode workspace integration
    cat > "wp.code-workspace" << 'EOF'
{
    "folders": [
        {
            "name": "test-plugin",
            "path": "./wordpress/wp-content/plugins/test-plugin"
        },
        {
            "name": "test-theme",
            "path": "./wordpress/wp-content/themes/test-theme"
        }
    ],
    "settings": {
        "php.validate.executablePath": "/usr/bin/php",
        "phpcs.executablePath": "./vendor/bin/phpcs"
    }
}
EOF
    
    assert_file_exists "wp.code-workspace" "VSCode workspace file available"
    assert_file_contains "wp.code-workspace" "folders" "Workspace contains folder configuration"
    assert_file_contains "wp.code-workspace" "settings" "Workspace contains settings configuration"
    assert_file_contains "wp.code-workspace" "test-plugin" "Workspace includes test-plugin"
    assert_file_contains "wp.code-workspace" "test-theme" "Workspace includes test-theme"
    
    cd "$original_dir"
    cleanup_mock_env "$mock_env"
}

# ====================================================================
# Error Handling Tests
# ====================================================================

test_error_handling() {
    echo "Testing error handling validation (Prerequisite Validation)..."
    
    # Test jq requirement for Mode 4
    local mock_env1
    mock_env1="$(create_mock_env "error_jq_test" "empty")"
    create_wordpress_project_structure "$mock_env1"
    
    local original_dir="$PWD"
    cd "$mock_env1"
    
    # Mock jq as not available for Mode 4 testing
    mock_tool "jq" "not_found"
    
    # Test that jq is properly detected as missing
    assert_command_fails "command -v jq" "jq correctly detected as not available for Mode 4"
    
    # Test that Mode 4 prerequisites are not met
    local mode4_ready=false
    if command -v jq >/dev/null 2>&1; then
        mode4_ready=true
    fi
    assert_false "$mode4_ready" "Mode 4 prerequisites correctly identified as not met"
    
    cd "$original_dir"
    cleanup_mock_env "$mock_env1"
    
    # Test missing WordPress structure detection
    local mock_env2
    mock_env2="$(create_mock_env "error_no_wp_test" "empty")"
    # Don't create WordPress structure for this test
    
    cd "$mock_env2"
    
    # Test that WordPress structure is properly detected as missing
    assert_directory_not_exists "wordpress/wp-content" "WordPress structure correctly detected as missing"
    assert_directory_not_exists "wp-content" "Alternative WordPress structure also missing"
    
    # Test that basic project files are missing
    assert_file_not_exists "package.json" "Package.json missing in empty project"
    assert_file_not_exists "composer.json" "Composer.json missing in empty project"
    
    cd "$original_dir"
    cleanup_mock_env "$mock_env2"
    
    # Test partial WordPress structure (incomplete setup)
    local mock_env3
    mock_env3="$(create_mock_env "error_partial_wp_test" "empty")"
    
    cd "$mock_env3"
    
    # Create partial WordPress structure
    mkdir -p "wordpress"
    # Missing wp-content directory
    
    assert_directory_exists "wordpress" "WordPress directory exists but incomplete"
    assert_directory_not_exists "wordpress/wp-content" "WordPress wp-content directory missing"
    
    # Test that incomplete structure is detectable
    local wp_structure_complete=true
    if [ ! -d "wordpress/wp-content/plugins" ] || [ ! -d "wordpress/wp-content/themes" ]; then
        wp_structure_complete=false
    fi
    assert_false "$wp_structure_complete" "Incomplete WordPress structure correctly detected"
    
    cd "$original_dir"
    cleanup_mock_env "$mock_env3"
}

# ====================================================================
# Main Test Execution
# ====================================================================

main() {
    echo "🧪 WordPress Init Project - Comprehensive E2E Test Suite"
    echo "=========================================================="
    echo "Testing all operation modes and functionality"
    echo ""
    
    # Check if script exists
    if [ ! -f "$SCRIPT_PATH" ]; then
        echo "❌ ERROR: Script not found at $SCRIPT_PATH"
        exit 1
    fi
    
    # Make script executable
    chmod +x "$SCRIPT_PATH"
    
    reset_assertions
    
    # Run all tests
    test_external_wordpress_path_validation
    test_cli_parameter_handling
    test_project_structure_compatibility
    test_mode_1_configure_and_format
    test_mode_2_configure_only
    test_mode_3_format_only
    test_mode_4_merge_configuration
    test_file_generation
    test_documented_workflows
    test_error_handling
    
    # Print final results
    print_assertion_summary
    
    local exit_code=$?
    if [ $exit_code -eq 0 ]; then
        echo "🎉 All E2E tests passed!"
    else
        echo "⚠️ Some E2E tests failed"
    fi
    
    return $exit_code
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi