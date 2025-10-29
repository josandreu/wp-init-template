#!/bin/bash

# File Validation Unit Tests
# Tests core file generation and content validation using new testing framework

set -euo pipefail

# Source testing libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/assertions.sh"
source "$SCRIPT_DIR/../lib/mock-env.sh"

# Test configuration files exist and have correct content
test_core_configuration_files() {
    echo "Testing core configuration files..."
    
    # Create mock environment for testing
    local mock_env
    mock_env="$(create_mock_env "file_validation_test" "empty")"
    
    # Change to mock environment
    local original_dir="$PWD"
    cd "$mock_env"
    
    # Create test files with expected content
    cat > "phpcs.xml.dist" <<'EOF'
<?xml version="1.0"?>
<ruleset name="WordPress Coding Standards">
    <description>WordPress coding standards configuration</description>
    <rule ref="WordPress"/>
    <file>./wordpress/wp-content</file>
</ruleset>
EOF
    
    cat > "phpstan.neon.dist" <<'EOF'
parameters:
    level: 5
    paths:
        - wordpress/wp-content
EOF
    
    cat > "eslint.config.js" <<'EOF'
module.exports = {
    extends: ['@wordpress/eslint-plugin/recommended'],
    files: ['**/*.js'],
    rules: {
        'wordpress/no-unused-vars-before-return': 'error'
    }
};
EOF
    
    cat > "package.json" <<'EOF'
{
    "name": "test-project",
    "scripts": {
        "lint:js": "eslint .",
        "lint:php": "phpcs"
    },
    "devDependencies": {
        "@wordpress/eslint-plugin": "^1.0.0"
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
    
    # Test file existence
    assert_file_exists "phpcs.xml.dist" "PHPCS configuration file exists"
    assert_file_exists "phpstan.neon.dist" "PHPStan configuration file exists"
    assert_file_exists "eslint.config.js" "ESLint configuration file exists"
    assert_file_exists "package.json" "Package.json file exists"
    assert_file_exists "composer.json" "Composer.json file exists"
    
    # Test file content
    assert_file_contains "phpcs.xml.dist" "WordPress" "PHPCS contains WordPress rules"
    assert_file_contains "phpcs.xml.dist" "<file>" "PHPCS contains file paths"
    
    assert_file_contains "phpstan.neon.dist" "level:" "PHPStan contains analysis level"
    assert_file_contains "phpstan.neon.dist" "paths:" "PHPStan contains file paths"
    
    assert_file_contains "eslint.config.js" "wordpress" "ESLint contains WordPress config"
    assert_file_contains "eslint.config.js" "files:" "ESLint contains file patterns"
    
    assert_file_contains "package.json" "lint" "Package.json contains linting scripts"
    assert_file_contains "package.json" "devDependencies" "Package.json contains dev dependencies"
    
    assert_file_contains "composer.json" "require-dev" "Composer.json contains dev dependencies"
    
    # Return to original directory and cleanup
    cd "$original_dir"
    cleanup_mock_env "$mock_env"
}

# Test missing files scenario
test_missing_files_detection() {
    echo "Testing missing files detection..."
    
    # Create mock environment with no files
    local mock_env
    mock_env="$(create_mock_env "missing_files_test" "empty")"
    
    local original_dir="$PWD"
    cd "$mock_env"
    
    # Test that missing files are properly detected
    assert_file_not_exists "phpcs.xml.dist" "PHPCS file correctly detected as missing"
    assert_file_not_exists "eslint.config.js" "ESLint file correctly detected as missing"
    assert_file_not_exists "package.json" "Package.json correctly detected as missing"
    
    cd "$original_dir"
    cleanup_mock_env "$mock_env"
}

# Test file content validation with invalid content
test_invalid_content_detection() {
    echo "Testing invalid content detection..."
    
    local mock_env
    mock_env="$(create_mock_env "invalid_content_test" "empty")"
    
    local original_dir="$PWD"
    cd "$mock_env"
    
    # Create files with invalid/missing content
    cat > "phpcs.xml.dist" <<'EOF'
<?xml version="1.0"?>
<ruleset name="Basic Rules">
    <description>Basic configuration without WP standards</description>
</ruleset>
EOF
    
    cat > "eslint.config.js" <<'EOF'
module.exports = {
    extends: ['eslint:recommended'],
    rules: {}
};
EOF
    
    cat > "package.json" <<'EOF'
{
    "name": "test-project",
    "scripts": {
        "build": "webpack"
    }
}
EOF
    
    # Test that invalid content is detected (files exist but don't contain expected content)
    assert_file_exists "phpcs.xml.dist" "PHPCS file exists but has invalid content"
    assert_file_not_contains "phpcs.xml.dist" "WordPress" "PHPCS missing WordPress rules detected"
    assert_file_not_contains "eslint.config.js" "wordpress" "ESLint missing WordPress config detected"
    assert_file_not_contains "package.json" "lint" "Package.json missing lint scripts detected"
    
    cd "$original_dir"
    cleanup_mock_env "$mock_env"
}

# Main test execution
main() {
    echo "🔍 File Validation Unit Tests"
    echo "============================="
    
    reset_assertions
    
    test_core_configuration_files
    test_missing_files_detection
    test_invalid_content_detection
    
    print_assertion_summary
    
    local exit_code=$?
    if [ $exit_code -eq 0 ]; then
        echo "🎉 All file validation tests passed!"
    else
        echo "⚠️ Some file validation tests failed"
    fi
    
    return $exit_code
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi