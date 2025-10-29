#!/bin/bash

# Simple Workflow Integration Tests
# Tests basic workflow prerequisites and readiness using new testing framework

set -euo pipefail

# Source testing libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/assertions.sh"
source "$SCRIPT_DIR/../lib/mock-env.sh"

# Test configuration files existence
test_configuration_files_exist() {
    echo "Testing configuration files existence..."
    
    local mock_env
    mock_env="$(create_mock_env "workflow_config_test" "empty")"
    
    local original_dir="$PWD"
    cd "$mock_env"
    
    # Create expected configuration files
    touch "phpcs.xml.dist"
    touch "eslint.config.js"
    touch "package.json"
    touch "composer.json"
    
    # Test file existence
    assert_file_exists "phpcs.xml.dist" "PHPCS configuration file exists"
    assert_file_exists "eslint.config.js" "ESLint configuration file exists"
    assert_file_exists "package.json" "Package.json file exists"
    assert_file_exists "composer.json" "Composer.json file exists"
    
    cd "$original_dir"
    cleanup_mock_env "$mock_env"
}

# Test Makefile structure and targets
test_makefile_structure() {
    echo "Testing Makefile structure..."
    
    local mock_env
    mock_env="$(create_mock_env "workflow_makefile_test" "empty")"
    
    local original_dir="$PWD"
    cd "$mock_env"
    
    # Create Makefile with expected targets
    cat > "Makefile" <<'EOF'
.PHONY: help install lint

help: ## Show this help
	@echo "Available targets:"
	@echo "  install  Install dependencies"
	@echo "  lint     Run linting"

install: ## Install dependencies
	npm install && composer install

lint: ## Run linting
	npm run lint:js && npm run lint:php
EOF
    
    assert_file_exists "Makefile" "Makefile exists"
    assert_file_contains "Makefile" "help:" "Makefile contains help target"
    assert_file_contains "Makefile" ".PHONY:" "Makefile contains PHONY declarations"
    
    cd "$original_dir"
    cleanup_mock_env "$mock_env"
}

# Test WordPress structure detection
test_wordpress_structure() {
    echo "Testing WordPress structure detection..."
    
    # Test wordpress/wp-content structure
    local mock_env1
    mock_env1="$(create_mock_env "workflow_wp_structure1" "wordpress")"
    
    local original_dir="$PWD"
    cd "$mock_env1"
    
    assert_directory_exists "wordpress/wp-content" "WordPress structure (wordpress/wp-content) exists"
    
    cd "$original_dir"
    cleanup_mock_env "$mock_env1"
    
    # Test wp-content only structure
    local mock_env2
    mock_env2="$(create_mock_env "workflow_wp_structure2" "wp-content-only")"
    
    cd "$mock_env2"
    
    assert_directory_exists "wp-content" "WordPress structure (wp-content) exists"
    
    cd "$original_dir"
    cleanup_mock_env "$mock_env2"
}

# Test command availability with mocking
test_command_availability() {
    echo "Testing command availability..."
    
    local mock_env
    mock_env="$(create_mock_env "workflow_commands_test" "empty")"
    
    local original_dir="$PWD"
    cd "$mock_env"
    
    # Mock npm as available
    mock_tool "npm" "success"
    assert_command_success "command -v npm" "npm command is available"
    assert_command_output_contains "npm --version" "mock version" "npm version command works"
    
    # Mock composer as available
    mock_tool "composer" "success"
    assert_command_success "command -v composer" "composer command is available"
    assert_command_output_contains "composer --version" "mock version" "composer version command works"
    
    # Test missing tool scenario
    mock_tool "jq" "not_found"
    assert_command_fails "command -v jq" "jq correctly detected as not available"
    
    cd "$original_dir"
    cleanup_mock_env "$mock_env"
}

# Test workflow readiness
test_workflow_readiness() {
    echo "Testing workflow readiness..."
    
    local mock_env
    mock_env="$(create_mock_env "workflow_readiness_test" "empty")"
    
    local original_dir="$PWD"
    cd "$mock_env"
    
    # Create configuration files for dependency installation
    cat > "package.json" <<'EOF'
{
    "name": "test-project",
    "scripts": {
        "lint:js": "eslint .",
        "lint:php": "phpcs"
    }
}
EOF
    
    cat > "composer.json" <<'EOF'
{
    "name": "test/project",
    "require-dev": {
        "wp-coding-standards/wpcs": "^2.0"
    }
}
EOF
    
    cat > "phpcs.xml.dist" <<'EOF'
<?xml version="1.0"?>
<ruleset name="WordPress">
    <rule ref="WordPress"/>
</ruleset>
EOF
    
    cat > "eslint.config.js" <<'EOF'
module.exports = {
    extends: ['@wordpress/eslint-plugin/recommended']
};
EOF
    
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
test_incomplete_workflow() {
    echo "Testing incomplete workflow scenarios..."
    
    local mock_env
    mock_env="$(create_mock_env "workflow_incomplete_test" "empty")"
    
    local original_dir="$PWD"
    cd "$mock_env"
    
    # Create only some files using echo instead of touch
    echo '{"name": "test"}' > "package.json"
    # Missing composer.json
    
    local dependency_ready=true
    [ ! -f "package.json" ] && dependency_ready=false
    [ ! -f "composer.json" ] && dependency_ready=false
    
    assert_false "$dependency_ready" "Correctly detects incomplete dependency setup"
    
    # Create only linting config for PHP
    echo '<?xml version="1.0"?><ruleset></ruleset>' > "phpcs.xml.dist"
    # Missing eslint.config.js
    
    local linting_ready=true
    [ ! -f "phpcs.xml.dist" ] && linting_ready=false
    [ ! -f "eslint.config.js" ] && linting_ready=false
    
    assert_false "$linting_ready" "Correctly detects incomplete linting setup"
    
    cd "$original_dir"
    cleanup_mock_env "$mock_env"
}

# Main test execution
main() {
    echo "🧪 Simple Workflow Integration Tests"
    echo "===================================="
    
    reset_assertions
    
    test_configuration_files_exist
    test_makefile_structure
    test_wordpress_structure
    test_command_availability
    test_workflow_readiness
    test_incomplete_workflow
    
    print_assertion_summary
    
    local exit_code=$?
    if [ $exit_code -eq 0 ]; then
        echo "🎉 All workflow tests passed!"
    else
        echo "⚠️ Some workflow tests failed"
    fi
    
    return $exit_code
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi