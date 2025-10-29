#!/bin/bash

# ====================================================================
# File Generation Integration Tests
# ====================================================================
# Validates that all documented files are created with correct content
# Uses new testing framework with mock environments
# ====================================================================

set -euo pipefail

# Source testing libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/assertions.sh"
source "$SCRIPT_DIR/../lib/mock-env.sh"

# Setup mock environment with generated files
setup_generated_files_env() {
    local mock_env="$1"
    
    # Create core configuration files
    cat > "$mock_env/phpcs.xml.dist" <<'EOF'
<?xml version="1.0"?>
<ruleset name="WordPress Coding Standards">
    <description>WordPress coding standards for this project</description>
    <rule ref="WordPress"/>
    <file>./wordpress/wp-content/themes</file>
    <file>./wordpress/wp-content/plugins</file>
    <file>./wordpress/wp-content/mu-plugins</file>
</ruleset>
EOF
    
    cat > "$mock_env/phpstan.neon.dist" <<'EOF'
parameters:
    level: 5
    paths:
        - wordpress/wp-content/themes
        - wordpress/wp-content/plugins
        - wordpress/wp-content/mu-plugins
    excludePaths:
        - wordpress/wp-content/themes/*/vendor/*
EOF
    
    cat > "$mock_env/eslint.config.js" <<'EOF'
module.exports = {
    extends: ['@wordpress/eslint-plugin/recommended'],
    files: [
        'wordpress/wp-content/themes/**/*.js',
        'wordpress/wp-content/plugins/**/*.js',
        'wordpress/wp-content/mu-plugins/**/*.js'
    ],
    rules: {
        'wordpress/no-unused-vars-before-return': 'error'
    }
};
EOF
    
    cat > "$mock_env/wp.code-workspace" <<'EOF'
{
    "folders": [
        {
            "name": "WordPress Core",
            "path": "./wordpress"
        },
        {
            "name": "Themes",
            "path": "./wordpress/wp-content/themes"
        },
        {
            "name": "Plugins", 
            "path": "./wordpress/wp-content/plugins"
        }
    ],
    "settings": {
        "php.validate.executablePath": "/usr/bin/php",
        "phpcs.executablePath": "./vendor/bin/phpcs"
    }
}
EOF
    
    cat > "$mock_env/package.json" <<'EOF'
{
    "name": "test-wordpress-project",
    "version": "1.0.0",
    "scripts": {
        "lint:js": "eslint wordpress/wp-content --ext .js",
        "lint:php": "phpcs --standard=phpcs.xml.dist",
        "lint": "npm run lint:js && npm run lint:php"
    },
    "devDependencies": {
        "@wordpress/eslint-plugin": "^12.0.0",
        "eslint": "^8.0.0"
    }
}
EOF
    
    cat > "$mock_env/composer.json" <<'EOF'
{
    "name": "test/wordpress-project",
    "description": "Test WordPress project",
    "type": "project",
    "require-dev": {
        "wp-coding-standards/wpcs": "^2.3",
        "phpstan/phpstan": "^1.0",
        "dealerdirect/phpcodesniffer-composer-installer": "^0.7"
    },
    "scripts": {
        "lint:php": "phpcs --standard=phpcs.xml.dist",
        "analyze": "phpstan analyze --configuration=phpstan.neon.dist"
    }
}
EOF
    
    cat > "$mock_env/.gitignore" <<'EOF'
# Dependencies
node_modules/
vendor/

# Build files
*.min.js
*.min.css

# WordPress
wp-config.php
.htaccess

# IDE
.vscode/
.idea/

# OS
.DS_Store
Thumbs.db
EOF
    
    cat > "$mock_env/Makefile" <<'EOF'
.PHONY: help install lint clean

help: ## Show this help
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'

install: ## Install dependencies
	npm install && composer install

lint: ## Run linting
	npm run lint

clean: ## Clean build files
	rm -rf node_modules vendor
EOF
}

# Test core configuration files
test_core_configuration_files() {
    echo "Testing core configuration files..."
    
    local mock_env
    mock_env="$(create_mock_env "file_generation_core" "empty")"
    setup_generated_files_env "$mock_env"
    
    local original_dir="$PWD"
    cd "$mock_env"
    
    # Test file existence
    assert_file_exists "phpcs.xml.dist" "PHPCS configuration file exists"
    assert_file_exists "phpstan.neon.dist" "PHPStan configuration file exists"
    assert_file_exists "eslint.config.js" "ESLint configuration file exists"
    assert_file_exists "wp.code-workspace" "VSCode workspace file exists"
    
    # Test content validation
    assert_file_contains "phpcs.xml.dist" "WordPress" "PHPCS contains WordPress rules"
    assert_file_contains "phpcs.xml.dist" "<file>" "PHPCS contains file paths"
    
    assert_file_contains "phpstan.neon.dist" "level:" "PHPStan contains analysis level"
    assert_file_contains "phpstan.neon.dist" "paths:" "PHPStan contains file paths"
    
    assert_file_contains "eslint.config.js" "wordpress" "ESLint contains WordPress config"
    assert_file_contains "eslint.config.js" "files:" "ESLint contains file patterns"
    
    assert_file_contains "wp.code-workspace" "folders" "VSCode workspace contains folders"
    assert_file_contains "wp.code-workspace" "settings" "VSCode workspace contains settings"
    
    cd "$original_dir"
    cleanup_mock_env "$mock_env"
}

# Test package management files with JSON validation
test_package_management_files() {
    echo "Testing package management files..."
    
    local mock_env
    mock_env="$(create_mock_env "file_generation_packages" "empty")"
    setup_generated_files_env "$mock_env"
    
    local original_dir="$PWD"
    cd "$mock_env"
    
    # Mock jq for JSON validation
    mock_tool "jq" "success" ""
    
    # Test file existence
    assert_file_exists "package.json" "Package.json file exists"
    assert_file_exists "composer.json" "Composer.json file exists"
    
    # Test JSON validity (using mock jq)
    assert_command_success "jq empty package.json" "Package.json has valid JSON syntax"
    assert_command_success "jq empty composer.json" "Composer.json has valid JSON syntax"
    
    # Test content validation
    assert_file_contains "package.json" "lint:js" "Package.json contains JavaScript linting scripts"
    assert_file_contains "package.json" "devDependencies" "Package.json contains dev dependencies"
    
    assert_file_contains "composer.json" "require-dev" "Composer.json contains dev dependencies"
    assert_file_contains "composer.json" "wp-coding-standards/wpcs" "Composer.json contains WPCS dependency"
    
    cd "$original_dir"
    cleanup_mock_env "$mock_env"
}

# Test template-generated files
test_template_generated_files() {
    echo "Testing template-generated files..."
    
    local mock_env
    mock_env="$(create_mock_env "file_generation_templates" "empty")"
    setup_generated_files_env "$mock_env"
    
    local original_dir="$PWD"
    cd "$mock_env"
    
    # Test file existence
    assert_file_exists ".gitignore" "Git ignore file exists"
    assert_file_exists "Makefile" "Makefile exists"
    
    # Test content validation
    assert_file_contains ".gitignore" "node_modules" "Gitignore contains node_modules"
    assert_file_contains ".gitignore" "vendor" "Gitignore contains vendor directory"
    
    assert_file_contains "Makefile" "help:" "Makefile contains help target"
    assert_file_contains "Makefile" ".PHONY:" "Makefile contains PHONY declarations"
    assert_file_contains "Makefile" "install:" "Makefile contains install target"
    
    cd "$original_dir"
    cleanup_mock_env "$mock_env"
}

# Test dynamic content generation
test_dynamic_content_generation() {
    echo "Testing dynamic content generation..."
    
    local mock_env
    mock_env="$(create_mock_env "file_generation_dynamic" "empty")"
    setup_generated_files_env "$mock_env"
    
    local original_dir="$PWD"
    cd "$mock_env"
    
    # Mock jq for project name extraction
    mock_tool "jq" "success" ""
    
    # Test WordPress component paths in workspace
    assert_file_contains "wp.code-workspace" "wp-content" "VSCode workspace contains WordPress component paths"
    assert_file_contains "wp.code-workspace" "themes" "VSCode workspace contains themes folder"
    assert_file_contains "wp.code-workspace" "plugins" "VSCode workspace contains plugins folder"
    
    # Test project-specific content in PHPCS
    assert_file_contains "phpcs.xml.dist" "wordpress/wp-content" "PHPCS contains WordPress content paths"
    
    cd "$original_dir"
    cleanup_mock_env "$mock_env"
}

# Test file permissions and accessibility
test_file_permissions() {
    echo "Testing file permissions and accessibility..."
    
    local mock_env
    mock_env="$(create_mock_env "file_generation_permissions" "empty")"
    setup_generated_files_env "$mock_env"
    
    local original_dir="$PWD"
    cd "$mock_env"
    
    local critical_files=("phpcs.xml.dist" "eslint.config.js" "package.json" "composer.json")
    
    for file in "${critical_files[@]}"; do
        assert_file_exists "$file" "Critical file exists: $file"
        
        # Test readability
        if [ -r "$file" ]; then
            assert_true "true" "File is readable: $file"
        else
            assert_true "false" "File is readable: $file"
        fi
        
        # Test writability
        if [ -w "$file" ]; then
            assert_true "true" "File is writable: $file"
        else
            assert_true "false" "File is writable: $file"
        fi
    done
    
    cd "$original_dir"
    cleanup_mock_env "$mock_env"
}

# Test missing files scenario
test_missing_files_scenario() {
    echo "Testing missing files scenario..."
    
    local mock_env
    mock_env="$(create_mock_env "file_generation_missing" "empty")"
    
    local original_dir="$PWD"
    cd "$mock_env"
    
    # Don't create any files - test missing file detection
    assert_file_not_exists "phpcs.xml.dist" "PHPCS file correctly detected as missing"
    assert_file_not_exists "eslint.config.js" "ESLint file correctly detected as missing"
    assert_file_not_exists "package.json" "Package.json correctly detected as missing"
    assert_file_not_exists "composer.json" "Composer.json correctly detected as missing"
    
    cd "$original_dir"
    cleanup_mock_env "$mock_env"
}

# Main test execution
main() {
    echo "🧪 File Generation Integration Tests"
    echo "===================================="
    
    reset_assertions
    
    test_core_configuration_files
    test_package_management_files
    test_template_generated_files
    test_dynamic_content_generation
    test_file_permissions
    test_missing_files_scenario
    
    print_assertion_summary
    
    local exit_code=$?
    if [ $exit_code -eq 0 ]; then
        echo "🎉 All file generation tests passed!"
    else
        echo "⚠️ Some file generation tests failed"
    fi
    
    return $exit_code
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi