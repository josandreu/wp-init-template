#!/bin/bash

# Mock Environment System for Isolated Testing
# Creates isolated test environments with WordPress structures and tool mocking

set -euo pipefail

# Configuration
readonly MOCK_BASE_DIR="${TEST_MOCK_DIR:-/tmp/wp-init-test-mocks}"
readonly MOCK_CLEANUP_ON_EXIT="${MOCK_CLEANUP_ON_EXIT:-true}"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly FIXTURES_DIR="$(dirname "$SCRIPT_DIR")/fixtures"

# Global state
declare -a CREATED_MOCK_ENVS=()
declare -a MOCKED_TOOLS=()

# Colors for output
readonly MOCK_GREEN='\033[0;32m'
readonly MOCK_YELLOW='\033[1;33m'
readonly MOCK_RED='\033[0;31m'
readonly MOCK_BLUE='\033[0;34m'
readonly MOCK_NC='\033[0m' # No Color

# Cleanup function for exit
cleanup_all_mocks() {
    if [ "$MOCK_CLEANUP_ON_EXIT" = "true" ] && [ ${#CREATED_MOCK_ENVS[@]} -gt 0 ]; then
        for env_path in "${CREATED_MOCK_ENVS[@]}"; do
            cleanup_mock_env "$env_path" 2>/dev/null || true
        done
        
        for tool_info in "${MOCKED_TOOLS[@]}"; do
            local tool_name="${tool_info%%:*}"
            restore_tool "$tool_name" 2>/dev/null || true
        done
    fi
}

# Set up cleanup trap
trap cleanup_all_mocks EXIT

# Print colored output
print_mock_message() {
    local color="$1"
    local message="$2"
    printf "${color}[MOCK]${MOCK_NC} %s\n" "$message" >&2
}

# Create isolated mock environment
create_mock_env() {
    local test_name="$1"
    local config="${2:-default}"
    
    # Generate unique environment path
    local env_id
    env_id="$(date +%s%3N)_$$_$(echo "$test_name" | tr '[:upper:]' '[:lower:]' | tr -c '[:alnum:]' '_')"
    local env_path="$MOCK_BASE_DIR/$env_id"
    
    print_mock_message "$MOCK_BLUE" "Creating mock environment: $test_name"
    
    # Create base directory structure
    mkdir -p "$env_path"
    
    # Create mock environment based on config
    case "$config" in
        "wordpress"|"default")
            create_wordpress_structure "$env_path"
            ;;
        "empty")
            # Just create the base directory
            ;;
        "wp-content-only")
            create_wp_content_structure "$env_path"
            ;;
        *)
            print_mock_message "$MOCK_YELLOW" "Unknown config '$config', using default"
            create_wordpress_structure "$env_path"
            ;;
    esac
    
    # Track created environment
    CREATED_MOCK_ENVS+=("$env_path")
    
    print_mock_message "$MOCK_GREEN" "Mock environment created: $env_path"
    echo "$env_path"
}

# Create WordPress directory structure
create_wordpress_structure() {
    local base_path="$1"
    
    print_mock_message "$MOCK_BLUE" "Creating WordPress structure in $base_path"
    
    # Create WordPress core structure
    mkdir -p "$base_path/wordpress"
    mkdir -p "$base_path/wordpress/wp-content"
    mkdir -p "$base_path/wordpress/wp-content/themes"
    mkdir -p "$base_path/wordpress/wp-content/plugins"
    mkdir -p "$base_path/wordpress/wp-content/mu-plugins"
    mkdir -p "$base_path/wordpress/wp-content/uploads"
    
    # Create essential WordPress files
    cat > "$base_path/wordpress/wp-config.php" <<'EOF'
<?php
// Mock WordPress configuration file for testing
define('DB_NAME', 'test_database');
define('DB_USER', 'test_user');
define('DB_PASSWORD', 'test_password');
define('DB_HOST', 'localhost');
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');

$table_prefix = 'wp_';

define('WP_DEBUG', true);
define('WP_DEBUG_LOG', true);
define('WP_DEBUG_DISPLAY', false);

if (!defined('ABSPATH')) {
    define('ABSPATH', __DIR__ . '/');
}

require_once ABSPATH . 'wp-settings.php';
EOF
    
    cat > "$base_path/wordpress/index.php" <<'EOF'
<?php
// Mock WordPress index file
define('WP_USE_THEMES', true);
require __DIR__ . '/wp-blog-header.php';
EOF
    
    # Create .htaccess
    cat > "$base_path/wordpress/.htaccess" <<'EOF'
# BEGIN WordPress
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]
</IfModule>
# END WordPress
EOF
    
    # Create sample theme
    create_sample_theme "$base_path/wordpress/wp-content/themes"
    
    # Create sample plugin
    create_sample_plugin "$base_path/wordpress/wp-content/plugins"
    
    # Create sample mu-plugin
    create_sample_mu_plugin "$base_path/wordpress/wp-content/mu-plugins"
}

# Create wp-content only structure
create_wp_content_structure() {
    local base_path="$1"
    
    print_mock_message "$MOCK_BLUE" "Creating wp-content structure in $base_path"
    
    mkdir -p "$base_path/wp-content"
    mkdir -p "$base_path/wp-content/themes"
    mkdir -p "$base_path/wp-content/plugins"
    mkdir -p "$base_path/wp-content/mu-plugins"
    mkdir -p "$base_path/wp-content/uploads"
    
    create_sample_theme "$base_path/wp-content/themes"
    create_sample_plugin "$base_path/wp-content/plugins"
    create_sample_mu_plugin "$base_path/wp-content/mu-plugins"
}

# Create sample theme
create_sample_theme() {
    local themes_dir="$1"
    local theme_name="test-theme"
    
    mkdir -p "$themes_dir/$theme_name"
    
    cat > "$themes_dir/$theme_name/style.css" <<EOF
/*
Theme Name: Test Theme
Description: A test theme for mock environment
Version: 1.0.0
Author: Test Author
*/

body {
    font-family: Arial, sans-serif;
    margin: 0;
    padding: 20px;
}
EOF
    
    cat > "$themes_dir/$theme_name/index.php" <<'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Test Theme</title>
    <link rel="stylesheet" href="<?php echo get_stylesheet_uri(); ?>">
</head>
<body>
    <h1>Test Theme</h1>
    <p>This is a mock theme for testing purposes.</p>
</body>
</html>
EOF
    
    cat > "$themes_dir/$theme_name/functions.php" <<'EOF'
<?php
// Test theme functions
function test_theme_setup() {
    add_theme_support('post-thumbnails');
    add_theme_support('custom-logo');
}
add_action('after_setup_theme', 'test_theme_setup');
EOF
}

# Create sample plugin
create_sample_plugin() {
    local plugins_dir="$1"
    local plugin_name="test-plugin"
    
    mkdir -p "$plugins_dir/$plugin_name"
    
    cat > "$plugins_dir/$plugin_name/test-plugin.php" <<'EOF'
<?php
/*
Plugin Name: Test Plugin
Description: A test plugin for mock environment
Version: 1.0.0
Author: Test Author
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
        // Plugin initialization code
    }
}

new TestPlugin();
EOF
}

# Create sample mu-plugin
create_sample_mu_plugin() {
    local mu_plugins_dir="$1"
    
    cat > "$mu_plugins_dir/test-mu-plugin.php" <<'EOF'
<?php
/*
Plugin Name: Test MU Plugin
Description: A test must-use plugin for mock environment
Version: 1.0.0
Author: Test Author
*/

// Prevent direct access
if (!defined('ABSPATH')) {
    exit;
}

// MU Plugin functionality
add_action('init', function() {
    // MU plugin initialization
});
EOF
}

# Mock external tools
mock_tool() {
    local tool_name="$1"
    local behavior="${2:-success}"
    local custom_output="${3:-}"
    
    print_mock_message "$MOCK_BLUE" "Mocking tool: $tool_name (behavior: $behavior)"
    
    # Create mock tools directory
    local mock_tools_dir="$MOCK_BASE_DIR/mock-tools"
    mkdir -p "$mock_tools_dir"
    
    # Backup original PATH if not already done
    if [ -z "${ORIGINAL_PATH:-}" ]; then
        export ORIGINAL_PATH="$PATH"
    fi
    
    # Create mock tool script
    local mock_script="$mock_tools_dir/$tool_name"
    
    case "$behavior" in
        "success")
            create_successful_mock "$mock_script" "$tool_name" "$custom_output"
            ;;
        "failure")
            create_failing_mock "$mock_script" "$tool_name" "$custom_output"
            ;;
        "not_found")
            # Don't create the script, just remove from PATH
            remove_tool_from_path "$tool_name"
            return 0
            ;;
        "custom")
            if [ -n "$custom_output" ]; then
                create_custom_mock "$mock_script" "$tool_name" "$custom_output"
            else
                print_mock_message "$MOCK_RED" "Custom behavior requires custom_output parameter"
                return 1
            fi
            ;;
        *)
            print_mock_message "$MOCK_RED" "Unknown behavior: $behavior"
            return 1
            ;;
    esac
    
    # Make script executable
    chmod +x "$mock_script"
    
    # Add mock tools directory to beginning of PATH
    export PATH="$mock_tools_dir:$PATH"
    
    # Track mocked tool
    MOCKED_TOOLS+=("$tool_name:$behavior:$mock_script")
    
    print_mock_message "$MOCK_GREEN" "Tool mocked: $tool_name"
}

# Create successful mock tool
create_successful_mock() {
    local script_path="$1"
    local tool_name="$2"
    local custom_output="$3"
    
    cat > "$script_path" <<EOF
#!/bin/bash
# Mock $tool_name - Success behavior

case "\$1" in
    "--version"|"-v")
        echo "$tool_name mock version 1.0.0"
        ;;
    "--help"|"-h")
        echo "Mock $tool_name help"
        echo "This is a mocked version of $tool_name for testing"
        ;;
    *)
        if [ -n "$custom_output" ]; then
            echo "$custom_output"
        else
            echo "Mock $tool_name executed successfully"
        fi
        ;;
esac

exit 0
EOF
}

# Create failing mock tool
create_failing_mock() {
    local script_path="$1"
    local tool_name="$2"
    local custom_output="$3"
    
    cat > "$script_path" <<EOF
#!/bin/bash
# Mock $tool_name - Failure behavior

if [ -n "$custom_output" ]; then
    echo "$custom_output" >&2
else
    echo "Mock $tool_name failed" >&2
fi

exit 1
EOF
}

# Create custom mock tool
create_custom_mock() {
    local script_path="$1"
    local tool_name="$2"
    local custom_script="$3"
    
    cat > "$script_path" <<EOF
#!/bin/bash
# Mock $tool_name - Custom behavior

$custom_script
EOF
}

# Remove tool from PATH
remove_tool_from_path() {
    local tool_name="$1"
    
    # Find tool in PATH and create a temporary PATH without it
    local new_path=""
    local IFS=":"
    
    for dir in $PATH; do
        if [ -x "$dir/$tool_name" ]; then
            print_mock_message "$MOCK_YELLOW" "Removing $tool_name from $dir"
            continue
        fi
        
        if [ -n "$new_path" ]; then
            new_path="$new_path:$dir"
        else
            new_path="$dir"
        fi
    done
    
    export PATH="$new_path"
    MOCKED_TOOLS+=("$tool_name:not_found:")
}

# Restore original tool
restore_tool() {
    local tool_name="$1"
    
    print_mock_message "$MOCK_BLUE" "Restoring tool: $tool_name"
    
    # Remove from mocked tools list
    local new_mocked_tools=()
    for tool_info in "${MOCKED_TOOLS[@]}"; do
        local name="${tool_info%%:*}"
        if [ "$name" != "$tool_name" ]; then
            new_mocked_tools+=("$tool_info")
        else
            local script_path="${tool_info##*:}"
            if [ -f "$script_path" ]; then
                rm -f "$script_path"
            fi
        fi
    done
    MOCKED_TOOLS=("${new_mocked_tools[@]}")
    
    # Restore original PATH if all tools are restored
    if [ ${#MOCKED_TOOLS[@]} -eq 0 ] && [ -n "${ORIGINAL_PATH:-}" ]; then
        export PATH="$ORIGINAL_PATH"
        unset ORIGINAL_PATH
    fi
    
    print_mock_message "$MOCK_GREEN" "Tool restored: $tool_name"
}

# Clean up mock environment
cleanup_mock_env() {
    local env_path="$1"
    
    if [ ! -d "$env_path" ]; then
        print_mock_message "$MOCK_YELLOW" "Environment does not exist: $env_path"
        return 0
    fi
    
    print_mock_message "$MOCK_BLUE" "Cleaning up mock environment: $env_path"
    
    # Remove from tracking
    if [ ${#CREATED_MOCK_ENVS[@]} -gt 0 ]; then
        local new_envs=()
        for env in "${CREATED_MOCK_ENVS[@]}"; do
            if [ "$env" != "$env_path" ]; then
                new_envs+=("$env")
            fi
        done
        CREATED_MOCK_ENVS=("${new_envs[@]}")
    fi
    
    # Remove directory
    rm -rf "$env_path"
    
    print_mock_message "$MOCK_GREEN" "Environment cleaned up: $env_path"
}

# Get mock environment info
get_mock_env_info() {
    local env_path="$1"
    
    if [ ! -d "$env_path" ]; then
        echo "Environment does not exist: $env_path"
        return 1
    fi
    
    echo "Mock Environment: $env_path"
    echo "Created: $(stat -c %y "$env_path" 2>/dev/null || stat -f %Sm "$env_path" 2>/dev/null || echo "Unknown")"
    echo "Size: $(du -sh "$env_path" 2>/dev/null | cut -f1 || echo "Unknown")"
    echo ""
    echo "Structure:"
    find "$env_path" -type d | head -20 | sed 's/^/  /'
    
    local file_count
    file_count=$(find "$env_path" -type f | wc -l)
    echo ""
    echo "Files: $file_count"
}

# List all active mock environments
list_mock_envs() {
    echo "Active Mock Environments:"
    if [ ${#CREATED_MOCK_ENVS[@]} -eq 0 ]; then
        echo "  None"
    else
        for env_path in "${CREATED_MOCK_ENVS[@]}"; do
            echo "  - $env_path"
        done
    fi
    
    echo ""
    echo "Mocked Tools:"
    if [ ${#MOCKED_TOOLS[@]} -eq 0 ]; then
        echo "  None"
    else
        for tool_info in "${MOCKED_TOOLS[@]}"; do
            local tool_name="${tool_info%%:*}"
            local behavior
            behavior="$(echo "$tool_info" | cut -d: -f2)"
            echo "  - $tool_name ($behavior)"
        done
    fi
}

# Utility functions for common WordPress scenarios
create_plugin_mock_env() {
    local test_name="$1"
    local plugin_name="${2:-test-plugin}"
    
    local env_path
    env_path="$(create_mock_env "$test_name" "wordpress")"
    
    # Add specific plugin structure
    mkdir -p "$env_path/wordpress/wp-content/plugins/$plugin_name"
    
    echo "$env_path"
}

create_theme_mock_env() {
    local test_name="$1"
    local theme_name="${2:-test-theme}"
    
    local env_path
    env_path="$(create_mock_env "$test_name" "wordpress")"
    
    # Add specific theme structure
    mkdir -p "$env_path/wordpress/wp-content/themes/$theme_name"
    
    echo "$env_path"
}

# Export functions for use in tests
export -f create_mock_env
export -f cleanup_mock_env
export -f mock_tool
export -f restore_tool
export -f get_mock_env_info
export -f list_mock_envs
export -f create_plugin_mock_env
export -f create_theme_mock_env