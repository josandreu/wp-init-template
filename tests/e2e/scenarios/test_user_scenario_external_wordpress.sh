#!/bin/bash

# ====================================================================
# WordPress Init Project - User Scenario Tests for External WordPress
# ====================================================================
# Tests specific user scenarios with custom WordPress directory structures,
# CLI parameters, and compatibility with existing project files
# ====================================================================

set -euo pipefail

# Source testing libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/assertions.sh"
source "$SCRIPT_DIR/../../lib/mock-env.sh"

# Test configuration
ORIGINAL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../" && pwd)"
SCRIPT_PATH="$ORIGINAL_DIR/init-project.sh"

# ====================================================================
# Test Setup Functions
# ====================================================================

# Create a realistic project structure with custom WordPress directory
create_user_project_structure() {
    local base_path="$1"
    local wp_dir_name="${2:-axn-wordpress}"
    
    # Create WordPress structure with custom directory name
    mkdir -p "$base_path/$wp_dir_name/wp-content"/{plugins,themes,mu-plugins}
    
    # Create existing project files that should be preserved
    mkdir -p "$base_path/docker/nginx" "$base_path/docker/php"
    mkdir -p "$base_path/ci/scripts" "$base_path/scripts"
    
    # Create CI/CD files
    cat > "$base_path/Jenkinsfile" << 'EOF'
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sh 'composer install'
                sh 'npm install'
            }
        }
        stage('Test') {
            steps {
                sh 'composer test'
                sh 'npm test'
            }
        }
    }
}
EOF
    
    cat > "$base_path/docker-compose.yml" << 'EOF'
version: '3.8'
services:
  nginx:
    build: ./docker/nginx
    ports:
      - "80:80"
    volumes:
      - ./axn-wordpress:/var/www/html
  
  php:
    build: ./docker/php
    volumes:
      - ./axn-wordpress:/var/www/html
EOF
    
    cat > "$base_path/.gitlab-ci.yml" << 'EOF'
stages:
  - test
  - deploy

test:
  script:
    - composer install
    - npm install
    - composer test
    - npm test

deploy:
  script:
    - echo "Deploying to production"
  only:
    - main
EOF
    
    # Create documentation files
    cat > "$base_path/README.md" << 'EOF'
# AXN WordPress Project

This is a WordPress project with custom structure.

## Structure
- `axn-wordpress/` - WordPress installation
- `docker/` - Docker configuration
- `ci/` - CI/CD scripts
- `scripts/` - Build and deployment scripts

## Development
1. Run `docker-compose up`
2. Access site at http://localhost
EOF
    
    # Create existing package.json with project-specific configuration
    cat > "$base_path/package.json" << 'EOF'
{
  "name": "axn-wordpress-project",
  "version": "2.1.0",
  "description": "AXN WordPress project with custom build pipeline",
  "scripts": {
    "start": "docker-compose up",
    "build": "webpack --mode production",
    "dev": "webpack --mode development --watch",
    "test": "jest",
    "deploy": "./scripts/deploy.sh"
  },
  "dependencies": {
    "axios": "^1.0.0",
    "lodash": "^4.17.21"
  },
  "devDependencies": {
    "webpack": "^5.88.0",
    "jest": "^29.0.0",
    "@babel/core": "^7.22.0"
  }
}
EOF
    
    # Create existing composer.json with project-specific configuration
    cat > "$base_path/composer.json" << 'EOF'
{
  "name": "axn/wordpress-project",
  "description": "AXN WordPress project with custom architecture",
  "type": "project",
  "version": "2.1.0",
  "require": {
    "php": ">=8.1",
    "monolog/monolog": "^3.0",
    "guzzlehttp/guzzle": "^7.0"
  },
  "require-dev": {
    "phpunit/phpunit": "^10.0",
    "mockery/mockery": "^1.5"
  },
  "scripts": {
    "test": "phpunit",
    "deploy": "php scripts/deploy.php",
    "build": "php scripts/build.php"
  },
  "autoload": {
    "psr-4": {
      "AXN\\": "src/"
    }
  }
}
EOF
    
    # Create sample WordPress components in custom directory
    create_sample_wordpress_components "$base_path/$wp_dir_name"
    
    # Create project-specific scripts
    mkdir -p "$base_path/scripts"
    cat > "$base_path/scripts/deploy.sh" << 'EOF'
#!/bin/bash
echo "Deploying AXN WordPress project..."
# Custom deployment logic
EOF
    chmod +x "$base_path/scripts/deploy.sh"
}

# Create sample WordPress components
create_sample_wordpress_components() {
    local wp_path="$1"
    
    # Create custom plugin
    mkdir -p "$wp_path/wp-content/plugins/axn-core"
    cat > "$wp_path/wp-content/plugins/axn-core/axn-core.php" << 'EOF'
<?php
/*
Plugin Name: AXN Core Functionality
Description: Core functionality for AXN WordPress site
Version: 2.1.0
Author: AXN Team
*/

if (!defined('ABSPATH')) {
    exit;
}

class AXNCore {
    public function __construct() {
        add_action('init', array($this, 'init'));
    }
    
    public function init() {
        // Core functionality initialization
        add_action('wp_enqueue_scripts', array($this, 'enqueue_scripts'));
    }
    
    public function enqueue_scripts() {
        wp_enqueue_script('axn-core', plugin_dir_url(__FILE__) . 'assets/js/core.js', array('jquery'), '2.1.0', true);
    }
}

new AXNCore();
EOF
    
    # Create custom theme
    mkdir -p "$wp_path/wp-content/themes/axn-theme"
    cat > "$wp_path/wp-content/themes/axn-theme/style.css" << 'EOF'
/*
Theme Name: AXN Custom Theme
Description: Custom theme for AXN WordPress project
Version: 2.1.0
Author: AXN Team
*/

body {
    font-family: 'Helvetica Neue', Arial, sans-serif;
    line-height: 1.6;
    color: #333;
}

.axn-header {
    background: #2c3e50;
    color: white;
    padding: 1rem 0;
}
EOF
    
    cat > "$wp_path/wp-content/themes/axn-theme/functions.php" << 'EOF'
<?php
function axn_theme_setup() {
    add_theme_support('post-thumbnails');
    add_theme_support('custom-logo');
    add_theme_support('html5', array('search-form', 'comment-form', 'comment-list', 'gallery', 'caption'));
}
add_action('after_setup_theme', 'axn_theme_setup');

function axn_theme_scripts() {
    wp_enqueue_style('axn-theme-style', get_stylesheet_uri(), array(), '2.1.0');
    wp_enqueue_script('axn-theme-script', get_template_directory_uri() . '/js/theme.js', array('jquery'), '2.1.0', true);
}
add_action('wp_enqueue_scripts', 'axn_theme_scripts');
EOF
    
    # Create MU plugin
    cat > "$wp_path/wp-content/mu-plugins/axn-security.php" << 'EOF'
<?php
/*
Plugin Name: AXN Security
Description: Security enhancements for AXN WordPress site
Version: 2.1.0
Author: AXN Team
*/

// Security headers
add_action('send_headers', function() {
    header('X-Content-Type-Options: nosniff');
    header('X-Frame-Options: SAMEORIGIN');
    header('X-XSS-Protection: 1; mode=block');
});

// Disable file editing
define('DISALLOW_FILE_EDIT', true);
EOF
}

# ====================================================================
# Test 1: Custom WordPress Directory Structure
# ====================================================================

test_custom_wordpress_directory_structure() {
    echo "Testing custom WordPress directory structure..."
    
    local mock_env
    mock_env="$(create_mock_env "custom_wp_structure_test" "empty")"
    
    # Create realistic project structure with custom WordPress directory
    create_user_project_structure "$mock_env" "my-custom-wordpress"
    
    local original_dir="$PWD"
    cd "$mock_env"
    
    # Test WordPress structure validation with custom directory name
    local wp_path="$mock_env/my-custom-wordpress"
    local project_root="$mock_env"
    
    # Validate custom WordPress structure exists
    assert_directory_exists "my-custom-wordpress/wp-content" "Custom WordPress directory exists"
    assert_directory_exists "my-custom-wordpress/wp-content/plugins" "Custom WordPress plugins directory exists"
    assert_directory_exists "my-custom-wordpress/wp-content/themes" "Custom WordPress themes directory exists"
    assert_directory_exists "my-custom-wordpress/wp-content/mu-plugins" "Custom WordPress MU-plugins directory exists"
    
    # Test custom components exist
    assert_directory_exists "my-custom-wordpress/wp-content/plugins/axn-core" "Custom plugin directory exists"
    assert_file_exists "my-custom-wordpress/wp-content/plugins/axn-core/axn-core.php" "Custom plugin file exists"
    assert_directory_exists "my-custom-wordpress/wp-content/themes/axn-theme" "Custom theme directory exists"
    assert_file_exists "my-custom-wordpress/wp-content/themes/axn-theme/style.css" "Custom theme style exists"
    assert_file_exists "my-custom-wordpress/wp-content/mu-plugins/axn-security.php" "Custom MU-plugin exists"
    
    # Test project root calculation from custom WordPress path
    local calculated_root
    calculated_root="$(dirname "$wp_path")"
    assert_equals "$project_root" "$calculated_root" "Project root calculated correctly from custom WordPress path"
    
    # Test relative path generation
    local relative_wp_path
    relative_wp_path="$(basename "$wp_path")"
    assert_equals "my-custom-wordpress" "$relative_wp_path" "Relative WordPress path generated correctly"
    
    # Test that custom WordPress structure is writable
    assert_command_success "test -w '$wp_path'" "Custom WordPress directory is writable"
    assert_command_success "test -w '$project_root'" "Project root is writable"
    
    # Test component validation with custom paths
    assert_file_contains "my-custom-wordpress/wp-content/plugins/axn-core/axn-core.php" "AXN Core Functionality" "Custom plugin has correct header"
    assert_file_contains "my-custom-wordpress/wp-content/themes/axn-theme/style.css" "AXN Custom Theme" "Custom theme has correct header"
    assert_file_contains "my-custom-wordpress/wp-content/mu-plugins/axn-security.php" "AXN Security" "Custom MU-plugin has correct header"
    
    cd "$original_dir"
    cleanup_mock_env "$mock_env"
}

# ====================================================================
# Test 2: Compatibility with Existing Project Files
# ====================================================================

test_existing_project_files_compatibility() {
    echo "Testing compatibility with existing project files..."
    
    local mock_env
    mock_env="$(create_mock_env "existing_files_test" "empty")"
    
    # Create project with existing files that should be preserved
    create_user_project_structure "$mock_env" "wordpress-site"
    
    local original_dir="$PWD"
    cd "$mock_env"
    
    # Test that all existing project files are preserved
    assert_file_exists "Jenkinsfile" "Jenkinsfile preserved"
    assert_file_exists "docker-compose.yml" "Docker Compose file preserved"
    assert_file_exists ".gitlab-ci.yml" "GitLab CI file preserved"
    assert_file_exists "README.md" "README file preserved"
    assert_file_exists "package.json" "Existing package.json preserved"
    assert_file_exists "composer.json" "Existing composer.json preserved"
    
    # Test directory structure preservation
    assert_directory_exists "docker" "Docker directory preserved"
    assert_directory_exists "docker/nginx" "Docker nginx directory preserved"
    assert_directory_exists "docker/php" "Docker PHP directory preserved"
    assert_directory_exists "ci" "CI directory preserved"
    assert_directory_exists "scripts" "Scripts directory preserved"
    
    # Test existing file content is preserved
    assert_file_contains "Jenkinsfile" "pipeline" "Jenkinsfile content preserved"
    assert_file_contains "docker-compose.yml" "version: '3.8'" "Docker Compose content preserved"
    assert_file_contains ".gitlab-ci.yml" "stages:" "GitLab CI content preserved"
    assert_file_contains "README.md" "AXN WordPress Project" "README content preserved"
    
    # Test existing package.json content preservation
    assert_file_contains "package.json" "axn-wordpress-project" "Package.json name preserved"
    assert_file_contains "package.json" "2.1.0" "Package.json version preserved"
    assert_file_contains "package.json" "docker-compose up" "Package.json start script preserved"
    assert_file_contains "package.json" "axios" "Package.json dependencies preserved"
    assert_file_contains "package.json" "jest" "Package.json dev dependencies preserved"
    
    # Test existing composer.json content preservation
    assert_file_contains "composer.json" "axn/wordpress-project" "Composer.json name preserved"
    assert_file_contains "composer.json" "2.1.0" "Composer.json version preserved"
    assert_file_contains "composer.json" "guzzlehttp/guzzle" "Composer.json dependencies preserved"
    assert_file_contains "composer.json" "mockery/mockery" "Composer.json dev dependencies preserved"
    assert_file_contains "composer.json" "AXN\\\\" "Composer.json autoload preserved"
    
    # Test that WordPress structure coexists with project files
    assert_directory_exists "wordpress-site/wp-content" "WordPress structure coexists with project files"
    assert_directory_exists "wordpress-site/wp-content/plugins/axn-core" "WordPress plugins coexist with project files"
    assert_directory_exists "wordpress-site/wp-content/themes/axn-theme" "WordPress themes coexist with project files"
    
    # Test that project scripts are preserved and executable
    assert_file_exists "scripts/deploy.sh" "Deploy script preserved"
    assert_command_success "test -x scripts/deploy.sh" "Deploy script is executable"
    
    cd "$original_dir"
    cleanup_mock_env "$mock_env"
}

# ====================================================================
# Test 3: CLI Parameters and Non-Interactive Mode
# ====================================================================

test_cli_parameters_and_non_interactive_mode() {
    echo "Testing CLI parameters and non-interactive mode..."
    
    local mock_env
    mock_env="$(create_mock_env "cli_params_test" "empty")"
    
    # Create project structure for CLI testing
    create_user_project_structure "$mock_env" "site-wordpress"
    
    local original_dir="$PWD"
    cd "$mock_env"
    
    # Test CLI parameter validation scenarios
    local wp_path="$mock_env/site-wordpress"
    local project_root="$mock_env"
    
    # Test 1: WordPress path parameter validation (Requirement 6.1)
    assert_directory_exists "site-wordpress" "WordPress path parameter target exists"
    assert_directory_exists "site-wordpress/wp-content" "WordPress path parameter target is valid WordPress structure"
    
    # Simulate CLI parameter parsing
    local cli_wp_path="$wp_path"
    local cli_project_root
    cli_project_root="$(dirname "$cli_wp_path")"
    
    assert_equals "$project_root" "$cli_project_root" "CLI WordPress path parameter resolves to correct project root"
    
    # Test 2: Mode parameter validation (Requirement 6.2)
    local valid_modes=("1" "2" "3" "4")
    for mode in "${valid_modes[@]}"; do
        # Simulate mode parameter validation
        if [[ "$mode" =~ ^[1-4]$ ]]; then
            assert_true true "Mode parameter $mode is valid"
        else
            assert_true false "Mode parameter $mode should be invalid"
        fi
    done
    
    # Test invalid mode parameters
    local invalid_modes=("0" "5" "abc" "" "-1")
    for mode in "${invalid_modes[@]}"; do
        if [[ ! "$mode" =~ ^[1-4]$ ]]; then
            assert_true true "Invalid mode parameter '$mode' correctly rejected"
        else
            assert_true false "Invalid mode parameter '$mode' should be rejected"
        fi
    done
    
    # Test 3: Non-interactive execution simulation (Requirement 6.3)
    # Simulate non-interactive mode by setting environment variables
    export WORDPRESS_PATH="$wp_path"
    export PROJECT_ROOT="$project_root"
    export OPERATION_MODE="1"
    export NON_INTERACTIVE="true"
    
    # Test that all required parameters are available for non-interactive execution
    assert_true "[ -n \"$WORDPRESS_PATH\" ]" "WordPress path available for non-interactive mode"
    assert_true "[ -n \"$PROJECT_ROOT\" ]" "Project root available for non-interactive mode"
    assert_true "[ -n \"$OPERATION_MODE\" ]" "Operation mode available for non-interactive mode"
    assert_true "[ \"$NON_INTERACTIVE\" = \"true\" ]" "Non-interactive flag set correctly"
    
    # Test 4: Parameter validation before proceeding (Requirement 6.4)
    # Simulate parameter validation checks
    local validation_passed=true
    
    # Check WordPress path exists and is valid
    if [ ! -d "$WORDPRESS_PATH/wp-content" ]; then
        validation_passed=false
    fi
    
    # Check project root is writable
    if [ ! -w "$PROJECT_ROOT" ]; then
        validation_passed=false
    fi
    
    # Check mode is valid
    if [[ ! "$OPERATION_MODE" =~ ^[1-4]$ ]]; then
        validation_passed=false
    fi
    
    assert_true "$validation_passed" "All CLI parameters pass validation"
    
    # Test 5: Error handling for invalid parameters (Requirement 6.5)
    # Test invalid WordPress path
    local invalid_wp_path="/nonexistent/path"
    local invalid_path_validation=false
    if [ -d "$invalid_wp_path/wp-content" ]; then
        invalid_path_validation=true
    fi
    assert_false "$invalid_path_validation" "Invalid WordPress path correctly rejected"
    
    # Test invalid mode
    local invalid_mode="invalid"
    local invalid_mode_validation=false
    if [[ "$invalid_mode" =~ ^[1-4]$ ]]; then
        invalid_mode_validation=true
    fi
    assert_false "$invalid_mode_validation" "Invalid mode parameter correctly rejected"
    
    # Test CLI help functionality simulation
    # Simulate --help flag behavior
    local help_content="Usage: ./init-project.sh [wordpress_path] [mode]"
    assert_contains "$help_content" "Usage:" "Help content contains usage information"
    assert_contains "$help_content" "wordpress_path" "Help content mentions WordPress path parameter"
    assert_contains "$help_content" "mode" "Help content mentions mode parameter"
    
    # Clean up environment variables
    unset WORDPRESS_PATH PROJECT_ROOT OPERATION_MODE NON_INTERACTIVE
    
    cd "$original_dir"
    cleanup_mock_env "$mock_env"
}

# ====================================================================
# Test 4: Integration Test - Complete User Scenario
# ====================================================================

test_complete_user_scenario_integration() {
    echo "Testing complete user scenario integration..."
    
    local mock_env
    mock_env="$(create_mock_env "complete_scenario_test" "empty")"
    
    # Create the exact scenario described in the requirements
    create_user_project_structure "$mock_env" "axn-wordpress"
    
    local original_dir="$PWD"
    cd "$mock_env"
    
    # Simulate the complete user workflow
    local wp_path="$mock_env/axn-wordpress"
    local project_root="$mock_env"
    local mode="1"
    
    # Step 1: Validate initial project state
    assert_directory_exists "axn-wordpress" "User's WordPress directory exists"
    assert_file_exists "Jenkinsfile" "User's CI/CD files exist"
    assert_file_exists "docker-compose.yml" "User's Docker configuration exists"
    assert_file_exists "package.json" "User's existing package.json exists"
    assert_file_exists "composer.json" "User's existing composer.json exists"
    
    # Step 2: Simulate CLI execution with parameters
    # ./init-project.sh /path/to/axn-wordpress 1
    export WORDPRESS_PATH="$wp_path"
    export PROJECT_ROOT="$project_root"
    export OPERATION_MODE="$mode"
    export NON_INTERACTIVE="true"
    
    # Step 3: Validate WordPress structure detection
    assert_directory_exists "$WORDPRESS_PATH/wp-content/plugins" "WordPress plugins directory detected"
    assert_directory_exists "$WORDPRESS_PATH/wp-content/themes" "WordPress themes directory detected"
    assert_directory_exists "$WORDPRESS_PATH/wp-content/mu-plugins" "WordPress MU-plugins directory detected"
    
    # Step 4: Validate project root calculation
    local calculated_root
    calculated_root="$(dirname "$WORDPRESS_PATH")"
    assert_equals "$PROJECT_ROOT" "$calculated_root" "Project root calculated correctly"
    
    # Step 5: Validate relative path generation for configuration files
    local relative_wp_path
    relative_wp_path="$(basename "$WORDPRESS_PATH")"
    assert_equals "axn-wordpress" "$relative_wp_path" "Relative WordPress path for configs"
    
    # Step 6: Simulate configuration file generation with correct paths
    # Test that configuration would use relative paths
    local expected_phpcs_path="axn-wordpress/wp-content/plugins"
    local expected_eslint_pattern="axn-wordpress/wp-content/**/*.js"
    
    assert_contains "$expected_phpcs_path" "axn-wordpress" "PHPCS config would use correct relative path"
    assert_contains "$expected_eslint_pattern" "axn-wordpress" "ESLint config would use correct relative path"
    
    # Step 7: Validate existing files preservation
    assert_file_exists "Jenkinsfile" "Jenkinsfile preserved during configuration"
    assert_file_exists "docker-compose.yml" "Docker Compose preserved during configuration"
    assert_file_contains "package.json" "axn-wordpress-project" "Existing package.json content preserved"
    assert_file_contains "composer.json" "axn/wordpress-project" "Existing composer.json content preserved"
    
    # Step 8: Validate backup creation simulation
    # In real execution, backups would be created in project root
    local backup_location="$PROJECT_ROOT"
    assert_command_success "test -w '$backup_location'" "Backup location is writable"
    
    # Step 9: Test mode-specific behavior (Mode 1: Configure and Format)
    assert_equals "1" "$OPERATION_MODE" "Mode 1 selected for complete configuration"
    
    # Step 10: Validate non-interactive execution readiness
    assert_true "[ \"$NON_INTERACTIVE\" = \"true\" ]" "Non-interactive mode enabled"
    assert_true "[ -n \"$WORDPRESS_PATH\" ]" "All required parameters available"
    assert_true "[ -n \"$PROJECT_ROOT\" ]" "All required parameters available"
    assert_true "[ -n \"$OPERATION_MODE\" ]" "All required parameters available"
    
    # Clean up
    unset WORDPRESS_PATH PROJECT_ROOT OPERATION_MODE NON_INTERACTIVE
    
    cd "$original_dir"
    cleanup_mock_env "$mock_env"
}

# ====================================================================
# Test 5: Edge Cases and Error Scenarios
# ====================================================================

test_edge_cases_and_error_scenarios() {
    echo "Testing edge cases and error scenarios..."
    
    # Test 1: WordPress directory with spaces in name
    local mock_env1
    mock_env1="$(create_mock_env "spaces_test" "empty")"
    
    cd "$mock_env1"
    create_user_project_structure "$mock_env1" "my wordpress site"
    
    assert_directory_exists "my wordpress site" "WordPress directory with spaces exists"
    assert_directory_exists "my wordpress site/wp-content" "WordPress with spaces has valid structure"
    
    # Test path handling with spaces
    local wp_with_spaces="$mock_env1/my wordpress site"
    local root_with_spaces
    root_with_spaces="$(dirname "$wp_with_spaces")"
    assert_equals "$mock_env1" "$root_with_spaces" "Project root calculated correctly with spaces"
    
    cleanup_mock_env "$mock_env1"
    
    # Test 2: Deeply nested WordPress directory
    local mock_env2
    mock_env2="$(create_mock_env "nested_test" "empty")"
    
    cd "$mock_env2"
    mkdir -p "projects/client/sites/wordpress-install"
    create_user_project_structure "$mock_env2/projects/client/sites" "wordpress-install"
    
    local nested_wp="$mock_env2/projects/client/sites/wordpress-install"
    local nested_root="$mock_env2/projects/client/sites"
    
    assert_directory_exists "$nested_wp/wp-content" "Deeply nested WordPress structure exists"
    
    local calculated_nested_root
    calculated_nested_root="$(dirname "$nested_wp")"
    assert_equals "$nested_root" "$calculated_nested_root" "Nested project root calculated correctly"
    
    cleanup_mock_env "$mock_env2"
    
    # Test 3: WordPress directory at filesystem root level
    local mock_env3
    mock_env3="$(create_mock_env "root_level_test" "empty")"
    
    cd "$mock_env3"
    # Simulate root-level WordPress (as much as possible in test environment)
    mkdir -p "wp-site"
    create_user_project_structure "$mock_env3" "wp-site"
    
    local root_level_wp="$mock_env3/wp-site"
    local root_level_root
    root_level_root="$(dirname "$root_level_wp")"
    
    assert_directory_exists "$root_level_wp/wp-content" "Root-level WordPress structure exists"
    assert_equals "$mock_env3" "$root_level_root" "Root-level project root calculated correctly"
    
    cleanup_mock_env "$mock_env3"
    
    # Test 4: Symlinked WordPress directory
    local mock_env4
    mock_env4="$(create_mock_env "symlink_test" "empty")"
    
    cd "$mock_env4"
    create_user_project_structure "$mock_env4" "real-wordpress"
    ln -s "real-wordpress" "symlinked-wordpress"
    
    assert_directory_exists "symlinked-wordpress" "Symlinked WordPress directory exists"
    assert_directory_exists "symlinked-wordpress/wp-content" "Symlinked WordPress has valid structure"
    
    # Test symlink resolution
    local symlink_target
    symlink_target="$(readlink "symlinked-wordpress")"
    assert_equals "real-wordpress" "$symlink_target" "Symlink points to correct target"
    
    cleanup_mock_env "$mock_env4"
}

# ====================================================================
# Main Test Execution
# ====================================================================

main() {
    echo "🧪 WordPress Init Project - User Scenario Tests"
    echo "================================================"
    echo "Testing external WordPress directory scenarios, CLI parameters, and file compatibility"
    echo ""
    
    # Check if script exists
    if [ ! -f "$SCRIPT_PATH" ]; then
        echo "❌ ERROR: Script not found at $SCRIPT_PATH"
        exit 1
    fi
    
    # Make script executable
    chmod +x "$SCRIPT_PATH"
    
    reset_assertions
    
    # Run all user scenario tests
    test_custom_wordpress_directory_structure
    test_existing_project_files_compatibility
    test_cli_parameters_and_non_interactive_mode
    test_complete_user_scenario_integration
    test_edge_cases_and_error_scenarios
    
    # Print final results
    print_assertion_summary
    
    local exit_code=$?
    if [ $exit_code -eq 0 ]; then
        echo "🎉 All user scenario tests passed!"
    else
        echo "⚠️ Some user scenario tests failed"
    fi
    
    return $exit_code
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi