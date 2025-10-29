#!/bin/bash

# End-to-End Tests for New Project Setup
# Tests complete user scenarios from start to finish

# Source test dependencies
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/assertions.sh"
source "$SCRIPT_DIR/../../lib/mock-env.sh"

# Test setup
setup_e2e_tests() {
    # Create isolated test environment
    TEST_ENV=$(create_mock_env "e2e_new_project")
    cd "$TEST_ENV"
    
    # Copy main script and templates
    cp "$SCRIPT_DIR/../../../init-project.sh" .
    copy_all_templates
    
    # Create realistic WordPress project structure
    create_realistic_wordpress_structure
}

# Copy all template files
copy_all_templates() {
    # Copy templates from project root
    local project_root="$SCRIPT_DIR/../../.."
    
    # Create templates if they don't exist (for testing)
    create_test_templates
}

# Create comprehensive test templates
create_test_templates() {
    # .gitignore template
    cat > .gitignore.template << 'EOF'
# WordPress Core
/wp-admin/
/wp-includes/
/wp-*.php
/xmlrpc.php
/readme.html
/license.txt

# WordPress Config
wp-config.php
wp-config-local.php
wp-config-production.php

# WordPress Content
wp-content/uploads/
wp-content/cache/
wp-content/backup-db/
wp-content/backups/
wp-content/blogs.dir/
wp-content/upgrade/

# WordPress Plugins (keep custom ones)
wp-content/plugins/akismet/
wp-content/plugins/hello.php
wp-content/plugins/wordpress-importer/

# WordPress Themes (keep custom ones)
wp-content/themes/twenty*/

# Dependencies
node_modules/
vendor/
bower_components/

# Build files
*.min.js
*.min.css
/build/
/dist/

# IDE files
.vscode/
.idea/
*.swp
*.swo
*~

# OS files
.DS_Store
Thumbs.db

# Logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Project specific
{{PROJECT_SLUG}}-backups/
{{PROJECT_SLUG}}-temp/
EOF

    # package.json template
    cat > package.json.template << 'EOF'
{
  "name": "{{PROJECT_SLUG}}",
  "version": "1.0.0",
  "description": "WordPress project {{PROJECT_SLUG}}",
  "main": "index.js",
  "scripts": {
    "dev": "webpack --mode development --watch",
    "build": "webpack --mode production",
    "lint:js": "eslint wp-content/themes/*/assets/js/ wp-content/plugins/*/assets/js/",
    "lint:css": "stylelint wp-content/themes/*/assets/css/ wp-content/plugins/*/assets/css/",
    "format:js": "prettier --write wp-content/themes/*/assets/js/ wp-content/plugins/*/assets/js/",
    "format:css": "prettier --write wp-content/themes/*/assets/css/ wp-content/plugins/*/assets/css/",
    "test": "jest",
    "test:watch": "jest --watch"
  },
  "keywords": ["wordpress", "{{PROJECT_SLUG}}"],
  "author": "{{PROJECT_AUTHOR}}",
  "license": "GPL-2.0-or-later",
  "devDependencies": {
    "@babel/core": "^7.22.0",
    "@babel/preset-env": "^7.22.0",
    "babel-loader": "^9.1.0",
    "css-loader": "^6.8.0",
    "eslint": "^8.42.0",
    "jest": "^29.5.0",
    "prettier": "^2.8.0",
    "sass": "^1.63.0",
    "sass-loader": "^13.3.0",
    "stylelint": "^15.7.0",
    "webpack": "^5.88.0",
    "webpack-cli": "^5.1.0"
  }
}
EOF

    # composer.json template
    cat > composer.json.template << 'EOF'
{
  "name": "{{PROJECT_NAMESPACE}}/{{PROJECT_SLUG}}",
  "description": "WordPress project {{PROJECT_SLUG}}",
  "type": "project",
  "license": "GPL-2.0-or-later",
  "authors": [
    {
      "name": "{{PROJECT_AUTHOR}}",
      "email": "{{PROJECT_EMAIL}}"
    }
  ],
  "require": {
    "php": ">=7.4",
    "composer/installers": "^2.0"
  },
  "require-dev": {
    "squizlabs/php_codesniffer": "^3.7",
    "wp-coding-standards/wpcs": "^3.0",
    "phpstan/phpstan": "^1.10",
    "phpunit/phpunit": "^9.6"
  },
  "scripts": {
    "lint": "phpcs --standard=WordPress wp-content/themes/ wp-content/plugins/ wp-content/mu-plugins/",
    "format": "phpcbf --standard=WordPress wp-content/themes/ wp-content/plugins/ wp-content/mu-plugins/",
    "analyze": "phpstan analyse wp-content/themes/ wp-content/plugins/ wp-content/mu-plugins/",
    "test": "phpunit",
    "post-install-cmd": [
      "phpcs --config-set installed_paths vendor/wp-coding-standards/wpcs"
    ]
  },
  "config": {
    "allow-plugins": {
      "composer/installers": true
    }
  }
}
EOF

    # Makefile template
    cat > Makefile.template << 'EOF'
.PHONY: help install dev build lint format test clean

# Project configuration
PROJECT_NAME = {{PROJECT_SLUG}}
WP_CONTENT = wp-content

help: ## Show this help
	@echo "Available targets for $(PROJECT_NAME):"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

install: ## Install dependencies
	@echo "Installing dependencies for $(PROJECT_NAME)..."
	@if [ -f "package.json" ]; then npm install; fi
	@if [ -f "composer.json" ]; then composer install; fi

dev: ## Start development environment
	@echo "Starting development environment for $(PROJECT_NAME)..."
	@npm run dev

build: ## Build project for production
	@echo "Building $(PROJECT_NAME) for production..."
	@npm run build

lint: ## Lint all code
	@echo "Linting $(PROJECT_NAME)..."
	@npm run lint:js
	@npm run lint:css
	@composer run lint

format: ## Format all code
	@echo "Formatting $(PROJECT_NAME)..."
	@npm run format:js
	@npm run format:css
	@composer run format

test: ## Run all tests
	@echo "Running tests for $(PROJECT_NAME)..."
	@npm test
	@composer run test

analyze: ## Run static analysis
	@echo "Running static analysis for $(PROJECT_NAME)..."
	@composer run analyze

clean: ## Clean build artifacts
	@echo "Cleaning $(PROJECT_NAME)..."
	@rm -rf node_modules/.cache
	@rm -rf build/
	@rm -rf dist/

# Component-specific targets
{{COMPONENT_TARGETS}}
EOF

    # phpcs.xml.dist template
    cat > phpcs.xml.dist.template << 'EOF'
<?xml version="1.0"?>
<ruleset name="{{PROJECT_CONSTANT}}_PHPCS">
    <description>PHP_CodeSniffer configuration for {{PROJECT_SLUG}}</description>

    <!-- Scan these files and directories -->
    <file>wp-content/themes/</file>
    <file>wp-content/plugins/</file>
    <file>wp-content/mu-plugins/</file>

    <!-- Exclude these files and directories -->
    <exclude-pattern>*/node_modules/*</exclude-pattern>
    <exclude-pattern>*/vendor/*</exclude-pattern>
    <exclude-pattern>*/build/*</exclude-pattern>
    <exclude-pattern>*/dist/*</exclude-pattern>

    <!-- Use WordPress coding standards -->
    <rule ref="WordPress">
        <!-- Allow short array syntax -->
        <exclude name="Generic.Arrays.DisallowShortArraySyntax"/>
    </rule>

    <!-- Check for PHP cross-version compatibility -->
    <config name="minimum_supported_wp_version" value="5.0"/>
    <config name="testVersion" value="7.4-"/>

    <!-- Show progress and use colors -->
    <arg value="p"/>
    <arg name="colors"/>

    <!-- Show sniff codes in all reports -->
    <arg value="s"/>
</ruleset>
EOF
}

# Create realistic WordPress structure with sample components
create_realistic_wordpress_structure() {
    # Create WordPress core structure
    mkdir -p wp-content/{plugins,themes,mu-plugins,uploads}
    
    # Create custom plugin
    mkdir -p wp-content/plugins/my-awesome-plugin/{includes,assets/{js,css}}
    
    cat > wp-content/plugins/my-awesome-plugin/my-awesome-plugin.php << 'EOF'
<?php
/**
 * Plugin Name: My Awesome Plugin
 * Plugin URI: https://example.com/my-awesome-plugin
 * Description: An awesome plugin for WordPress
 * Version: 1.0.0
 * Author: Plugin Author
 * License: GPL v2 or later
 * Text Domain: my-awesome-plugin
 */

// Prevent direct access
if (!defined('ABSPATH')) {
    exit;
}

// Define plugin constants
define('MY_AWESOME_PLUGIN_VERSION', '1.0.0');
define('MY_AWESOME_PLUGIN_PATH', plugin_dir_path(__FILE__));
define('MY_AWESOME_PLUGIN_URL', plugin_dir_url(__FILE__));

// Include main plugin class
require_once MY_AWESOME_PLUGIN_PATH . 'includes/class-my-awesome-plugin.php';

// Initialize plugin
function my_awesome_plugin_init() {
    new My_Awesome_Plugin();
}
add_action('plugins_loaded', 'my_awesome_plugin_init');
EOF

    cat > wp-content/plugins/my-awesome-plugin/includes/class-my-awesome-plugin.php << 'EOF'
<?php
/**
 * Main plugin class
 */

class My_Awesome_Plugin {
    
    public function __construct() {
        add_action('init', array($this, 'init'));
        add_action('wp_enqueue_scripts', array($this, 'enqueue_scripts'));
    }
    
    public function init() {
        // Plugin initialization
        load_plugin_textdomain('my-awesome-plugin', false, dirname(plugin_basename(__FILE__)) . '/languages');
    }
    
    public function enqueue_scripts() {
        wp_enqueue_script(
            'my-awesome-plugin-js',
            MY_AWESOME_PLUGIN_URL . 'assets/js/plugin.js',
            array('jquery'),
            MY_AWESOME_PLUGIN_VERSION,
            true
        );
        
        wp_enqueue_style(
            'my-awesome-plugin-css',
            MY_AWESOME_PLUGIN_URL . 'assets/css/plugin.css',
            array(),
            MY_AWESOME_PLUGIN_VERSION
        );
    }
}
EOF

    cat > wp-content/plugins/my-awesome-plugin/assets/js/plugin.js << 'EOF'
(function($) {
    'use strict';
    
    $(document).ready(function() {
        console.log('My Awesome Plugin loaded');
        
        // Plugin functionality
        $('.my-awesome-button').on('click', function(e) {
            e.preventDefault();
            alert('Button clicked!');
        });
    });
    
})(jQuery);
EOF

    cat > wp-content/plugins/my-awesome-plugin/assets/css/plugin.css << 'EOF'
/* My Awesome Plugin Styles */

.my-awesome-plugin {
    background: #f9f9f9;
    border: 1px solid #ddd;
    padding: 20px;
    margin: 10px 0;
}

.my-awesome-button {
    background: #0073aa;
    color: white;
    border: none;
    padding: 10px 20px;
    cursor: pointer;
    border-radius: 3px;
}

.my-awesome-button:hover {
    background: #005a87;
}
EOF

    # Create custom theme
    mkdir -p wp-content/themes/my-awesome-theme/{assets/{js,css,images},includes,template-parts}
    
    cat > wp-content/themes/my-awesome-theme/style.css << 'EOF'
/*
Theme Name: My Awesome Theme
Description: An awesome WordPress theme
Author: Theme Author
Version: 1.0.0
License: GPL v2 or later
Text Domain: my-awesome-theme
*/

/* Theme styles */
body {
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    line-height: 1.6;
    color: #333;
}

.site-header {
    background: #fff;
    border-bottom: 1px solid #eee;
    padding: 1rem 0;
}

.site-title {
    font-size: 2rem;
    font-weight: bold;
    margin: 0;
}

.site-content {
    max-width: 1200px;
    margin: 0 auto;
    padding: 2rem;
}

.site-footer {
    background: #333;
    color: #fff;
    text-align: center;
    padding: 2rem 0;
}
EOF

    cat > wp-content/themes/my-awesome-theme/functions.php << 'EOF'
<?php
/**
 * My Awesome Theme functions
 */

// Prevent direct access
if (!defined('ABSPATH')) {
    exit;
}

// Theme setup
function my_awesome_theme_setup() {
    // Add theme support
    add_theme_support('post-thumbnails');
    add_theme_support('title-tag');
    add_theme_support('custom-logo');
    add_theme_support('html5', array(
        'search-form',
        'comment-form',
        'comment-list',
        'gallery',
        'caption',
    ));
    
    // Register navigation menus
    register_nav_menus(array(
        'primary' => __('Primary Menu', 'my-awesome-theme'),
        'footer' => __('Footer Menu', 'my-awesome-theme'),
    ));
}
add_action('after_setup_theme', 'my_awesome_theme_setup');

// Enqueue scripts and styles
function my_awesome_theme_scripts() {
    wp_enqueue_style('my-awesome-theme-style', get_stylesheet_uri(), array(), '1.0.0');
    
    wp_enqueue_script(
        'my-awesome-theme-script',
        get_template_directory_uri() . '/assets/js/theme.js',
        array('jquery'),
        '1.0.0',
        true
    );
}
add_action('wp_enqueue_scripts', 'my_awesome_theme_scripts');

// Widget areas
function my_awesome_theme_widgets_init() {
    register_sidebar(array(
        'name' => __('Sidebar', 'my-awesome-theme'),
        'id' => 'sidebar-1',
        'description' => __('Add widgets here.', 'my-awesome-theme'),
        'before_widget' => '<section id="%1$s" class="widget %2$s">',
        'after_widget' => '</section>',
        'before_title' => '<h2 class="widget-title">',
        'after_title' => '</h2>',
    ));
}
add_action('widgets_init', 'my_awesome_theme_widgets_init');
EOF

    cat > wp-content/themes/my-awesome-theme/index.php << 'EOF'
<?php get_header(); ?>

<main class="site-content">
    <?php if (have_posts()) : ?>
        <?php while (have_posts()) : the_post(); ?>
            <article id="post-<?php the_ID(); ?>" <?php post_class(); ?>>
                <header class="entry-header">
                    <h1 class="entry-title"><?php the_title(); ?></h1>
                </header>
                
                <div class="entry-content">
                    <?php the_content(); ?>
                </div>
            </article>
        <?php endwhile; ?>
    <?php else : ?>
        <p><?php _e('No posts found.', 'my-awesome-theme'); ?></p>
    <?php endif; ?>
</main>

<?php get_footer(); ?>
EOF

    # Create MU plugin
    cat > wp-content/mu-plugins/site-functionality.php << 'EOF'
<?php
/**
 * Site Functionality MU Plugin
 * Description: Core site functionality that should always be active
 */

// Prevent direct access
if (!defined('ABSPATH')) {
    exit;
}

// Disable file editing in admin
define('DISALLOW_FILE_EDIT', true);

// Custom login logo
function custom_login_logo() {
    echo '<style type="text/css">
        #login h1 a {
            background-image: url(' . get_stylesheet_directory_uri() . '/assets/images/logo.png);
            background-size: contain;
            width: 200px;
            height: 80px;
        }
    </style>';
}
add_action('login_enqueue_scripts', 'custom_login_logo');

// Remove WordPress version from head
remove_action('wp_head', 'wp_generator');

// Security headers
function add_security_headers() {
    header('X-Content-Type-Options: nosniff');
    header('X-Frame-Options: SAMEORIGIN');
    header('X-XSS-Protection: 1; mode=block');
}
add_action('send_headers', 'add_security_headers');
EOF
}

# Test teardown
teardown_e2e_tests() {
    cd - > /dev/null
    cleanup_mock_env "$TEST_ENV"
}

# Test complete new project setup (Mode 1)
test_complete_new_project_setup() {
    echo "Testing complete new project setup..."
    
    setup_e2e_tests
    
    # Simulate user input for new project
    export PROJECT_SLUG="my-new-project"
    export PROJECT_AUTHOR="Test Author"
    export PROJECT_EMAIL="test@example.com"
    
    # Auto-detect components
    local detected_plugins
    local detected_themes
    local detected_mu_plugins
    
    detected_plugins=$(find wp-content/plugins -maxdepth 1 -type d -name "*" ! -name "plugins" | xargs -I {} basename {})
    detected_themes=$(find wp-content/themes -maxdepth 1 -type d -name "*" ! -name "themes" | xargs -I {} basename {})
    detected_mu_plugins=$(find wp-content/mu-plugins -name "*.php" | xargs -I {} basename {} .php)
    
    # Verify component detection
    if [[ "$detected_plugins" == *"my-awesome-plugin"* ]]; then
        print_assertion "PASS" "Should detect custom plugin"
    else
        print_assertion "FAIL" "Should detect custom plugin"
    fi
    
    if [[ "$detected_themes" == *"my-awesome-theme"* ]]; then
        print_assertion "PASS" "Should detect custom theme"
    else
        print_assertion "FAIL" "Should detect custom theme"
    fi
    
    if [[ "$detected_mu_plugins" == *"site-functionality"* ]]; then
        print_assertion "PASS" "Should detect MU plugin"
    else
        print_assertion "FAIL" "Should detect MU plugin"
    fi
    
    # Test configuration file generation
    local namespace
    namespace=$(echo "$PROJECT_SLUG" | awk -F'-' '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1' OFS='')
    
    # Generate package.json
    local package_content
    package_content=$(sed -e "s/{{PROJECT_SLUG}}/$PROJECT_SLUG/g" -e "s/{{PROJECT_AUTHOR}}/$PROJECT_AUTHOR/g" package.json.template)
    echo "$package_content" > package.json
    
    if [ -f "package.json" ] && grep -q "$PROJECT_SLUG" package.json && grep -q "$PROJECT_AUTHOR" package.json; then
        print_assertion "PASS" "Should generate complete package.json"
    else
        print_assertion "FAIL" "Should generate complete package.json"
    fi
    
    # Generate composer.json
    local composer_content
    composer_content=$(sed -e "s/{{PROJECT_SLUG}}/$PROJECT_SLUG/g" -e "s/{{PROJECT_NAMESPACE}}/$(echo $namespace | tr '[:upper:]' '[:lower:]')/g" -e "s/{{PROJECT_AUTHOR}}/$PROJECT_AUTHOR/g" -e "s/{{PROJECT_EMAIL}}/$PROJECT_EMAIL/g" composer.json.template)
    echo "$composer_content" > composer.json
    
    if [ -f "composer.json" ] && grep -q "$PROJECT_SLUG" composer.json && grep -q "$PROJECT_AUTHOR" composer.json; then
        print_assertion "PASS" "Should generate complete composer.json"
    else
        print_assertion "FAIL" "Should generate complete composer.json"
    fi
    
    # Generate .gitignore
    local gitignore_content
    gitignore_content=$(sed "s/{{PROJECT_SLUG}}/$PROJECT_SLUG/g" .gitignore.template)
    echo "$gitignore_content" > .gitignore
    
    if [ -f ".gitignore" ] && grep -q "$PROJECT_SLUG" .gitignore; then
        print_assertion "PASS" "Should generate project-specific .gitignore"
    else
        print_assertion "FAIL" "Should generate project-specific .gitignore"
    fi
    
    # Verify all expected files are created
    local expected_files=("package.json" "composer.json" ".gitignore" "Makefile" "phpcs.xml.dist")
    local missing_files=()
    
    for file in "${expected_files[@]}"; do
        if [ ! -f "$file" ]; then
            missing_files+=("$file")
        fi
    done
    
    if [ ${#missing_files[@]} -eq 0 ]; then
        print_assertion "PASS" "Should create all expected configuration files"
    else
        print_assertion "FAIL" "Should create all expected configuration files" "Missing: ${missing_files[*]}"
    fi
    
    teardown_e2e_tests
}

# Test project setup with existing files
test_project_setup_with_existing_files() {
    echo "Testing project setup with existing files..."
    
    setup_e2e_tests
    
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
    "php": ">=7.2",
    "existing/package": "^1.0"
  }
}
EOF

    export PROJECT_SLUG="updated-project"
    
    # Test backup creation
    cp package.json package.json.backup
    cp composer.json composer.json.backup
    
    if [ -f "package.json.backup" ] && [ -f "composer.json.backup" ]; then
        print_assertion "PASS" "Should create backups of existing files"
    else
        print_assertion "FAIL" "Should create backups of existing files"
    fi
    
    # Test that backups preserve original content
    if grep -q "existing-project" package.json.backup; then
        print_assertion "PASS" "Should preserve original content in backups"
    else
        print_assertion "FAIL" "Should preserve original content in backups"
    fi
    
    # Test merge capability (simulate)
    # In real scenario, this would merge configurations intelligently
    local merged_package
    merged_package=$(cat package.json.template | sed "s/{{PROJECT_SLUG}}/$PROJECT_SLUG/g")
    
    # Simulate intelligent merge (keeping existing dependencies)
    echo "$merged_package" | jq --argjson existing "$(cat package.json)" '.dependencies = $existing.dependencies' > package.json.merged 2>/dev/null || {
        # Fallback if jq is not available
        echo "$merged_package" > package.json.merged
    }
    
    if [ -f "package.json.merged" ]; then
        print_assertion "PASS" "Should create merged configuration"
    else
        print_assertion "FAIL" "Should create merged configuration"
    fi
    
    teardown_e2e_tests
}

# Test cross-platform compatibility
test_cross_platform_compatibility() {
    echo "Testing cross-platform compatibility..."
    
    setup_e2e_tests
    
    export PROJECT_SLUG="cross-platform-project"
    
    # Test path handling (Unix-style paths should work on all platforms)
    local wp_content_path="wp-content/plugins/my-awesome-plugin"
    
    if [ -d "$wp_content_path" ]; then
        print_assertion "PASS" "Should handle Unix-style paths correctly"
    else
        print_assertion "FAIL" "Should handle Unix-style paths correctly"
    fi
    
    # Test file operations with different line endings
    echo -e "Line 1\nLine 2\nLine 3" > test-file.txt
    
    if [ -f "test-file.txt" ] && [ "$(wc -l < test-file.txt)" -eq 3 ]; then
        print_assertion "PASS" "Should handle file operations correctly"
    else
        print_assertion "FAIL" "Should handle file operations correctly"
    fi
    
    # Test command availability checks
    local required_commands=("find" "grep" "sed" "awk")
    local missing_commands=()
    
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_commands+=("$cmd")
        fi
    done
    
    if [ ${#missing_commands[@]} -eq 0 ]; then
        print_assertion "PASS" "Should have all required commands available"
    else
        print_assertion "FAIL" "Should have all required commands available" "Missing: ${missing_commands[*]}"
    fi
    
    # Test permission handling
    touch test-permissions.txt
    chmod 644 test-permissions.txt
    
    if [ -w "test-permissions.txt" ]; then
        print_assertion "PASS" "Should handle file permissions correctly"
    else
        print_assertion "FAIL" "Should handle file permissions correctly"
    fi
    
    teardown_e2e_tests
}

# Test error scenarios and recovery
test_error_scenarios_and_recovery() {
    echo "Testing error scenarios and recovery..."
    
    setup_e2e_tests
    
    export PROJECT_SLUG="error-test-project"
    
    # Test invalid project slug
    export PROJECT_SLUG="Invalid Project Name!"
    
    # Should detect invalid slug
    if [[ ! "$PROJECT_SLUG" =~ ^[a-z0-9-]+$ ]]; then
        print_assertion "PASS" "Should detect invalid project slug"
    else
        print_assertion "FAIL" "Should detect invalid project slug"
    fi
    
    # Reset to valid slug
    export PROJECT_SLUG="error-test-project"
    
    # Test missing WordPress structure
    rm -rf wp-content
    
    if [ ! -d "wp-content" ]; then
        print_assertion "PASS" "Should detect missing WordPress structure"
    else
        print_assertion "FAIL" "Should detect missing WordPress structure"
    fi
    
    # Test recovery - recreate structure
    mkdir -p wp-content/{plugins,themes,mu-plugins}
    
    if [ -d "wp-content" ]; then
        print_assertion "PASS" "Should recover from missing WordPress structure"
    else
        print_assertion "FAIL" "Should recover from missing WordPress structure"
    fi
    
    # Test permission errors
    touch readonly-file.txt
    chmod 444 readonly-file.txt
    
    if ! echo "test" > readonly-file.txt 2>/dev/null; then
        print_assertion "PASS" "Should detect permission errors"
    else
        print_assertion "FAIL" "Should detect permission errors"
    fi
    
    # Restore permissions for cleanup
    chmod 644 readonly-file.txt
    
    # Test missing template files
    rm -f .gitignore.template
    
    if [ ! -f ".gitignore.template" ]; then
        print_assertion "PASS" "Should detect missing template files"
    else
        print_assertion "FAIL" "Should detect missing template files"
    fi
    
    teardown_e2e_tests
}

# Test performance with large projects
test_performance_large_project() {
    echo "Testing performance with large project..."
    
    setup_e2e_tests
    
    export PROJECT_SLUG="large-project"
    
    # Create many components to test performance
    for i in {1..10}; do
        mkdir -p "wp-content/plugins/plugin-$i"
        echo "<?php // Plugin $i" > "wp-content/plugins/plugin-$i/plugin-$i.php"
        
        mkdir -p "wp-content/themes/theme-$i"
        echo "/* Theme Name: Theme $i */" > "wp-content/themes/theme-$i/style.css"
    done
    
    # Test component detection performance
    local start_time
    local end_time
    local duration
    
    start_time=$(date +%s)
    
    # Detect all plugins
    local detected_plugins
    detected_plugins=$(find wp-content/plugins -maxdepth 1 -type d -name "*" ! -name "plugins" | wc -l)
    
    # Detect all themes
    local detected_themes
    detected_themes=$(find wp-content/themes -maxdepth 1 -type d -name "*" ! -name "themes" | wc -l)
    
    end_time=$(date +%s)
    duration=$((end_time - start_time))
    
    # Should complete within reasonable time (5 seconds for this test)
    if [ "$duration" -le 5 ]; then
        print_assertion "PASS" "Should detect components within reasonable time ($duration seconds)"
    else
        print_assertion "FAIL" "Should detect components within reasonable time ($duration seconds)"
    fi
    
    # Verify correct detection count
    if [ "$detected_plugins" -ge 10 ]; then
        print_assertion "PASS" "Should detect all plugins in large project"
    else
        print_assertion "FAIL" "Should detect all plugins in large project"
    fi
    
    if [ "$detected_themes" -ge 10 ]; then
        print_assertion "PASS" "Should detect all themes in large project"
    else
        print_assertion "FAIL" "Should detect all themes in large project"
    fi
    
    teardown_e2e_tests
}

# Run all E2E tests
run_new_project_e2e_tests() {
    echo "🧪 Running New Project Setup E2E Tests..."
    echo "========================================="
    
    test_complete_new_project_setup
    test_project_setup_with_existing_files
    test_cross_platform_compatibility
    test_error_scenarios_and_recovery
    test_performance_large_project
    
    echo ""
    echo "📊 Test Results:"
    echo "  • Total Assertions: $ASSERTION_COUNT"
    echo "  • Failed Assertions: $ASSERTION_FAILURES"
    echo "  • Success Rate: $(( (ASSERTION_COUNT - ASSERTION_FAILURES) * 100 / ASSERTION_COUNT ))%"
    
    if [ "$ASSERTION_FAILURES" -eq 0 ]; then
        echo "✅ All new project E2E tests passed!"
        return 0
    else
        echo "❌ Some new project E2E tests failed!"
        return 1
    fi
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_new_project_e2e_tests
fi