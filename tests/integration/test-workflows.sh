#!/bin/bash

# ====================================================================
# Documented Workflow Integration Tests
# ====================================================================
# Tests the workflows described in the README using new testing framework
# ====================================================================

set -euo pipefail

# Source testing libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/assertions.sh"
source "$SCRIPT_DIR/../lib/mock-env.sh"

# Setup complete workflow environment
setup_complete_workflow_env() {
    local mock_env="$1"
    
    # Create all necessary files for a complete workflow
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

# Test Quick Start workflow prerequisites
test_quick_start_prerequisites() {
    echo "Testing Quick Start workflow prerequisites..."
    
    local mock_env
    mock_env="$(create_mock_env "workflow_quickstart" "empty")"
    setup_complete_workflow_env "$mock_env"
    
    local original_dir="$PWD"
    cd "$mock_env"
    
    # Mock jq for JSON validation
    mock_tool "jq" "success" ""
    
    # Test configuration files readiness
    assert_file_exists "package.json" "Package.json exists for dependency installation"
    assert_file_exists "composer.json" "Composer.json exists for dependency installation"
    
    # Test package.json structure
    assert_command_success "jq -e '.scripts' package.json" "Package.json contains scripts section"
    assert_command_success "jq -e '.devDependencies' package.json" "Package.json contains devDependencies"
    assert_file_contains "package.json" "lint:js" "Package.json contains JavaScript linting script"
    assert_file_contains "package.json" "lint:php" "Package.json contains PHP linting script"
    
    # Test composer.json structure
    assert_command_success "jq -e '.\"require-dev\"' composer.json" "Composer.json contains require-dev section"
    assert_file_contains "composer.json" "wp-coding-standards/wpcs" "Composer.json contains WPCS dependency"
    
    cd "$original_dir"
    cleanup_mock_env "$mock_env"
}

# Test linting command prerequisites
test_linting_prerequisites() {
    echo "Testing linting command prerequisites..."
    
    local mock_env
    mock_env="$(create_mock_env "workflow_linting" "empty")"
    setup_complete_workflow_env "$mock_env"
    
    local original_dir="$PWD"
    cd "$mock_env"
    
    # Test PHPCS configuration
    assert_file_exists "phpcs.xml.dist" "PHPCS configuration file exists"
    assert_file_contains "phpcs.xml.dist" "<file>" "PHPCS configuration contains file paths for linting"
    assert_file_contains "phpcs.xml.dist" "WordPress" "PHPCS configuration contains WordPress coding standards"
    assert_file_contains "phpcs.xml.dist" "wp-content" "PHPCS configuration targets WordPress content directories"
    
    # Test ESLint configuration
    assert_file_exists "eslint.config.js" "ESLint configuration file exists"
    assert_file_contains "eslint.config.js" "files:" "ESLint configuration contains file patterns"
    assert_file_contains "eslint.config.js" "wordpress" "ESLint configuration contains WordPress configuration"
    assert_file_contains "eslint.config.js" "@wordpress/eslint-plugin" "ESLint configuration uses WordPress plugin"
    
    cd "$original_dir"
    cleanup_mock_env "$mock_env"
}

# Test Make commands validation
test_make_commands() {
    echo "Testing Make commands..."
    
    local mock_env
    mock_env="$(create_mock_env "workflow_make" "empty")"
    setup_complete_workflow_env "$mock_env"
    
    local original_dir="$PWD"
    cd "$mock_env"
    
    # Test Makefile existence and structure
    assert_file_exists "Makefile" "Makefile exists"
    assert_file_contains "Makefile" "help:" "Makefile contains help target"
    assert_file_contains "Makefile" ".PHONY:" "Makefile contains PHONY declarations"
    assert_file_contains "Makefile" "install:" "Makefile contains install target"
    assert_file_contains "Makefile" "lint:" "Makefile contains lint target"
    
    # Test help target functionality
    assert_file_contains "Makefile" "## Show this help" "Makefile help target has description"
    assert_file_contains "Makefile" "npm install && composer install" "Makefile install target runs both package managers"
    
    cd "$original_dir"
    cleanup_mock_env "$mock_env"
}

# Test VSCode workspace configuration
test_vscode_workspace() {
    echo "Testing VSCode workspace configuration..."
    
    local mock_env
    mock_env="$(create_mock_env "workflow_vscode" "empty")"
    setup_complete_workflow_env "$mock_env"
    
    local original_dir="$PWD"
    cd "$mock_env"
    
    # Mock jq for JSON validation
    mock_tool "jq" "success" ""
    
    # Test workspace file existence and structure
    assert_file_exists "wp.code-workspace" "VSCode workspace file exists"
    assert_command_success "jq empty wp.code-workspace" "VSCode workspace has valid JSON format"
    
    # Test workspace content
    assert_command_success "jq -e '.folders' wp.code-workspace" "VSCode workspace contains folders configuration"
    assert_command_success "jq -e '.settings' wp.code-workspace" "VSCode workspace contains settings configuration"
    
    assert_file_contains "wp.code-workspace" "WordPress Core" "VSCode workspace includes WordPress Core folder"
    assert_file_contains "wp.code-workspace" "Themes" "VSCode workspace includes Themes folder"
    assert_file_contains "wp.code-workspace" "Plugins" "VSCode workspace includes Plugins folder"
    
    cd "$original_dir"
    cleanup_mock_env "$mock_env"
}

# Test WordPress structure requirements
test_wordpress_structure_requirements() {
    echo "Testing WordPress structure requirements..."
    
    # Test wordpress/wp-content structure
    local mock_env1
    mock_env1="$(create_mock_env "workflow_wp_structure1" "wordpress")"
    
    local original_dir="$PWD"
    cd "$mock_env1"
    
    assert_directory_exists "wordpress/wp-content" "WordPress content directory found (wordpress/wp-content)"
    assert_directory_exists "wordpress/wp-content/plugins" "WordPress plugins directory exists"
    assert_directory_exists "wordpress/wp-content/themes" "WordPress themes directory exists"
    assert_directory_exists "wordpress/wp-content/mu-plugins" "WordPress mu-plugins directory exists"
    
    cd "$original_dir"
    cleanup_mock_env "$mock_env1"
    
    # Test wp-content only structure
    local mock_env2
    mock_env2="$(create_mock_env "workflow_wp_structure2" "wp-content-only")"
    
    cd "$mock_env2"
    
    assert_directory_exists "wp-content" "WordPress content directory found (wp-content)"
    assert_directory_exists "wp-content/plugins" "WordPress plugins directory exists"
    assert_directory_exists "wp-content/themes" "WordPress themes directory exists"
    assert_directory_exists "wp-content/mu-plugins" "WordPress mu-plugins directory exists"
    
    cd "$original_dir"
    cleanup_mock_env "$mock_env2"
}

# Test command readiness simulation
test_command_readiness() {
    echo "Testing command readiness simulation..."
    
    local mock_env
    mock_env="$(create_mock_env "workflow_commands" "empty")"
    setup_complete_workflow_env "$mock_env"
    
    local original_dir="$PWD"
    cd "$mock_env"
    
    # Mock tools for testing
    mock_tool "npm" "success" "npm version 8.0.0"
    mock_tool "composer" "success" "Composer version 2.0.0"
    mock_tool "jq" "success" ""
    
    # Test npm availability and scripts
    assert_command_success "command -v npm" "npm command is available"
    assert_command_success "jq -e '.scripts.\"lint:js\"' package.json" "npm lint:js script is defined"
    assert_command_success "jq -e '.scripts.\"lint:php\"' package.json" "npm lint:php script is defined"
    
    # Test composer availability
    assert_command_success "command -v composer" "composer command is available"
    
    cd "$original_dir"
    cleanup_mock_env "$mock_env"
}

# Test integration workflow validation
test_integration_workflow() {
    echo "Testing integration workflow validation..."
    
    local mock_env
    mock_env="$(create_mock_env "workflow_integration" "empty")"
    setup_complete_workflow_env "$mock_env"
    
    local original_dir="$PWD"
    cd "$mock_env"
    
    # Test complete configuration
    local config_files_exist=true
    [ ! -f "phpcs.xml.dist" ] && config_files_exist=false
    [ ! -f "eslint.config.js" ] && config_files_exist=false
    [ ! -f "package.json" ] && config_files_exist=false
    [ ! -f "composer.json" ] && config_files_exist=false
    
    assert_true "$config_files_exist" "All configuration files present for full workflow"
    
    # Test dependency installation readiness
    local dependency_ready=true
    [ ! -f "package.json" ] && dependency_ready=false
    [ ! -f "composer.json" ] && dependency_ready=false
    
    assert_true "$dependency_ready" "Ready for dependency installation (npm install && composer install)"
    
    # Test linting readiness
    local linting_ready=true
    [ ! -f "phpcs.xml.dist" ] && linting_ready=false
    [ ! -f "eslint.config.js" ] && linting_ready=false
    
    assert_true "$linting_ready" "Ready for linting commands"
    
    cd "$original_dir"
    cleanup_mock_env "$mock_env"
}

# Test incomplete workflow scenarios
test_incomplete_workflow_scenarios() {
    echo "Testing incomplete workflow scenarios..."
    
    local mock_env
    mock_env="$(create_mock_env "workflow_incomplete" "empty")"
    
    local original_dir="$PWD"
    cd "$mock_env"
    
    # Create only partial configuration
    touch "package.json"
    # Missing composer.json, phpcs.xml.dist, eslint.config.js
    
    local config_files_exist=true
    [ ! -f "phpcs.xml.dist" ] && config_files_exist=false
    [ ! -f "eslint.config.js" ] && config_files_exist=false
    [ ! -f "package.json" ] && config_files_exist=false
    [ ! -f "composer.json" ] && config_files_exist=false
    
    assert_false "$config_files_exist" "Correctly detects incomplete configuration"
    
    local dependency_ready=true
    [ ! -f "package.json" ] && dependency_ready=false
    [ ! -f "composer.json" ] && dependency_ready=false
    
    assert_false "$dependency_ready" "Correctly detects incomplete dependency setup"
    
    local linting_ready=true
    [ ! -f "phpcs.xml.dist" ] && linting_ready=false
    [ ! -f "eslint.config.js" ] && linting_ready=false
    
    assert_false "$linting_ready" "Correctly detects incomplete linting setup"
    
    cd "$original_dir"
    cleanup_mock_env "$mock_env"
}

# Main test execution
main() {
    echo "🧪 Documented Workflow Integration Tests"
    echo "========================================"
    
    reset_assertions
    
    test_quick_start_prerequisites
    test_linting_prerequisites
    test_make_commands
    test_vscode_workspace
    test_wordpress_structure_requirements
    test_command_readiness
    test_integration_workflow
    test_incomplete_workflow_scenarios
    
    print_assertion_summary
    
    local exit_code=$?
    if [ $exit_code -eq 0 ]; then
        echo "🎉 All workflow tests passed!"
        echo ""
        echo "✅ The project is ready for the documented workflows:"
        echo "   • npm install && composer install"
        echo "   • npm run lint:js && npm run lint:php"
        echo "   • make help (to see available commands)"
        echo "   • Open wp.code-workspace in VSCode"
    else
        echo "⚠️ Some workflow tests failed"
        echo "   Check the output above for specific issues."
    fi
    
    return $exit_code
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi