#!/bin/bash

# ====================================================================
# WordPress Standards Configuration & Formatting Script
# ====================================================================
# Detecta, configura y formatea código WordPress automáticamente
# ====================================================================

set -e
set -o pipefail

# Colores
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; MAGENTA='\033[0;35m'; NC='\033[0m'

# Get the directory where this script is located (for finding template files)
INIT_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Print functions are now defined in the Error Handling module below

validate_slug() {
    [ -z "$1" ] && { print_error "Slug vacío"; return 1; }
    [[ ! "$1" =~ ^[a-z0-9-]+$ ]] && { print_error "Slug inválido"; return 1; }
    return 0
}

generate_namespace() {
    echo "$1" | awk -F'-' '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1' OFS=''
}

generate_constant() {
    echo "$1" | tr '[:lower:]' '[:upper:]' | tr '-' '_'
}

# ====================================================================
# External WordPress Path Handling Module
# ====================================================================

# Global variables for external WordPress path handling
WORDPRESS_PATH=""
PROJECT_ROOT=""
WORDPRESS_RELATIVE_PATH=""
NON_INTERACTIVE=false

# Function to validate WordPress structure at specified path
validate_wordpress_structure() {
    local wp_path="$1"
    local show_details="${2:-false}"
    
    # Use the enhanced validation function
    validate_wordpress_structure_enhanced "$wp_path" "$show_details"
}

# Function to handle WordPress path and calculate project root
handle_wordpress_path() {
    local wordpress_path="$1"
    local project_root
    
    print_info "Procesando ruta de WordPress: $wordpress_path"
    
    # Convert relative path to absolute path
    if [[ "$wordpress_path" != /* ]]; then
        local original_path="$wordpress_path"
        wordpress_path="$(cd "$(dirname "$wordpress_path")" && pwd)/$(basename "$wordpress_path")"
        print_info "Ruta relativa convertida: $original_path → $wordpress_path"
    fi
    
    # Validate WordPress structure with enhanced validation
    if ! validate_wordpress_structure_enhanced "$wordpress_path"; then
        return 1
    fi
    
    # Calculate project root as parent directory of WordPress path
    project_root=$(dirname "$wordpress_path")
    
    # Verify project root is writable
    if [ ! -w "$project_root" ]; then
        print_error "El directorio raíz del proyecto no tiene permisos de escritura: $project_root"
        echo ""
        echo "💡 Soluciones:"
        echo "  • Cambiar permisos: chmod 755 '$project_root'"
        echo "  • Ejecutar con sudo (no recomendado)"
        echo "  • Verificar que eres el propietario del directorio"
        echo ""
        return 1
    fi
    
    # Set global variables
    WORDPRESS_PATH="$wordpress_path"
    PROJECT_ROOT="$project_root"
    WORDPRESS_RELATIVE_PATH=$(basename "$wordpress_path")
    
    # Set WP_CONTENT_DIR to relative path from project root
    WP_CONTENT_DIR="$WORDPRESS_RELATIVE_PATH/wp-content"
    
    # Show structure summary
    show_structure_summary "$wordpress_path" "$project_root" "$WORDPRESS_RELATIVE_PATH"
    
    # Confirm configuration with user
    if ! confirm_project_configuration "$wordpress_path" "$project_root" "$WORDPRESS_RELATIVE_PATH"; then
        return 1
    fi
    
    print_success "Configuración de WordPress completada exitosamente"
    [ -n "$LOG_FILE" ] && log_success "WordPress path configured: $wordpress_path -> $project_root" "PATH_HANDLING"
    
    return 0
}

# Function to parse CLI arguments
parse_cli_arguments() {
    local wordpress_path=""
    local mode=""
    
    # Parse all arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help|-h)
                show_cli_help
                exit 0
                ;;
            --version|-v)
                show_version
                exit 0
                ;;
            --*)
                print_error "Opción desconocida: $1"
                echo ""
                echo "Usa --help para ver las opciones disponibles"
                exit 1
                ;;
            *)
                if [ -z "$wordpress_path" ]; then
                    wordpress_path="$1"
                elif [ -z "$mode" ]; then
                    mode="$1"
                else
                    print_error "Demasiados argumentos: $1"
                    echo ""
                    echo "Uso: $0 [WORDPRESS_PATH] [MODE]"
                    echo "Usa --help para más información"
                    exit 1
                fi
                ;;
        esac
        shift
    done
    
    if [ -n "$wordpress_path" ]; then
        # Handle WordPress path
        if ! handle_wordpress_path "$wordpress_path"; then
            print_error "Error al configurar la ruta de WordPress: $wordpress_path"
            echo ""
            echo "💡 Usa --help para ver ejemplos de uso"
            exit 1
        fi
        
        # Set mode if provided
        if [ -n "$mode" ]; then
            if [[ "$mode" =~ ^[1-4]$ ]]; then
                MODE="$mode"
            else
                print_error "Modo inválido: $mode. Debe ser 1, 2, 3, o 4"
                echo ""
                echo "Modos disponibles:"
                echo "  1 - Configurar y formatear proyecto"
                echo "  2 - Solo configurar (sin formatear)"
                echo "  3 - Solo formatear código existente"
                echo "  4 - Fusionar configuración (requiere jq)"
                echo ""
                exit 1
            fi
        fi
        
        # Mark as non-interactive
        NON_INTERACTIVE=true
        return 0
    fi
    
    return 0
}

# Function to detect execution context (legacy vs new mode)
detect_execution_context() {
    # Check if we're executing from a WordPress project root (legacy mode)
    if [ -d "./wp-content" ] || [ -d "./wordpress/wp-content" ]; then
        print_info "Legacy mode detected (executing from WordPress project root)"
        return 0
    else
        print_info "New mode detected (external execution)"
        return 1
    fi
}

# Function to show detected structure summary
show_structure_summary() {
    local wordpress_path="$1"
    local project_root="$2"
    local relative_path="$3"
    
    echo ""
    echo "══════════════════════════════════════════════════════════════"
    echo "  📋 Resumen de Estructura Detectada"
    echo "══════════════════════════════════════════════════════════════"
    echo ""
    
    print_success "Estructura WordPress válida detectada"
    echo ""
    
    echo "📁 Rutas del proyecto:"
    echo "  • Raíz del proyecto: ${BLUE}$project_root${NC}"
    echo "  • Directorio WordPress: ${BLUE}$wordpress_path${NC}"
    echo "  • Ruta relativa: ${BLUE}$relative_path${NC}"
    echo ""
    
    echo "📂 Estructura WordPress encontrada:"
    echo "  • wp-content: ${GREEN}✓${NC} $wordpress_path/wp-content"
    
    if [ -d "$wordpress_path/wp-content/plugins" ]; then
        local plugin_count=$(find "$wordpress_path/wp-content/plugins" -maxdepth 1 -type d | wc -l)
        plugin_count=$((plugin_count - 1)) # Subtract the plugins directory itself
        echo "  • plugins: ${GREEN}✓${NC} ($plugin_count directorios)"
    else
        echo "  • plugins: ${RED}✗${NC} (no encontrado)"
    fi
    
    if [ -d "$wordpress_path/wp-content/themes" ]; then
        local theme_count=$(find "$wordpress_path/wp-content/themes" -maxdepth 1 -type d | wc -l)
        theme_count=$((theme_count - 1)) # Subtract the themes directory itself
        echo "  • themes: ${GREEN}✓${NC} ($theme_count directorios)"
    else
        echo "  • themes: ${RED}✗${NC} (no encontrado)"
    fi
    
    if [ -d "$wordpress_path/wp-content/mu-plugins" ]; then
        local mu_count=$(find "$wordpress_path/wp-content/mu-plugins" -maxdepth 1 -type d | wc -l)
        mu_count=$((mu_count - 1)) # Subtract the mu-plugins directory itself
        echo "  • mu-plugins: ${GREEN}✓${NC} ($mu_count directorios)"
    else
        echo "  • mu-plugins: ${YELLOW}⚠${NC} (será creado automáticamente)"
    fi
    
    echo ""
    
    # Check for existing project files
    echo "📄 Archivos del proyecto existentes:"
    local existing_files=()
    [ -f "$project_root/composer.json" ] && existing_files+=("composer.json")
    [ -f "$project_root/package.json" ] && existing_files+=("package.json")
    [ -f "$project_root/Jenkinsfile" ] && existing_files+=("Jenkinsfile")
    [ -d "$project_root/docker" ] && existing_files+=("docker/")
    [ -f "$project_root/docker-compose.yml" ] && existing_files+=("docker-compose.yml")
    [ -f "$project_root/.gitignore" ] && existing_files+=(".gitignore")
    [ -f "$project_root/README.md" ] && existing_files+=("README.md")
    
    if [ ${#existing_files[@]} -gt 0 ]; then
        for file in "${existing_files[@]}"; do
            echo "  • ${GREEN}✓${NC} $file (será preservado)"
        done
    else
        echo "  • ${YELLOW}ℹ${NC} No se encontraron archivos de proyecto existentes"
    fi
    
    echo ""
    
    # Check write permissions
    echo "🔐 Permisos de escritura:"
    if [ -w "$project_root" ]; then
        echo "  • Raíz del proyecto: ${GREEN}✓${NC} Escribible"
    else
        echo "  • Raíz del proyecto: ${RED}✗${NC} Sin permisos de escritura"
        print_error "Sin permisos de escritura en: $project_root"
        return 1
    fi
    
    if [ -w "$wordpress_path" ]; then
        echo "  • Directorio WordPress: ${GREEN}✓${NC} Escribible"
    else
        echo "  • Directorio WordPress: ${YELLOW}⚠${NC} Solo lectura (puede limitar algunas operaciones)"
    fi
    
    echo ""
    
    # Show what will be created/modified
    echo "📝 Archivos que se crearán/modificarán:"
    echo "  • phpcs.xml.dist (configuración PHP CodeSniffer)"
    echo "  • phpstan.neon.dist (análisis estático PHP)"
    echo "  • eslint.config.js (configuración ESLint)"
    echo "  • package.json (dependencias JavaScript)"
    echo "  • composer.json (dependencias PHP)"
    echo "  • wp.code-workspace (workspace VSCode)"
    echo "  • .vscode/settings.json (configuración VSCode)"
    
    echo ""
    
    return 0
}

# Function to confirm project configuration
confirm_project_configuration() {
    local wordpress_path="$1"
    local project_root="$2"
    local relative_path="$3"
    
    if [ "$NON_INTERACTIVE" = true ]; then
        print_info "Modo no interactivo: continuando automáticamente"
        return 0
    fi
    
    echo "══════════════════════════════════════════════════════════════"
    echo "  ✅ Confirmación de Configuración"
    echo "══════════════════════════════════════════════════════════════"
    echo ""
    
    echo "¿La configuración detectada es correcta?"
    echo ""
    echo "  Raíz del proyecto: $project_root"
    echo "  WordPress: $wordpress_path"
    echo "  Ruta relativa: $relative_path"
    echo ""
    
    while true; do
        echo -n "¿Continuar con esta configuración? (y/n): "
        read response
        echo ""
        
        case "$response" in
            [Yy]|[Yy][Ee][Ss]|[Ss]|[Ss][Ii])
                print_success "Configuración confirmada"
                return 0
                ;;
            [Nn]|[Nn][Oo])
                print_warning "Configuración rechazada por el usuario"
                echo ""
                echo "Puedes:"
                echo "  1. Especificar una ruta diferente de WordPress"
                echo "  2. Verificar que estás en el directorio correcto"
                echo "  3. Consultar la ayuda: $0 --help"
                echo ""
                return 1
                ;;
            *)
                print_warning "Por favor responde 'y' para sí o 'n' para no"
                ;;
        esac
    done
}

# Enhanced function to handle WordPress path validation with better error messages
validate_wordpress_structure_enhanced() {
    local wp_path="$1"
    local show_details="${2:-true}"
    
    if [ "$show_details" = true ]; then
        print_info "Validando estructura WordPress en: $wp_path"
    fi
    
    # Verify that the directory exists
    if [ ! -d "$wp_path" ]; then
        print_error "El directorio no existe: $wp_path"
        echo ""
        echo "💡 Soluciones:"
        echo "  • Verifica que la ruta sea correcta"
        echo "  • Usa rutas absolutas: /Users/usuario/Sites/mi-proyecto/wordpress"
        echo "  • O rutas relativas: ./mi-wordpress"
        echo ""
        [ -n "$LOG_FILE" ] && log_error "WordPress path validation failed - directory not found: $wp_path" "VALIDATION"
        return 1
    fi
    
    # Verify wp-content and subdirectories
    if [ ! -d "$wp_path/wp-content" ]; then
        print_error "Directorio wp-content no encontrado en: $wp_path"
        echo ""
        echo "💡 Soluciones:"
        echo "  • Verifica que sea un directorio WordPress válido"
        echo "  • El directorio debe contener wp-content/"
        echo "  • Estructura esperada: $wp_path/wp-content/"
        echo ""
        echo "🔍 Contenido actual del directorio:"
        ls -la "$wp_path" 2>/dev/null | head -10
        echo ""
        [ -n "$LOG_FILE" ] && log_error "WordPress structure validation failed - wp-content not found" "VALIDATION"
        return 1
    fi
    
    if [ ! -d "$wp_path/wp-content/plugins" ]; then
        print_error "Directorio plugins no encontrado en: $wp_path/wp-content"
        echo ""
        echo "💡 Soluciones:"
        echo "  • Crear directorio: mkdir -p '$wp_path/wp-content/plugins'"
        echo "  • Verificar permisos del directorio wp-content"
        echo ""
        [ -n "$LOG_FILE" ] && log_error "WordPress structure validation failed - plugins directory not found" "VALIDATION"
        return 1
    fi
    
    if [ ! -d "$wp_path/wp-content/themes" ]; then
        print_error "Directorio themes no encontrado en: $wp_path/wp-content"
        echo ""
        echo "💡 Soluciones:"
        echo "  • Crear directorio: mkdir -p '$wp_path/wp-content/themes'"
        echo "  • Verificar permisos del directorio wp-content"
        echo ""
        [ -n "$LOG_FILE" ] && log_error "WordPress structure validation failed - themes directory not found" "VALIDATION"
        return 1
    fi
    
    # Create mu-plugins directory if it doesn't exist
    if [ ! -d "$wp_path/wp-content/mu-plugins" ]; then
        if [ "$show_details" = true ]; then
            print_info "Creando directorio mu-plugins: $wp_path/wp-content/mu-plugins"
        fi
        if mkdir -p "$wp_path/wp-content/mu-plugins"; then
            [ -n "$LOG_FILE" ] && log_info "Created mu-plugins directory" "VALIDATION"
        else
            print_error "Error al crear directorio mu-plugins"
            echo ""
            echo "💡 Soluciones:"
            echo "  • Verificar permisos: chmod 755 '$wp_path/wp-content'"
            echo "  • Crear manualmente: mkdir -p '$wp_path/wp-content/mu-plugins'"
            echo ""
            [ -n "$LOG_FILE" ] && log_error "Failed to create mu-plugins directory" "VALIDATION"
            return 1
        fi
    fi
    
    if [ "$show_details" = true ]; then
        print_success "Estructura WordPress válida"
    fi
    [ -n "$LOG_FILE" ] && log_success "WordPress structure validation passed" "VALIDATION"
    return 0
}

# Function to show comprehensive CLI help
show_cli_help() {
    echo ""
    echo "══════════════════════════════════════════════════════════════"
    echo "  📚 WordPress Init Project - Guía de Uso"
    echo "══════════════════════════════════════════════════════════════"
    echo ""
    
    echo "${BLUE}SINTAXIS:${NC}"
    echo "  $0 [WORDPRESS_PATH] [MODE] [OPTIONS]"
    echo ""
    
    echo "${BLUE}PARÁMETROS:${NC}"
    echo "  WORDPRESS_PATH    Ruta al directorio de WordPress (requerido para ejecución externa)"
    echo "  MODE             Modo de operación (1-4, opcional, por defecto: 1)"
    echo ""
    
    echo "${BLUE}MODOS DE OPERACIÓN:${NC}"
    echo "  ${GREEN}1${NC}    Configurar y formatear proyecto (completo)"
    echo "       • Genera archivos de configuración"
    echo "       • Formatea código existente"
    echo "       • Instala dependencias si es necesario"
    echo ""
    echo "  ${GREEN}2${NC}    Solo configurar (sin formatear)"
    echo "       • Genera solo archivos de configuración"
    echo "       • No modifica código existente"
    echo "       • Ideal para proyectos nuevos"
    echo ""
    echo "  ${GREEN}3${NC}    Solo formatear código existente"
    echo "       • Requiere configuración previa (modo 1 o 2)"
    echo "       • Formatea PHP con PHPCBF"
    echo "       • Formatea JavaScript con ESLint"
    echo ""
    echo "  ${GREEN}4${NC}    Fusionar configuración (requiere jq)"
    echo "       • Combina configuración nueva con existente"
    echo "       • Preserva configuración personalizada"
    echo "       • Ideal para proyectos con configuración previa"
    echo ""
    
    echo "${BLUE}OPCIONES:${NC}"
    echo "  --help, -h       Mostrar esta ayuda"
    echo "  --version, -v    Mostrar versión del script"
    echo ""
    
    echo "${BLUE}EJEMPLOS BÁSICOS:${NC}"
    echo ""
    echo "  ${YELLOW}# Configuración completa (modo interactivo)${NC}"
    echo "  $0 /path/to/my-wordpress"
    echo ""
    echo "  ${YELLOW}# Configuración completa (modo no interactivo)${NC}"
    echo "  $0 /path/to/my-wordpress 1"
    echo ""
    echo "  ${YELLOW}# Solo configurar sin formatear${NC}"
    echo "  $0 ./my-project-wordpress 2"
    echo ""
    echo "  ${YELLOW}# Solo formatear código existente${NC}"
    echo "  $0 /Users/user/Sites/project/wordpress 3"
    echo ""
    
    echo "${BLUE}EJEMPLOS PARA ESTRUCTURAS ESPECÍFICAS:${NC}"
    echo ""
    echo "  ${MAGENTA}📁 Proyecto con Docker:${NC}"
    echo "  Estructura:"
    echo "    /Users/user/Sites/mi-proyecto/"
    echo "    ├── docker/"
    echo "    ├── docker-compose.yml"
    echo "    ├── Jenkinsfile"
    echo "    └── wordpress/          ← Directorio WordPress"
    echo "        └── wp-content/"
    echo ""
    echo "  Comando:"
    echo "    ${GREEN}cd /tmp && git clone <repo> wp-init${NC}"
    echo "    ${GREEN}/tmp/wp-init/init-project.sh /Users/user/Sites/mi-proyecto/wordpress 1${NC}"
    echo ""
    
    echo "  ${MAGENTA}📁 Proyecto con CI/CD:${NC}"
    echo "  Estructura:"
    echo "    /var/www/mi-sitio/"
    echo "    ├── .gitlab-ci.yml"
    echo "    ├── README.md"
    echo "    └── wp/                 ← Directorio WordPress"
    echo "        └── wp-content/"
    echo ""
    echo "  Comando:"
    echo "    ${GREEN}git clone <repo> /tmp/wp-standards${NC}"
    echo "    ${GREEN}/tmp/wp-standards/init-project.sh /var/www/mi-sitio/wp 2${NC}"
    echo ""
    
    echo "  ${MAGENTA}📁 Proyecto con nombre personalizado:${NC}"
    echo "  Estructura:"
    echo "    /home/dev/projects/cliente-web/"
    echo "    ├── docs/"
    echo "    └── cliente-wordpress/  ← Directorio WordPress"
    echo "        └── wp-content/"
    echo ""
    echo "  Comando:"
    echo "    ${GREEN}/tmp/wp-init/init-project.sh /home/dev/projects/cliente-web/cliente-wordpress${NC}"
    echo ""
    
    echo "${BLUE}FLUJO DE TRABAJO RECOMENDADO:${NC}"
    echo ""
    echo "  ${GREEN}1.${NC} ${YELLOW}Clonar plantilla externamente:${NC}"
    echo "     git clone https://github.com/tu-usuario/wp-init.git /tmp/wp-init"
    echo ""
    echo "  ${GREEN}2.${NC} ${YELLOW}Ejecutar desde ubicación externa:${NC}"
    echo "     /tmp/wp-init/init-project.sh /ruta/a/tu/wordpress [modo]"
    echo ""
    echo "  ${GREEN}3.${NC} ${YELLOW}Instalar dependencias (si es necesario):${NC}"
    echo "     cd /ruta/a/tu/proyecto"
    echo "     composer install"
    echo "     npm install"
    echo ""
    echo "  ${GREEN}4.${NC} ${YELLOW}Verificar configuración:${NC}"
    echo "     ./vendor/bin/phpcs --standard=phpcs.xml.dist"
    echo "     npx eslint '**/*.{js,jsx,ts,tsx}'"
    echo ""
    
    echo "${BLUE}VENTAJAS DEL FLUJO EXTERNO:${NC}"
    echo "  ✅ No interfiere con archivos del proyecto"
    echo "  ✅ Preserva configuración de Docker/CI/CD"
    echo "  ✅ Funciona con cualquier estructura de proyecto"
    echo "  ✅ Permite múltiples proyectos desde una plantilla"
    echo "  ✅ Evita conflictos con .gitignore del proyecto"
    echo ""
    
    echo "${BLUE}ARCHIVOS GENERADOS:${NC}"
    echo "  📄 phpcs.xml.dist        - Configuración PHP CodeSniffer"
    echo "  📄 phpstan.neon.dist     - Configuración PHPStan"
    echo "  📄 eslint.config.js      - Configuración ESLint"
    echo "  📄 package.json          - Dependencias JavaScript"
    echo "  📄 composer.json         - Dependencias PHP"
    echo "  📄 wp.code-workspace     - Workspace VSCode"
    echo "  📁 .vscode/              - Configuración VSCode"
    echo "  📄 .gitignore            - Archivos a ignorar"
    echo "  📄 Makefile              - Comandos de desarrollo"
    echo ""
    
    echo "${BLUE}SOLUCIÓN DE PROBLEMAS:${NC}"
    echo ""
    echo "  ${RED}Error: WordPress structure not found${NC}"
    echo "  💡 Verifica que la ruta contenga wp-content/plugins/ y wp-content/themes/"
    echo ""
    echo "  ${RED}Error: Permission denied${NC}"
    echo "  💡 Ejecuta: chmod 755 /ruta/del/proyecto"
    echo ""
    echo "  ${RED}Error: jq not found (Modo 4)${NC}"
    echo "  💡 Instala jq: brew install jq (macOS) o apt-get install jq (Ubuntu)"
    echo ""
    
    echo "${BLUE}MÁS INFORMACIÓN:${NC}"
    echo "  📚 Documentación: https://github.com/tu-usuario/wp-init#readme"
    echo "  🐛 Reportar bugs: https://github.com/tu-usuario/wp-init/issues"
    echo "  💬 Soporte: https://github.com/tu-usuario/wp-init/discussions"
    echo ""
}

# Function to show version information
show_version() {
    echo ""
    echo "WordPress Init Project Script"
    echo "Version: 2.0.0"
    echo "Author: WordPress Standards Team"
    echo "License: MIT"
    echo ""
    echo "Features:"
    echo "  ✅ External WordPress path support"
    echo "  ✅ Docker/CI/CD compatibility"
    echo "  ✅ Automatic project structure detection"
    echo "  ✅ Enhanced validation and error handling"
    echo "  ✅ Recovery system with rollback support"
    echo ""
}

# Legacy WordPress structure detection (for backward compatibility)
detect_wordpress_structure() {
    log_operation_start "DETECT_WORDPRESS_STRUCTURE" "Detecting WordPress structure"
    
    # If WordPress path is already configured via CLI, use it
    if [ -n "$WORDPRESS_PATH" ]; then
        log_info "Using pre-configured WordPress path: $WP_CONTENT_DIR" "STRUCTURE"
        log_operation_end "DETECT_WORDPRESS_STRUCTURE" "SUCCESS" "Using external WordPress path"
        return 0
    fi
    
    # Legacy detection for backward compatibility
    if [ -d "wordpress/wp-content" ]; then
        WP_CONTENT_DIR="wordpress/wp-content"
        print_info "Legacy mode: WordPress structure found at wordpress/wp-content"
        log_info "Legacy WordPress structure detected: wordpress/wp-content" "STRUCTURE"
        log_operation_end "DETECT_WORDPRESS_STRUCTURE" "SUCCESS" "Legacy structure found"
        return 0
    elif [ -d "wp-content" ]; then
        WP_CONTENT_DIR="wp-content"
        print_info "Legacy mode: WordPress structure found at wp-content"
        log_info "Legacy WordPress structure detected: wp-content" "STRUCTURE"
        log_operation_end "DETECT_WORDPRESS_STRUCTURE" "SUCCESS" "Direct structure found"
        return 0
    fi
    
    log_operation_end "DETECT_WORDPRESS_STRUCTURE" "FAILED" "No WordPress structure found"
    return 1
}

detect_custom_plugins() {
    local plugins_dir="$WP_CONTENT_DIR/plugins"
    [ ! -d "$plugins_dir" ] && { echo ""; return; }
    
    local -a custom_plugins=()
    local exclude="akismet|hello|wordpress-importer|classic-editor|classic-widgets"
    
    for plugin_dir in "$plugins_dir"/*; do
        [ ! -d "$plugin_dir" ] && continue
        local name=$(basename "$plugin_dir")
        [[ "$name" =~ $exclude ]] && continue
        [ -n "$(find "$plugin_dir" -maxdepth 2 -name "*.php" 2>/dev/null)" ] && custom_plugins+=("$name")
    done
    
    echo "${custom_plugins[@]}"
}

detect_custom_themes() {
    local themes_dir="$WP_CONTENT_DIR/themes"
    [ ! -d "$themes_dir" ] && { echo ""; return; }
    
    local -a custom_themes=()
    local exclude="twenty"
    
    for theme_dir in "$themes_dir"/*; do
        [ ! -d "$theme_dir" ] && continue
        local name=$(basename "$theme_dir")
        [[ "$name" =~ $exclude ]] && continue
        { [ -f "$theme_dir/style.css" ] || [ -f "$theme_dir/functions.php" ]; } && custom_themes+=("$name")
    done
    
    echo "${custom_themes[@]}"
}

detect_custom_mu_plugins() {
    local mu_dir="$WP_CONTENT_DIR/mu-plugins"
    [ ! -d "$mu_dir" ] && { echo ""; return; }
    
    local -a mu_plugins=()
    for item in "$mu_dir"/*; do
        [ -d "$item" ] || continue  # Solo directorios
        local name=$(basename "$item")
        # Excluir directorios especiales
        [[ "$name" == "."* ]] || [[ "$name" == "index.php" ]] && continue
        mu_plugins+=("$name")
    done
    
    echo "${mu_plugins[@]}"
}

# ====================================================================
# Error Handling and Validation Module
# ====================================================================

# Source modular validation engine and recovery manager
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/tests/lib/validation-engine.sh" ]; then
    source "$SCRIPT_DIR/tests/lib/validation-engine.sh"
else
    echo "Warning: Validation engine not found at $SCRIPT_DIR/tests/lib/validation-engine.sh"
fi

if [ -f "$SCRIPT_DIR/tests/lib/recovery-manager.sh" ]; then
    source "$SCRIPT_DIR/tests/lib/recovery-manager.sh"
else
    echo "Warning: Recovery manager not found at $SCRIPT_DIR/tests/lib/recovery-manager.sh"
fi

# Global variables for error tracking and logging
BACKUP_DIR=""
COPIED_FILES=()
FAILED_OPERATIONS=()
LOG_FILE=""
VALIDATION_ERRORS=0

# Initialize enhanced logging system
init_logging() {
    LOG_FILE="./init-project-$(date +%Y%m%d-%H%M%S).log"
    
    # Create log file with enhanced header
    cat > "$LOG_FILE" << LOG_HEADER
================================================================================
WordPress Init Project Script - Execution Log
================================================================================
Execution ID: $(date +%Y%m%d-%H%M%S)-$$
Started: $(date '+%Y-%m-%d %H:%M:%S %Z')
Working Directory: $(pwd)
User: $(whoami)
System: $(uname -s) $(uname -r)
Shell: $SHELL
Script Version: $(grep -o 'WordPress Standards.*Script' "$0" | head -1 || echo "Unknown")
================================================================================

LOG_HEADER
    
    log_info "Logging system initialized"
    log_info "Log file: $LOG_FILE"
}

# Enhanced logging functions with detailed timestamps and context
log_info() {
    local message="$1"
    local context="${2:-}"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S.%3N')
    
    if [ -n "$context" ]; then
        echo "[$timestamp] [INFO] [$context] $message" >> "$LOG_FILE"
    else
        echo "[$timestamp] [INFO] $message" >> "$LOG_FILE"
    fi
}

log_warning() {
    local message="$1"
    local context="${2:-}"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S.%3N')
    
    if [ -n "$context" ]; then
        echo "[$timestamp] [WARN] [$context] $message" >> "$LOG_FILE"
    else
        echo "[$timestamp] [WARN] $message" >> "$LOG_FILE"
    fi
}

log_error() {
    local message="$1"
    local context="${2:-}"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S.%3N')
    
    if [ -n "$context" ]; then
        echo "[$timestamp] [ERROR] [$context] $message" >> "$LOG_FILE"
    else
        echo "[$timestamp] [ERROR] $message" >> "$LOG_FILE"
    fi
}

log_success() {
    local message="$1"
    local context="${2:-}"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S.%3N')
    
    if [ -n "$context" ]; then
        echo "[$timestamp] [SUCCESS] [$context] $message" >> "$LOG_FILE"
    else
        echo "[$timestamp] [SUCCESS] $message" >> "$LOG_FILE"
    fi
}

# New logging functions for better operation tracking
log_operation_start() {
    local operation="$1"
    local details="${2:-}"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S.%3N')
    
    echo "[$timestamp] [OPERATION] [START] $operation" >> "$LOG_FILE"
    [ -n "$details" ] && echo "[$timestamp] [OPERATION] [DETAILS] $details" >> "$LOG_FILE"
}

log_operation_end() {
    local operation="$1"
    local status="${2:-SUCCESS}"
    local details="${3:-}"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S.%3N')
    
    echo "[$timestamp] [OPERATION] [END] $operation - Status: $status" >> "$LOG_FILE"
    [ -n "$details" ] && echo "[$timestamp] [OPERATION] [RESULT] $details" >> "$LOG_FILE"
}

log_file_operation() {
    local operation="$1"  # CREATE, MODIFY, DELETE, BACKUP
    local file="$2"
    local status="${3:-SUCCESS}"
    local details="${4:-}"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S.%3N')
    
    echo "[$timestamp] [FILE] [$operation] $file - Status: $status" >> "$LOG_FILE"
    [ -n "$details" ] && echo "[$timestamp] [FILE] [DETAILS] $details" >> "$LOG_FILE"
}

log_validation_result() {
    local check="$1"
    local result="${2:-PASS}"
    local details="${3:-}"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S.%3N')
    
    echo "[$timestamp] [VALIDATION] [$result] $check" >> "$LOG_FILE"
    [ -n "$details" ] && echo "[$timestamp] [VALIDATION] [DETAILS] $details" >> "$LOG_FILE"
}

log_component_action() {
    local component_type="$1"  # PLUGIN, THEME, MU_PLUGIN
    local component_name="$2"
    local action="$3"  # DETECTED, SELECTED, PROCESSED
    local details="${4:-}"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S.%3N')
    
    echo "[$timestamp] [COMPONENT] [$component_type] [$action] $component_name" >> "$LOG_FILE"
    [ -n "$details" ] && echo "[$timestamp] [COMPONENT] [DETAILS] $details" >> "$LOG_FILE"
}

# ====================================================================
# Enhanced Error Message System with Solutions and Documentation Links
# ====================================================================

# Enhanced error functions with specific solutions and documentation links
print_error_with_solution() {
    local error_code="$1"
    local context="$2"
    local details="${3:-}"
    
    # Use validation engine results if available
    if [ ${#VALIDATION_RESULTS[@]} -gt 0 ]; then
        for result in "${VALIDATION_RESULTS[@]}"; do
            IFS='|' read -r check status severity message solution files <<< "$result"
            if [ "$status" = "FAIL" ] && [ -n "$solution" ]; then
                print_error "$message" "VALIDATION"
                echo ""
                echo -e "${BLUE}💡 Solution: ${solution}${NC}"
                if [ -n "$files" ]; then
                    echo -e "${MAGENTA}📁 Affected files: ${files}${NC}"
                fi
                echo ""
                return 0
            fi
        done
    fi
    
    # Fallback to original error handling for backward compatibility
    case "$error_code" in
        "WORDPRESS_STRUCTURE_NOT_FOUND")
            print_error "WordPress structure not found" "VALIDATION"
            echo ""
            echo "🔍 Problem: The script cannot detect a valid WordPress project structure."
            echo ""
            echo "💡 Solutions:"
            echo "   1. Verify you're in the correct directory:"
            echo "      ${BLUE}pwd && ls -la${NC}"
            echo ""
            echo "   2. Create WordPress structure (option 1 - with subdirectory):"
            echo "      ${BLUE}mkdir -p wordpress/wp-content/{plugins,themes,mu-plugins}${NC}"
            echo ""
            echo "   3. Create WordPress structure (option 2 - direct):"
            echo "      ${BLUE}mkdir -p wp-content/{plugins,themes,mu-plugins}${NC}"
            echo ""
            echo "   4. Verify structure was created:"
            echo "      ${BLUE}ls -la wordpress/wp-content/ || ls -la wp-content/${NC}"
            echo ""
            echo "📚 Documentation: https://github.com/tu-usuario/wp-init#troubleshooting"
            log_error "WordPress structure validation failed with solution provided" "ERROR_HANDLER"
            ;;
            
        "COMPONENT_DIRECTORY_NOT_FOUND")
            local component_type="$context"
            local component_name="$details"
            print_error "Selected $component_type directory not found: $component_name" "VALIDATION"
            echo ""
            echo "🔍 Problem: The script cannot find the $component_type '$component_name' that you selected."
            echo ""
            echo "💡 Solutions:"
            echo "   1. Verify the directory exists:"
            echo "      ${BLUE}ls -la $WP_CONTENT_DIR/${component_type}s/$component_name${NC}"
            echo ""
            echo "   2. Create basic $component_type structure:"
            case "$component_type" in
                "plugin")
                    echo "      ${BLUE}mkdir -p $WP_CONTENT_DIR/plugins/$component_name${NC}"
                    echo "      ${BLUE}echo '<?php // Plugin: $component_name' > $WP_CONTENT_DIR/plugins/$component_name/init.php${NC}"
                    ;;
                "theme")
                    echo "      ${BLUE}mkdir -p $WP_CONTENT_DIR/themes/$component_name${NC}"
                    echo "      ${BLUE}echo '<?php // Theme: $component_name' > $WP_CONTENT_DIR/themes/$component_name/functions.php${NC}"
                    echo "      ${BLUE}echo '/* Theme Name: $component_name */' > $WP_CONTENT_DIR/themes/$component_name/style.css${NC}"
                    ;;
                "mu-plugin")
                    echo "      ${BLUE}mkdir -p $WP_CONTENT_DIR/mu-plugins/$component_name${NC}"
                    echo "      ${BLUE}echo '<?php // MU-Plugin: $component_name' > $WP_CONTENT_DIR/mu-plugins/$component_name/init.php${NC}"
                    ;;
            esac
            echo ""
            echo "   3. Re-run the script:"
            echo "      ${BLUE}./init-project.sh${NC}"
            echo ""
            echo "📚 Documentation: https://github.com/tu-usuario/wp-init#component-structure"
            log_error "$component_type directory not found: $component_name - solution provided" "ERROR_HANDLER"
            ;;
            
        "NO_COMPONENTS_SELECTED")
            print_error "No components selected for processing" "VALIDATION"
            echo ""
            echo "🔍 Problem: You need to select at least one component (plugin, theme, or mu-plugin) to proceed."
            echo ""
            echo "💡 Solutions:"
            echo "   1. Verify you have custom components:"
            echo "      ${BLUE}ls -la $WP_CONTENT_DIR/plugins/${NC}"
            echo "      ${BLUE}ls -la $WP_CONTENT_DIR/themes/${NC}"
            echo ""
            echo "   2. Create a custom plugin if none exist:"
            echo "      ${BLUE}mkdir -p $WP_CONTENT_DIR/plugins/mi-proyecto-plugin${NC}"
            echo "      ${BLUE}cat > $WP_CONTENT_DIR/plugins/mi-proyecto-plugin/init.php << 'EOF'${NC}"
            echo "      <?php"
            echo "      /*"
            echo "      Plugin Name: Mi Proyecto Plugin"
            echo "      Description: Custom plugin for my project"
            echo "      Version: 1.0.0"
            echo "      */"
            echo "      EOF"
            echo ""
            echo "   3. When prompted, answer 'y' or 'yes' to include components"
            echo ""
            echo "📚 Documentation: https://github.com/tu-usuario/wp-init#component-selection"
            log_error "No components selected - solution provided" "ERROR_HANDLER"
            ;;
            
        "JQ_NOT_AVAILABLE")
            print_error "jq is required for Mode 4 (Merge configuration) but not available" "VALIDATION"
            echo ""
            echo "🔍 Problem: Mode 4 requires 'jq' for JSON merging operations."
            echo ""
            echo "💡 Installation instructions:"
            echo "   • macOS: ${BLUE}brew install jq${NC}"
            echo "   • Ubuntu/Debian: ${BLUE}sudo apt-get install jq${NC}"
            echo "   • CentOS/RHEL: ${BLUE}sudo yum install jq${NC}"
            echo "   • Windows: ${BLUE}choco install jq${NC}"
            echo ""
            echo "   Alternative: Use a different mode:"
            echo "   • Mode 1: Configure and format project"
            echo "   • Mode 2: Configure only (no formatting)"
            echo "   • Mode 3: Format existing code only"
            echo ""
            echo "📚 Documentation: https://stedolan.github.io/jq/download/"
            log_error "jq not available for Mode 4 - installation instructions provided" "ERROR_HANDLER"
            ;;
            
        "INSUFFICIENT_DISK_SPACE")
            local available="$context"
            local required="$details"
            print_error "Insufficient disk space: ${available}MB available, ${required}MB required" "VALIDATION"
            echo ""
            echo "🔍 Problem: Not enough disk space for the operation."
            echo ""
            echo "💡 Solutions:"
            echo "   1. Free up disk space:"
            echo "      ${BLUE}rm -rf backup-* *.log node_modules/ vendor/${NC}"
            echo ""
            echo "   2. Check current disk usage:"
            echo "      ${BLUE}df -h .${NC}"
            echo "      ${BLUE}du -sh * | sort -hr | head -10${NC}"
            echo ""
            echo "   3. Consider using a different mode that requires less space:"
            echo "      • Mode 3 (Format only): ~20MB"
            echo "      • Mode 2 (Configure only): ~50MB"
            echo ""
            echo "📚 Documentation: https://github.com/tu-usuario/wp-init#disk-space-requirements"
            log_error "Insufficient disk space: ${available}MB available, ${required}MB required - solutions provided" "ERROR_HANDLER"
            ;;
            
        "BACKUP_CREATION_FAILED")
            local file="$context"
            print_error "Failed to create backup for: $file" "BACKUP"
            echo ""
            echo "🔍 Problem: Cannot create backup before modifying existing file."
            echo ""
            echo "💡 Solutions:"
            echo "   1. Check write permissions:"
            echo "      ${BLUE}ls -la .${NC}"
            echo "      ${BLUE}chmod 755 .${NC}"
            echo ""
            echo "   2. Check available disk space:"
            echo "      ${BLUE}df -h .${NC}"
            echo ""
            echo "   3. Manually create backup:"
            echo "      ${BLUE}cp '$file' '${file}.backup-$(date +%Y%m%d-%H%M%S)'${NC}"
            echo ""
            echo "   4. Continue without backup (not recommended):"
            echo "      Re-run with --force-no-backup flag"
            echo ""
            echo "📚 Documentation: https://github.com/tu-usuario/wp-init#backup-system"
            log_error "Backup creation failed for $file - solutions provided" "ERROR_HANDLER"
            ;;
            
        "TEMPLATE_FILE_NOT_FOUND")
            local template="$context"
            print_error "Template file not found: $template" "TEMPLATE"
            echo ""
            echo "🔍 Problem: Required template file is missing."
            echo ""
            echo "💡 Solutions:"
            echo "   1. Download missing template:"
            echo "      ${BLUE}curl -O https://raw.githubusercontent.com/tu-usuario/wp-init/main/$template${NC}"
            echo ""
            echo "   2. Clone fresh repository:"
            echo "      ${BLUE}cd .. && git clone https://github.com/tu-usuario/wp-init.git wp-init-fresh${NC}"
            echo "      ${BLUE}cd wp-init-fresh${NC}"
            echo ""
            echo "   3. Continue without optional templates:"
            echo "      Some templates are optional and the script can continue without them"
            echo ""
            echo "📚 Documentation: https://github.com/tu-usuario/wp-init#template-files"
            log_error "Template file not found: $template - solutions provided" "ERROR_HANDLER"
            ;;
            
        "MERGE_OPERATION_FAILED")
            local file="$context"
            local operation="$details"
            print_error "Failed to merge $file" "MERGE"
            echo ""
            echo "🔍 Problem: JSON merge operation failed for $file."
            echo ""
            echo "💡 Solutions:"
            echo "   1. Verify JSON syntax:"
            echo "      ${BLUE}jq empty '$file'${NC}"
            echo ""
            echo "   2. Check backup and restore if needed:"
            echo "      ${BLUE}ls -la backup-*/$file${NC}"
            echo "      ${BLUE}cp backup-*/$file .${NC}"
            echo ""
            echo "   3. Manual merge (create new file):"
            echo "      ${BLUE}mv '$file' '${file}.original'${NC}"
            echo "      Then re-run in Mode 2 to create fresh configuration"
            echo ""
            echo "   4. Use different mode:"
            echo "      Mode 2 (Configure only) creates new files instead of merging"
            echo ""
            echo "📚 Documentation: https://github.com/tu-usuario/wp-init#mode-4-merge"
            log_error "Merge operation failed for $file - solutions provided" "ERROR_HANDLER"
            ;;
            
        *)
            print_error "$error_code" "$context"
            echo ""
            echo "💡 General troubleshooting:"
            echo "   1. Check the log file for details: $LOG_FILE"
            echo "   2. Verify file permissions: ${BLUE}ls -la .${NC}"
            echo "   3. Check available disk space: ${BLUE}df -h .${NC}"
            echo "   4. Ensure you're in a WordPress project directory"
            echo ""
            echo "📚 Full documentation: https://github.com/tu-usuario/wp-init#troubleshooting"
            log_error "Unknown error: $error_code - general solutions provided" "ERROR_HANDLER"
            ;;
    esac
    echo ""
}

# Function to show recovery options after errors
show_recovery_options() {
    local error_count="$1"
    local context="${2:-GENERAL}"
    
    echo "🔄 Recovery Options:"
    echo ""
    
    # Show recovery system options if available
    if command -v list_recovery_points >/dev/null 2>&1 && is_recovery_enabled; then
        local recovery_points
        recovery_points=$(list_recovery_points simple | wc -l)
        if [ "$recovery_points" -gt 0 ]; then
            echo "   ${GREEN}Recovery System Available:${NC}"
            echo "   • ${BLUE}List recovery points${NC}: recovery_manager list"
            echo "   • ${BLUE}Rollback to recovery point${NC}: recovery_manager rollback <point_id>"
            echo "   • ${BLUE}View recovery point info${NC}: recovery_manager info <point_id>"
            echo ""
        fi
    fi
    
    case "$context" in
        "VALIDATION")
            echo "   1. ${BLUE}Fix validation issues${NC} and re-run the script"
            echo "   2. ${BLUE}Continue with warnings${NC} (may cause issues later)"
            echo "   3. ${BLUE}Use a different mode${NC} that requires fewer resources"
            echo "   4. ${BLUE}Check documentation${NC} for specific solutions"
            ;;
        "FILE_OPERATIONS")
            echo "   1. ${BLUE}Restore from backup${NC}: cp backup-*/* ."
            echo "   2. ${BLUE}Fix file permissions${NC}: chmod 755 . && chmod 644 *"
            echo "   3. ${BLUE}Free up disk space${NC}: rm -rf backup-* *.log"
            echo "   4. ${BLUE}Re-run with different options${NC}"
            ;;
        "MERGE_OPERATIONS")
            echo "   1. ${BLUE}Restore original files${NC}: cp backup-*/* ."
            echo "   2. ${BLUE}Use Mode 2${NC} (configure only) instead of Mode 4"
            echo "   3. ${BLUE}Manually merge configurations${NC} using provided templates"
            echo "   4. ${BLUE}Check JSON syntax${NC}: jq empty file.json"
            ;;
        *)
            echo "   1. ${BLUE}Check the log file${NC}: cat $LOG_FILE"
            echo "   2. ${BLUE}Restore from backup${NC} if available"
            echo "   3. ${BLUE}Re-run with different parameters${NC}"
            echo "   4. ${BLUE}Consult documentation${NC}: https://github.com/tu-usuario/wp-init"
            ;;
    esac
    
    echo ""
    log_info "Recovery options displayed for context: $context" "ERROR_HANDLER"
}

# ====================================================================
# Graceful Recovery System
# ====================================================================

# Global variables for tracking recovery operations
RECOVERY_OPERATIONS=()
SKIPPED_OPERATIONS=()
PARTIAL_SUCCESS_OPERATIONS=()

# Function to handle non-fatal errors gracefully
handle_non_fatal_error() {
    local operation="$1"
    local error_message="$2"
    local recovery_action="${3:-SKIP}"
    local context="${4:-GENERAL}"
    
    log_warning "Non-fatal error in $operation: $error_message" "RECOVERY"
    
    case "$recovery_action" in
        "SKIP")
            print_warning "Skipping $operation due to error: $error_message" "RECOVERY"
            SKIPPED_OPERATIONS+=("$operation: $error_message")
            log_info "Operation skipped: $operation" "RECOVERY"
            return 0
            ;;
        "CONTINUE")
            print_warning "Continuing $operation with warnings: $error_message" "RECOVERY"
            PARTIAL_SUCCESS_OPERATIONS+=("$operation: $error_message")
            log_info "Operation continued with warnings: $operation" "RECOVERY"
            return 0
            ;;
        "RETRY")
            print_info "Retrying $operation after error: $error_message" "RECOVERY"
            RECOVERY_OPERATIONS+=("$operation: $error_message")
            log_info "Operation queued for retry: $operation" "RECOVERY"
            return 1
            ;;
        "PROMPT")
            echo ""
            print_warning "Error in $operation: $error_message" "RECOVERY"
            echo ""
            echo "🔄 Recovery options:"
            echo "   1. Skip this operation and continue"
            echo "   2. Retry this operation"
            echo "   3. Abort entire process"
            echo ""
            echo -n "Choose option (1-3): "
            read recovery_choice
            
            case "$recovery_choice" in
                1)
                    print_info "Skipping $operation and continuing..." "RECOVERY"
                    SKIPPED_OPERATIONS+=("$operation: $error_message")
                    log_info "User chose to skip operation: $operation" "RECOVERY"
                    return 0
                    ;;
                2)
                    print_info "Retrying $operation..." "RECOVERY"
                    RECOVERY_OPERATIONS+=("$operation: $error_message")
                    log_info "User chose to retry operation: $operation" "RECOVERY"
                    return 1
                    ;;
                3)
                    print_error "Process aborted by user" "RECOVERY"
                    log_error "User chose to abort process during recovery" "RECOVERY"
                    show_operation_summary
                    exit 1
                    ;;
                *)
                    print_warning "Invalid choice, skipping operation" "RECOVERY"
                    SKIPPED_OPERATIONS+=("$operation: $error_message")
                    log_info "Invalid user choice, operation skipped: $operation" "RECOVERY"
                    return 0
                    ;;
            esac
            ;;
        *)
            print_error "Unknown recovery action: $recovery_action" "RECOVERY"
            FAILED_OPERATIONS+=("$operation: $error_message")
            return 1
            ;;
    esac
}

# Enhanced safe file operation with graceful recovery
safe_file_operation_with_recovery() {
    local operation="$1"
    local source="$2"
    local target="$3"
    local recovery_mode="${4:-PROMPT}"  # SKIP, CONTINUE, RETRY, PROMPT
    
    log_operation_start "SAFE_FILE_OPERATION" "$operation: $source -> $target"
    
    # First attempt
    if safe_file_operation "$operation" "$source" "$target"; then
        log_operation_end "SAFE_FILE_OPERATION" "SUCCESS" "$operation completed successfully"
        return 0
    fi
    
    # Handle failure with recovery
    local error_msg="Failed to $operation: $source -> $target"
    
    case "$recovery_mode" in
        "CRITICAL")
            # Critical operations cannot be skipped
            print_error "Critical operation failed: $operation" "RECOVERY"
            log_operation_end "SAFE_FILE_OPERATION" "CRITICAL_FAILURE" "$error_msg"
            return 1
            ;;
        "OPTIONAL")
            # Optional operations can be skipped without user prompt
            handle_non_fatal_error "$operation" "$error_msg" "SKIP" "FILE_OPERATIONS"
            log_operation_end "SAFE_FILE_OPERATION" "SKIPPED" "Optional operation skipped"
            return 0
            ;;
        *)
            # Use the specified recovery mode
            if handle_non_fatal_error "$operation" "$error_msg" "$recovery_mode" "FILE_OPERATIONS"; then
                log_operation_end "SAFE_FILE_OPERATION" "RECOVERED" "Operation handled gracefully"
                return 0
            else
                log_operation_end "SAFE_FILE_OPERATION" "FAILED" "Recovery failed"
                return 1
            fi
            ;;
    esac
}

# Function to attempt recovery of failed operations
attempt_recovery_operations() {
    if [ ${#RECOVERY_OPERATIONS[@]} -eq 0 ]; then
        return 0
    fi
    
    print_info "Attempting recovery of ${#RECOVERY_OPERATIONS[@]} failed operation(s)..." "RECOVERY"
    log_operation_start "RECOVERY_ATTEMPT" "Attempting to recover ${#RECOVERY_OPERATIONS[@]} operations"
    
    local recovered=0
    local still_failed=0
    
    for recovery_op in "${RECOVERY_OPERATIONS[@]}"; do
        local operation="${recovery_op%: *}"
        local error="${recovery_op#*: }"
        
        print_info "Retrying: $operation" "RECOVERY"
        
        # Simple retry logic - this would need to be expanded based on operation type
        case "$operation" in
            *"backup"*)
                # Retry backup operation
                local file=$(echo "$operation" | sed 's/.*backup //')
                if create_backup "$file"; then
                    print_success "Recovery successful: $operation" "RECOVERY"
                    ((recovered++))
                else
                    print_warning "Recovery failed: $operation" "RECOVERY"
                    FAILED_OPERATIONS+=("$recovery_op")
                    ((still_failed++))
                fi
                ;;
            *"copy"*|*"write"*)
                # For now, just mark as still failed - would need specific retry logic
                print_warning "Recovery not implemented for: $operation" "RECOVERY"
                FAILED_OPERATIONS+=("$recovery_op")
                ((still_failed++))
                ;;
            *)
                print_warning "Unknown operation type for recovery: $operation" "RECOVERY"
                FAILED_OPERATIONS+=("$recovery_op")
                ((still_failed++))
                ;;
        esac
    done
    
    if [ "$recovered" -gt 0 ]; then
        print_success "Recovered $recovered operation(s)" "RECOVERY"
    fi
    
    if [ "$still_failed" -gt 0 ]; then
        print_warning "$still_failed operation(s) still failed after recovery attempt" "RECOVERY"
    fi
    
    log_operation_end "RECOVERY_ATTEMPT" "COMPLETED" "Recovered: $recovered, Still failed: $still_failed"
    
    # Clear recovery operations list
    RECOVERY_OPERATIONS=()
    
    return 0
}

# Function to check if we can continue despite errors
can_continue_with_errors() {
    local critical_errors="$1"
    local total_errors="$2"
    local context="${3:-GENERAL}"
    
    # If no critical errors, we can usually continue
    if [ "$critical_errors" -eq 0 ]; then
        return 0
    fi
    
    # Context-specific logic
    case "$context" in
        "VALIDATION")
            # Some validation errors are acceptable if user confirms
            if [ "$critical_errors" -le 2 ] && [ "$total_errors" -le 5 ]; then
                return 0
            fi
            ;;
        "FILE_OPERATIONS")
            # File operation errors are usually recoverable
            if [ "$critical_errors" -le 1 ]; then
                return 0
            fi
            ;;
        "TEMPLATE_PROCESSING")
            # Template errors are often non-critical
            return 0
            ;;
        *)
            # Conservative approach for unknown contexts
            if [ "$critical_errors" -eq 1 ] && [ "$total_errors" -le 3 ]; then
                return 0
            fi
            ;;
    esac
    
    return 1
}

# Enhanced validation with graceful recovery using modular validation engine
validate_with_recovery() {
    print_info "Performing validation with graceful error handling..." "VALIDATION"
    log_operation_start "VALIDATION_WITH_RECOVERY" "Starting enhanced validation with recovery"
    
    # Determine validation context based on mode and configuration
    local validation_context=""
    if [ "$CONFIGURE_PROJECT" = true ] && [ "$MERGE_MODE" = true ]; then
        validation_context="$CONTEXT_MERGE"
    elif [ "$CONFIGURE_PROJECT" = true ]; then
        validation_context="$CONTEXT_CONFIGURE"
    elif [ "$FORMAT_CODE" = true ]; then
        validation_context="$CONTEXT_FORMAT"
    else
        validation_context="$CONTEXT_TEMPLATE"
    fi
    
    # Run modular validation system
    if validate_system "$validation_context" "$MODE"; then
        print_success "All validations passed" "VALIDATION"
        log_operation_end "VALIDATION_WITH_RECOVERY" "SUCCESS" "All validations completed successfully"
        return 0
    fi
    
    # Display validation results
    display_validation_results false
    
    # Check if we can continue despite errors
    if validation_can_continue; then
        print_warning "Validation completed with errors, but operation can continue" "VALIDATION"
        echo ""
        echo "🔄 Continue with limitations:"
        echo "   • Some features may be disabled"
        echo "   • Backup and recovery options available"
        echo "   • Detailed logging will track all issues"
        echo ""
        
        echo -n "Continue despite validation errors? (y/n): "
        read continue_choice
        
        if [[ $continue_choice =~ ^[Yy]$ ]]; then
            print_info "Continuing with validation warnings..." "VALIDATION"
            log_operation_end "VALIDATION_WITH_RECOVERY" "CONTINUED_WITH_WARNINGS" "User chose to continue with $(get_validation_summary)"
            return 0
        else
            print_warning "Operation cancelled by user due to validation errors" "VALIDATION"
            log_operation_end "VALIDATION_WITH_RECOVERY" "CANCELLED" "User cancelled due to validation errors"
            show_recovery_options "$VALIDATION_ERRORS" "VALIDATION"
            return 1
        fi
    else
        print_error "Too many critical errors to continue safely" "VALIDATION"
        log_operation_end "VALIDATION_WITH_RECOVERY" "FAILED" "Critical validation errors: $(get_validation_summary)"
        show_recovery_options "$VALIDATION_ERRORS" "VALIDATION"
        return 1
    fi
}

# Enhanced print functions with contextual logging
print_success() { 
    local message="$1"
    local context="${2:-USER_OUTPUT}"
    echo -e "${GREEN}✅ $message${NC}"
    log_success "$message" "$context"
}

print_error() { 
    local message="$1"
    local context="${2:-USER_OUTPUT}"
    echo -e "${RED}❌ $message${NC}"
    log_error "$message" "$context"
}

print_warning() { 
    local message="$1"
    local context="${2:-USER_OUTPUT}"
    echo -e "${YELLOW}⚠️  $message${NC}"
    log_warning "$message" "$context"
}

print_info() { 
    local message="$1"
    local context="${2:-USER_OUTPUT}"
    echo -e "${BLUE}ℹ️  $message${NC}"
    log_info "$message" "$context"
}

# Progress indicator function
show_progress() {
    local current="$1"
    local total="$2"
    local task="$3"
    local percentage=$((current * 100 / total))
    local bar_length=30
    local filled_length=$((percentage * bar_length / 100))
    
    printf "\r${BLUE}[%3d%%]${NC} " "$percentage"
    printf "["
    for ((i=0; i<filled_length; i++)); do printf "█"; done
    for ((i=filled_length; i<bar_length; i++)); do printf "░"; done
    printf "] %s" "$task"
    
    if [ "$current" -eq "$total" ]; then
        echo ""
    fi
}

# Comprehensive validation function - now uses modular validation engine
validate_file_operations() {
    print_info "Performing pre-execution validation checks..." "VALIDATION"
    log_operation_start "VALIDATION_CHECKS" "Starting comprehensive pre-execution validation using modular engine"
    
    # Determine validation context based on mode and configuration
    local validation_context=""
    if [ "$CONFIGURE_PROJECT" = true ] && [ "$MERGE_MODE" = true ]; then
        validation_context="$CONTEXT_MERGE"
    elif [ "$CONFIGURE_PROJECT" = true ]; then
        validation_context="$CONTEXT_CONFIGURE"
    elif [ "$FORMAT_CODE" = true ]; then
        validation_context="$CONTEXT_FORMAT"
    else
        validation_context="$CONTEXT_TEMPLATE"
    fi
    
    # Run modular validation system
    if validate_system "$validation_context" "$MODE"; then
        print_success "All validation checks passed" "VALIDATION"
        log_operation_end "VALIDATION_CHECKS" "SUCCESS" "All validation checks completed successfully"
        VALIDATION_ERRORS=0
        return 0
    else
        # Set legacy VALIDATION_ERRORS for backward compatibility
        VALIDATION_ERRORS=$VALIDATION_ERRORS
        
        print_error "Validation failed with $VALIDATION_ERRORS error(s)" "VALIDATION"
        log_operation_end "VALIDATION_CHECKS" "FAILED" "$VALIDATION_ERRORS validation errors found"
        echo ""
        show_recovery_options "$VALIDATION_ERRORS" "VALIDATION"
        return 1
    fi
}

# ====================================================================
# Mode-Specific File Operations Module
# ====================================================================

# Function to create backup in project root directory
create_project_backup() {
    local file="$1"
    local backup_location="${PROJECT_ROOT:-./}"
    
    if [ ! -f "$file" ]; then
        log_warning "Backup requested for non-existent file: $file" "BACKUP"
        log_file_operation "BACKUP" "$file" "SKIPPED" "File does not exist"
        return 1
    fi
    
    log_operation_start "BACKUP_FILE" "Creating backup for: $file in project root"
    
    # Use recovery system if available, otherwise fallback to legacy backup
    if command -v recovery_manager >/dev/null 2>&1 && is_recovery_enabled; then
        # Initialize recovery system if not already done
        if [ -z "$RECOVERY_BASE_DIR" ] || [ ! -d "$RECOVERY_BASE_DIR" ]; then
            init_recovery_system "$backup_location/recovery"
        fi
        
        # Create recovery point for this file
        local recovery_point_id
        recovery_point_id=$(create_recovery_point "backup_$(basename "$file")" "Backup before modification" "$file")
        
        if [ -n "$recovery_point_id" ]; then
            print_info "Recovery point created: $recovery_point_id" "BACKUP"
            log_operation_end "BACKUP_FILE" "SUCCESS" "File backed up using recovery system"
            COPIED_FILES+=("$file")
            return 0
        else
            log_warning "Recovery system backup failed, falling back to legacy backup" "BACKUP"
        fi
    fi
    
    # Legacy backup system (fallback) - create in project root
    # Initialize backup directory in project root if needed
    if [ -z "$BACKUP_DIR" ]; then
        BACKUP_DIR="$backup_location/backup-$(date +%Y%m%d-%H%M%S)"
    fi
    
    # Create backup directory if it doesn't exist
    if [ ! -d "$BACKUP_DIR" ]; then
        if ! mkdir -p "$BACKUP_DIR"; then
            print_error_with_solution "BACKUP_CREATION_FAILED" "$BACKUP_DIR"
            log_file_operation "CREATE_DIR" "$BACKUP_DIR" "FAILED" "mkdir command failed"
            log_operation_end "BACKUP_FILE" "FAILED" "Could not create backup directory"
            return 1
        fi
        print_info "Backup directory created: $BACKUP_DIR" "BACKUP"
        log_info "Backup directory created: $BACKUP_DIR" "BACKUP"
    fi
    
    # Create backup copy
    local backup_file="$BACKUP_DIR/$(basename "$file")"
    if cp "$file" "$backup_file"; then
        print_success "Backup created: $backup_file" "BACKUP"
        log_file_operation "BACKUP" "$file" "SUCCESS" "Backed up to $backup_file"
        log_operation_end "BACKUP_FILE" "SUCCESS" "File backed up successfully"
        COPIED_FILES+=("$backup_file")
        return 0
    else
        print_error "Failed to create backup: $backup_file" "BACKUP"
        log_file_operation "BACKUP" "$file" "FAILED" "Copy operation failed"
        log_operation_end "BACKUP_FILE" "FAILED" "Backup copy operation failed"
        return 1
    fi
}

# Mode 1: Create/overwrite files with backup
mode_1_file_operation() {
    local source="$1"
    local target="$2"
    local operation_type="${3:-copy}"  # copy or write
    
    log_operation_start "MODE_1_OPERATION" "Mode 1: Create/overwrite with backup - $target"
    
    # Create backup if target file exists
    if [ -f "$target" ]; then
        print_info "Creating backup for existing file: $target" "MODE_1"
        if ! create_project_backup "$target"; then
            print_warning "Backup failed, but continuing with operation" "MODE_1"
            log_warning "Backup failed for $target but continuing" "MODE_1"
        fi
    fi
    
    # Perform the file operation
    case "$operation_type" in
        "copy")
            if safe_file_operation "copy" "$source" "$target"; then
                print_success "File created/updated: $target" "MODE_1"
                log_operation_end "MODE_1_OPERATION" "SUCCESS" "File copied successfully"
                return 0
            else
                print_error "Failed to copy file: $source -> $target" "MODE_1"
                log_operation_end "MODE_1_OPERATION" "FAILED" "Copy operation failed"
                return 1
            fi
            ;;
        "write")
            if safe_file_operation "write" "$source" "$target"; then
                print_success "File created/updated: $target" "MODE_1"
                log_operation_end "MODE_1_OPERATION" "SUCCESS" "File written successfully"
                return 0
            else
                print_error "Failed to write file: $target" "MODE_1"
                log_operation_end "MODE_1_OPERATION" "FAILED" "Write operation failed"
                return 1
            fi
            ;;
        *)
            print_error "Unknown operation type: $operation_type" "MODE_1"
            log_operation_end "MODE_1_OPERATION" "FAILED" "Unknown operation type"
            return 1
            ;;
    esac
}

# Mode 2: Only create configuration files without formatting
mode_2_file_operation() {
    local source="$1"
    local target="$2"
    local operation_type="${3:-copy}"
    
    log_operation_start "MODE_2_OPERATION" "Mode 2: Configuration only - $target"
    
    # Check if file is a configuration file (not formatting-related)
    local config_files="phpcs.xml.dist|phpstan.neon.dist|eslint.config.js|package.json|composer.json|wp.code-workspace|.vscode/settings.json|.gitignore|Makefile|bitbucket-pipelines.yml|commitlint.config.cjs|lighthouserc.js"
    
    if [[ "$target" =~ ^($config_files)$ ]] || [[ "$target" =~ \.vscode/ ]]; then
        # This is a configuration file, proceed with creation
        print_info "Creating configuration file: $target" "MODE_2"
        
        # Don't overwrite existing files in mode 2, just skip
        if [ -f "$target" ]; then
            print_warning "Configuration file already exists, skipping: $target" "MODE_2"
            log_operation_end "MODE_2_OPERATION" "SKIPPED" "File already exists"
            return 0
        fi
        
        # Create the file
        case "$operation_type" in
            "copy")
                if safe_file_operation "copy" "$source" "$target"; then
                    print_success "Configuration file created: $target" "MODE_2"
                    log_operation_end "MODE_2_OPERATION" "SUCCESS" "Configuration file created"
                    return 0
                else
                    print_error "Failed to create configuration file: $target" "MODE_2"
                    log_operation_end "MODE_2_OPERATION" "FAILED" "Copy operation failed"
                    return 1
                fi
                ;;
            "write")
                if safe_file_operation "write" "$source" "$target"; then
                    print_success "Configuration file created: $target" "MODE_2"
                    log_operation_end "MODE_2_OPERATION" "SUCCESS" "Configuration file written"
                    return 0
                else
                    print_error "Failed to write configuration file: $target" "MODE_2"
                    log_operation_end "MODE_2_OPERATION" "FAILED" "Write operation failed"
                    return 1
                fi
                ;;
        esac
    else
        # Not a configuration file, skip in mode 2
        print_info "Skipping non-configuration file in mode 2: $target" "MODE_2"
        log_operation_end "MODE_2_OPERATION" "SKIPPED" "Not a configuration file"
        return 0
    fi
}

# Mode 3: Only format using existing configuration
mode_3_file_operation() {
    local source="$1"
    local target="$2"
    local operation_type="${3:-copy}"
    
    log_operation_start "MODE_3_OPERATION" "Mode 3: Format only - $target"
    
    # Mode 3 should not create new configuration files
    # It should only work with existing configuration for formatting
    print_info "Mode 3: Skipping file creation (format-only mode): $target" "MODE_3"
    log_operation_end "MODE_3_OPERATION" "SKIPPED" "Mode 3 does not create files"
    return 0
}

# Mode 4: Intelligently merge JSON files (package.json, composer.json)
mode_4_file_operation() {
    local source="$1"
    local target="$2"
    local operation_type="${3:-copy}"
    
    log_operation_start "MODE_4_OPERATION" "Mode 4: Intelligent merge - $target"
    
    # Check if this is a JSON file that can be merged
    if [[ "$target" == "package.json" ]] || [[ "$target" == "composer.json" ]]; then
        if [ -f "$target" ]; then
            print_info "Merging existing JSON file: $target" "MODE_4"
            
            # Create backup first
            if ! create_project_backup "$target"; then
                print_warning "Backup failed for $target, but continuing" "MODE_4"
            fi
            
            # Perform intelligent merge (this will use existing merge functions)
            if [[ "$target" == "package.json" ]]; then
                # Use existing package.json merge logic
                if merge_package_json_intelligent "$source" "$target"; then
                    print_success "Successfully merged package.json" "MODE_4"
                    log_operation_end "MODE_4_OPERATION" "SUCCESS" "package.json merged"
                    return 0
                else
                    print_error "Failed to merge package.json" "MODE_4"
                    log_operation_end "MODE_4_OPERATION" "FAILED" "package.json merge failed"
                    return 1
                fi
            elif [[ "$target" == "composer.json" ]]; then
                # Use existing composer.json merge logic
                if merge_composer_json_intelligent "$source" "$target"; then
                    print_success "Successfully merged composer.json" "MODE_4"
                    log_operation_end "MODE_4_OPERATION" "SUCCESS" "composer.json merged"
                    return 0
                else
                    print_error "Failed to merge composer.json" "MODE_4"
                    log_operation_end "MODE_4_OPERATION" "FAILED" "composer.json merge failed"
                    return 1
                fi
            fi
        else
            # File doesn't exist, create new one
            print_info "Creating new JSON file: $target" "MODE_4"
            case "$operation_type" in
                "copy")
                    if safe_file_operation "copy" "$source" "$target"; then
                        print_success "JSON file created: $target" "MODE_4"
                        log_operation_end "MODE_4_OPERATION" "SUCCESS" "New JSON file created"
                        return 0
                    fi
                    ;;
                "write")
                    if safe_file_operation "write" "$source" "$target"; then
                        print_success "JSON file created: $target" "MODE_4"
                        log_operation_end "MODE_4_OPERATION" "SUCCESS" "New JSON file written"
                        return 0
                    fi
                    ;;
            esac
            print_error "Failed to create JSON file: $target" "MODE_4"
            log_operation_end "MODE_4_OPERATION" "FAILED" "File creation failed"
            return 1
        fi
    else
        # Non-JSON files: create with backup like mode 1
        print_info "Non-JSON file, using mode 1 behavior: $target" "MODE_4"
        mode_1_file_operation "$source" "$target" "$operation_type"
        return $?
    fi
}

# Main function to perform file operations according to selected mode
perform_mode_specific_file_operation() {
    local source="$1"
    local target="$2"
    local operation_type="${3:-copy}"
    
    # Ensure target path is relative to project root if PROJECT_ROOT is set
    if [ -n "$PROJECT_ROOT" ] && [[ "$target" != /* ]]; then
        # Change to project root for file operations
        local original_dir=$(pwd)
        cd "$PROJECT_ROOT" || {
            print_error "Cannot change to project root: $PROJECT_ROOT"
            return 1
        }
        
        # Perform the operation
        local result=0
        case "$MODE" in
            1)
                mode_1_file_operation "$source" "$target" "$operation_type"
                result=$?
                ;;
            2)
                mode_2_file_operation "$source" "$target" "$operation_type"
                result=$?
                ;;
            3)
                mode_3_file_operation "$source" "$target" "$operation_type"
                result=$?
                ;;
            4)
                mode_4_file_operation "$source" "$target" "$operation_type"
                result=$?
                ;;
            *)
                print_error "Invalid mode: $MODE"
                result=1
                ;;
        esac
        
        # Return to original directory
        cd "$original_dir" || print_warning "Could not return to original directory: $original_dir"
        return $result
    else
        # No project root set or absolute path, perform operation in current directory
        case "$MODE" in
            1)
                mode_1_file_operation "$source" "$target" "$operation_type"
                ;;
            2)
                mode_2_file_operation "$source" "$target" "$operation_type"
                ;;
            3)
                mode_3_file_operation "$source" "$target" "$operation_type"
                ;;
            4)
                mode_4_file_operation "$source" "$target" "$operation_type"
                ;;
            *)
                print_error "Invalid mode: $MODE"
                return 1
                ;;
        esac
    fi
}

# Enhanced backup function with error handling - now uses recovery system
create_backup() {
    local file="$1"
    
    # Delegate to project backup function for consistency
    create_project_backup "$file"
}

# Enhanced file operation with error handling
safe_file_operation() {
    local operation="$1"
    local source="$2"
    local target="$3"
    
    case "$operation" in
        "copy")
            if [ ! -f "$source" ]; then
                print_error "Source file not found: $source"
                log_error "Copy operation failed - source not found: $source"
                FAILED_OPERATIONS+=("copy:$source->$target")
                return 1
            fi
            
            # Create target directory if needed
            local target_dir
            target_dir=$(dirname "$target")
            if [ ! -d "$target_dir" ] && [ "$target_dir" != "." ]; then
                if ! mkdir -p "$target_dir"; then
                    print_error "Failed to create target directory: $target_dir"
                    log_error "Directory creation failed: $target_dir"
                    FAILED_OPERATIONS+=("mkdir:$target_dir")
                    return 1
                fi
                log_info "Created directory: $target_dir"
            fi
            
            # Perform copy operation
            if cp "$source" "$target"; then
                log_success "File copied: $source -> $target"
                COPIED_FILES+=("$target")
                return 0
            else
                print_error "Failed to copy file: $source -> $target"
                log_error "Copy operation failed: $source -> $target"
                FAILED_OPERATIONS+=("copy:$source->$target")
                return 1
            fi
            ;;
        "write")
            # For write operations, source is the content, target is the file
            local content="$source"
            local file="$target"
            
            # Create target directory if needed
            local target_dir
            target_dir=$(dirname "$file")
            if [ ! -d "$target_dir" ] && [ "$target_dir" != "." ]; then
                if ! mkdir -p "$target_dir"; then
                    print_error "Failed to create target directory: $target_dir"
                    log_error "Directory creation failed: $target_dir"
                    FAILED_OPERATIONS+=("mkdir:$target_dir")
                    return 1
                fi
                log_info "Created directory: $target_dir"
            fi
            
            # Write content to file using printf to handle special characters
            if printf '%s' "$content" > "$file"; then
                log_success "File written: $file"
                COPIED_FILES+=("$file")
                return 0
            else
                print_error "Failed to write file: $file"
                log_error "Write operation failed: $file"
                FAILED_OPERATIONS+=("write:$file")
                return 1
            fi
            ;;
        *)
            print_error "Unknown file operation: $operation"
            log_error "Unknown file operation requested: $operation"
            return 1
            ;;
    esac
}

# Enhanced function to display comprehensive operation summary
show_operation_summary() {
    local end_time=$(date '+%Y-%m-%d %H:%M:%S %Z')
    local execution_time=""
    
    # Calculate execution time if start time is available
    if [ -n "$SCRIPT_START_TIME" ]; then
        local start_epoch=$(date -d "$SCRIPT_START_TIME" +%s 2>/dev/null || echo "0")
        local end_epoch=$(date +%s)
        local duration=$((end_epoch - start_epoch))
        execution_time=" (${duration}s)"
    fi
    
    echo ""
    echo "══════════════════════════════════════════════════════════════"
    echo "  📊 Operation Summary"
    echo "══════════════════════════════════════════════════════════════"
    echo ""
    
    # Log summary start
    log_operation_start "SUMMARY_GENERATION" "Generating final operation summary"
    
    # Success metrics including recovery operations
    local success_count=${#COPIED_FILES[@]}
    local failure_count=${#FAILED_OPERATIONS[@]}
    local skipped_count=${#SKIPPED_OPERATIONS[@]}
    local partial_success_count=${#PARTIAL_SUCCESS_OPERATIONS[@]}
    local total_operations=$((success_count + failure_count + skipped_count + partial_success_count))
    
    if [ "$total_operations" -gt 0 ]; then
        local success_rate=$((success_count * 100 / total_operations))
        echo "📈 Success Rate: ${success_rate}% (${success_count}/${total_operations} operations)"
        log_info "Success rate: ${success_rate}% (${success_count}/${total_operations})" "SUMMARY"
        
        # Show recovery statistics if applicable
        if [ "$skipped_count" -gt 0 ] || [ "$partial_success_count" -gt 0 ]; then
            echo "🔄 Recovery Statistics:"
            [ "$skipped_count" -gt 0 ] && echo "   • Skipped operations: $skipped_count"
            [ "$partial_success_count" -gt 0 ] && echo "   • Partial successes: $partial_success_count"
            log_info "Recovery stats - Skipped: $skipped_count, Partial: $partial_success_count" "SUMMARY"
        fi
        echo ""
    fi
    
    # Successful operations
    if [ "$success_count" -gt 0 ]; then
        print_success "Successfully processed ${success_count} file(s)" "SUMMARY"
        
        # Group successful operations by type
        local config_files=0
        local template_files=0
        local backup_files=0
        
        for file in "${COPIED_FILES[@]}"; do
            case "$file" in
                *.xml.dist|*.neon.dist|*.config.js|*.json) ((config_files++)) ;;
                *template*|*.template) ((template_files++)) ;;
                backup-*/*) ((backup_files++)) ;;
            esac
        done
        
        [ "$config_files" -gt 0 ] && echo "  ✅ Configuration files: $config_files"
        [ "$template_files" -gt 0 ] && echo "  ✅ Template files: $template_files"
        [ "$backup_files" -gt 0 ] && echo "  ✅ Backup files: $backup_files"
        echo ""
    fi
    
    # Skipped operations
    if [ "$skipped_count" -gt 0 ]; then
        print_info "Skipped operations: ${skipped_count}" "SUMMARY"
        for skipped in "${SKIPPED_OPERATIONS[@]}"; do
            echo "  ⏭️  $skipped"
        done
        echo ""
    fi
    
    # Partial success operations
    if [ "$partial_success_count" -gt 0 ]; then
        print_warning "Operations completed with warnings: ${partial_success_count}" "SUMMARY"
        for partial in "${PARTIAL_SUCCESS_OPERATIONS[@]}"; do
            echo "  ⚠️  $partial"
        done
        echo ""
    fi
    
    # Failed operations with categorization
    if [ "$failure_count" -gt 0 ]; then
        print_warning "Failed operations: ${failure_count}" "SUMMARY"
        
        # Categorize failures
        local validation_failures=0
        local file_failures=0
        local tool_failures=0
        local permission_failures=0
        
        for failed in "${FAILED_OPERATIONS[@]}"; do
            echo "  ❌ $failed"
            case "$failed" in
                validation:*) ((validation_failures++)) ;;
                copy:*|write:*|backup:*) ((file_failures++)) ;;
                *permission*|*access*) ((permission_failures++)) ;;
                *) ((tool_failures++)) ;;
            esac
        done
        
        echo ""
        echo "  📊 Failure breakdown:"
        [ "$validation_failures" -gt 0 ] && echo "    • Validation errors: $validation_failures"
        [ "$file_failures" -gt 0 ] && echo "    • File operation errors: $file_failures"
        [ "$permission_failures" -gt 0 ] && echo "    • Permission errors: $permission_failures"
        [ "$tool_failures" -gt 0 ] && echo "    • Tool/dependency errors: $tool_failures"
        
        log_warning "Failure breakdown - Validation: $validation_failures, File ops: $file_failures, Permissions: $permission_failures, Tools: $tool_failures" "SUMMARY"
        echo ""
    fi
    
    # Backup information
    if [ -n "$BACKUP_DIR" ] && [ -d "$BACKUP_DIR" ]; then
        local backup_count=$(find "$BACKUP_DIR" -type f 2>/dev/null | wc -l)
        print_info "Backup directory: $BACKUP_DIR ($backup_count files)" "SUMMARY"
        log_info "Backup directory created with $backup_count files: $BACKUP_DIR" "SUMMARY"
    fi
    
    # Component summary
    if [ "$CONFIGURE_PROJECT" = true ]; then
        local total_components=$((${#SELECTED_PLUGINS[@]} + ${#SELECTED_THEMES[@]} + ${#SELECTED_MU_PLUGINS[@]}))
        if [ "$total_components" -gt 0 ]; then
            echo "🧩 Components processed: $total_components"
            [ ${#SELECTED_PLUGINS[@]} -gt 0 ] && echo "  • Plugins: ${#SELECTED_PLUGINS[@]} (${SELECTED_PLUGINS[*]})"
            [ ${#SELECTED_THEMES[@]} -gt 0 ] && echo "  • Themes: ${#SELECTED_THEMES[@]} (${SELECTED_THEMES[*]})"
            [ ${#SELECTED_MU_PLUGINS[@]} -gt 0 ] && echo "  • MU-Plugins: ${#SELECTED_MU_PLUGINS[@]} (${SELECTED_MU_PLUGINS[*]})"
            echo ""
            log_component_action "SUMMARY" "ALL" "PROCESSED" "$total_components components: ${#SELECTED_PLUGINS[@]} plugins, ${#SELECTED_THEMES[@]} themes, ${#SELECTED_MU_PLUGINS[@]} mu-plugins"
        fi
    fi
    
    # Mode information
    local mode_description=""
    case "$MODE" in
        1) mode_description="Configure and format project" ;;
        2) mode_description="Configure only (no formatting)" ;;
        3) mode_description="Format existing code only" ;;
        4) mode_description="Merge configuration (advanced)" ;;
        *) mode_description="Unknown mode" ;;
    esac
    echo "⚙️  Mode: $MODE ($mode_description)"
    log_info "Execution mode: $MODE ($mode_description)" "SUMMARY"
    
    # Execution time and log file
    echo "⏱️  Completed: $end_time$execution_time"
    if [ -n "$LOG_FILE" ] && [ -f "$LOG_FILE" ]; then
        local log_size=$(du -h "$LOG_FILE" 2>/dev/null | cut -f1 || echo "unknown")
        print_info "Detailed log: $LOG_FILE ($log_size)" "SUMMARY"
        
        # Write final summary to log
        cat >> "$LOG_FILE" << LOG_SUMMARY

================================================================================
EXECUTION SUMMARY
================================================================================
End Time: $end_time
Execution Time: ${execution_time#* (}
Mode: $MODE ($mode_description)
Success Rate: ${success_rate:-0}% (${success_count}/${total_operations} operations)
Components Processed: ${total_components:-0}
Backup Directory: ${BACKUP_DIR:-None}
Validation Errors: ${VALIDATION_ERRORS:-0}
================================================================================

LOG_SUMMARY
    fi
    
    log_operation_end "SUMMARY_GENERATION" "SUCCESS" "Summary completed with $success_count successes, $failure_count failures"
}

# ====================================================================
# File Operations Module for Template Adaptation
# ====================================================================

# ====================================================================
# Workspace Generation Module
# ====================================================================

extract_workspace_settings() {
    local template_file="wp.code-workspace"
    
    if [ ! -f "$template_file" ]; then
        print_warning "Template workspace file not found: $template_file"
        # Return enhanced default settings
        echo '  "settings": {
    "editor.rulers": [120],
    "editor.formatOnSave": true,
    "phpsab.snifferMode": "onType",
    "phpsab.snifferShowSources": true,
    "eslint.enable": true,
    "eslint.validate": ["javascript", "javascriptreact", "typescript", "typescriptreact"],
    "stylelint.enable": true,
    "stylelint.validate": ["css", "scss", "sass"],
    "[php]": {
      "editor.formatOnSave": true,
      "editor.defaultFormatter": "valeryanm.vscode-phpsab",
      "editor.codeActionsOnSave": {
        "source.fixAll": "always"
      }
    },
    "[javascript]": {
      "editor.formatOnSave": true,
      "editor.defaultFormatter": "dbaeumer.vscode-eslint",
      "editor.codeActionsOnSave": {
        "source.fixAll.eslint": "always"
      }
    },
    "[javascriptreact]": {
      "editor.formatOnSave": true,
      "editor.defaultFormatter": "dbaeumer.vscode-eslint",
      "editor.codeActionsOnSave": {
        "source.fixAll.eslint": "always"
      }
    },
    "[css]": {
      "editor.formatOnSave": true,
      "editor.defaultFormatter": "stylelint.vscode-stylelint",
      "editor.codeActionsOnSave": {
        "source.fixAll.stylelint": "always"
      }
    },
    "[scss]": {
      "editor.formatOnSave": true,
      "editor.defaultFormatter": "stylelint.vscode-stylelint",
      "editor.codeActionsOnSave": {
        "source.fixAll.stylelint": "always"
      }
    },
    "[json]": {
      "editor.formatOnSave": true,
      "editor.defaultFormatter": "esbenp.prettier-vscode"
    },
    "[markdown]": {
      "editor.formatOnSave": true,
      "editor.defaultFormatter": "esbenp.prettier-vscode"
    }
  }'
        return
    fi
    
    # Extract settings section from template workspace file
    # This preserves all editor settings, extensions, and other configurations
    local settings_section
    settings_section=$(sed -n '/^[[:space:]]*"settings":/,/^[[:space:]]*}[[:space:]]*$/p' "$template_file" | head -n -1)
    
    # If no settings found, extract everything after folders array
    if [ -z "$settings_section" ]; then
        settings_section=$(sed -n '/^[[:space:]]*]/,$ p' "$template_file" | tail -n +2 | head -n -1)
    fi
    
    echo "$settings_section"
}

generate_workspace_file() {
    local workspace_file="wp.code-workspace"
    
    print_info "Generating workspace file: $workspace_file"
    
    # Create backup if file exists
    if [ -f "$workspace_file" ]; then
        create_backup "$workspace_file"
    fi
    
    # Start building workspace content
    local workspace_content='{'
    workspace_content+='\n  "folders": ['
    workspace_content+='\n    {'
    workspace_content+='\n      "path": "."'
    workspace_content+='\n    }'
    
    # Add selected plugin paths
    for plugin in "${SELECTED_PLUGINS[@]}"; do
        if [ -d "$WP_CONTENT_DIR/plugins/$plugin" ]; then
            workspace_content+=',\n    {\n      "path": "'
            workspace_content+="$WP_CONTENT_DIR/plugins/$plugin"
            workspace_content+='"\n    }'
        else
            print_warning "Plugin directory not found: $WP_CONTENT_DIR/plugins/$plugin"
        fi
    done
    
    # Add selected theme paths
    for theme in "${SELECTED_THEMES[@]}"; do
        if [ -d "$WP_CONTENT_DIR/themes/$theme" ]; then
            workspace_content+=',\n    {\n      "path": "'
            workspace_content+="$WP_CONTENT_DIR/themes/$theme"
            workspace_content+='"\n    }'
        else
            print_warning "Theme directory not found: $WP_CONTENT_DIR/themes/$theme"
        fi
    done
    
    # Add selected mu-plugin paths
    for mu_plugin in "${SELECTED_MU_PLUGINS[@]}"; do
        if [ -d "$WP_CONTENT_DIR/mu-plugins/$mu_plugin" ]; then
            workspace_content+=',\n    {\n      "path": "'
            workspace_content+="$WP_CONTENT_DIR/mu-plugins/$mu_plugin"
            workspace_content+='"\n    }'
        else
            print_warning "MU-Plugin directory not found: $WP_CONTENT_DIR/mu-plugins/$mu_plugin"
        fi
    done
    
    # Close folders array
    workspace_content+='\n  ],'
    
    # Add settings from template
    workspace_content+='\n'
    workspace_content+="$(extract_workspace_settings)"
    workspace_content+='\n}'
    
    # Write workspace file
    echo -e "$workspace_content" > "$workspace_file"
    
    print_success "Generated $workspace_file with ${#SELECTED_PLUGINS[@]} plugins, ${#SELECTED_THEMES[@]} themes, ${#SELECTED_MU_PLUGINS[@]} mu-plugins"
}

# ====================================================================
# JavaScript Path Management Module
# ====================================================================

build_js_paths_for_formatting() {
    local -a js_paths=()
    
    # Only include selected components that actually exist
    for plugin in "${SELECTED_PLUGINS[@]}"; do
        if [ -d "$WP_CONTENT_DIR/plugins/$plugin" ]; then
            js_paths+=("$WP_CONTENT_DIR/plugins/$plugin/**/*.{js,jsx,ts,tsx}")
        else
            print_warning "Plugin directory not found: $WP_CONTENT_DIR/plugins/$plugin"
        fi
    done
    
    for theme in "${SELECTED_THEMES[@]}"; do
        if [ -d "$WP_CONTENT_DIR/themes/$theme" ]; then
            js_paths+=("$WP_CONTENT_DIR/themes/$theme/**/*.{js,jsx,ts,tsx}")
        else
            print_warning "Theme directory not found: $WP_CONTENT_DIR/themes/$theme"
        fi
    done
    
    for mu_plugin in "${SELECTED_MU_PLUGINS[@]}"; do
        if [ -d "$WP_CONTENT_DIR/mu-plugins/$mu_plugin" ]; then
            js_paths+=("$WP_CONTENT_DIR/mu-plugins/$mu_plugin/**/*.{js,jsx,ts,tsx}")
        else
            print_warning "MU-Plugin directory not found: $WP_CONTENT_DIR/mu-plugins/$mu_plugin"
        fi
    done
    
    echo "${js_paths[@]}"
}



adapt_template_variables() {
    local source="$1"
    local target="$2"
    
    log_info "Adapting template variables: $source -> $target"
    
    # Validate inputs
    if [ ! -f "$source" ]; then
        log_error "Source template file not found: $source"
        return 1
    fi
    
    if [ -z "$PROJECT_SLUG" ]; then
        log_error "PROJECT_SLUG not set for template adaptation"
        return 1
    fi
    
    # Generate project name from slug (capitalize first letter of each word)
    local project_name
    project_name=$(echo "$PROJECT_SLUG" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1')
    
    # Replace template variables with project-specific values
    if sed -e "s/{{PROJECT_NAME}}/$project_name/g" \
           -e "s/{{PROJECT_SLUG}}/$PROJECT_SLUG/g" \
           -e "s/{{PROJECT_CONSTANT}}/$PROJECT_CONSTANT/g" \
           -e "s|{{WP_CONTENT_DIR}}|$WP_CONTENT_DIR|g" \
           -e "s/MyProject/$PROJECT_SLUG/g" \
           -e "s/my-project/$PROJECT_SLUG/g" \
           -e "s/MY_PROJECT/$PROJECT_CONSTANT/g" \
           -e "s|wordpress/wp-content|$WP_CONTENT_DIR|g" \
           "$source" > "$target"; then
        log_success "Template variables adapted successfully: $target"
        return 0
    else
        log_error "Failed to adapt template variables: $source -> $target"
        return 1
    fi
}

generate_gitignore_from_template() {
    local source="$1"
    local target="$2"
    
    log_info "Generating .gitignore from template: $source"
    
    # Start with template content
    if ! adapt_template_variables "$source" "$target"; then
        log_error "Failed to adapt template variables for .gitignore"
        return 1
    fi
    
    # Add project-specific ignores based on selected components
    if ! {
        echo ""
        echo "# Project-specific ignores for ${PROJECT_SLUG}"
        echo ""
        
        # Plugin-specific ignores
        if [ ${#SELECTED_PLUGINS[@]} -gt 0 ]; then
            echo "# Plugin build and dependency directories"
            for plugin in "${SELECTED_PLUGINS[@]}"; do
                echo "${WP_CONTENT_DIR}/plugins/${plugin}/build/"
                echo "${WP_CONTENT_DIR}/plugins/${plugin}/dist/"
                echo "${WP_CONTENT_DIR}/plugins/${plugin}/node_modules/"
                echo "${WP_CONTENT_DIR}/plugins/${plugin}/vendor/"
                echo "${WP_CONTENT_DIR}/plugins/${plugin}/.eslintcache"
                echo "${WP_CONTENT_DIR}/plugins/${plugin}/.stylelintcache"
            done
            echo ""
        fi
        
        # Theme-specific ignores
        if [ ${#SELECTED_THEMES[@]} -gt 0 ]; then
            echo "# Theme build and dependency directories"
            for theme in "${SELECTED_THEMES[@]}"; do
                echo "${WP_CONTENT_DIR}/themes/${theme}/assets/build/"
                echo "${WP_CONTENT_DIR}/themes/${theme}/assets/dist/"
                echo "${WP_CONTENT_DIR}/themes/${theme}/build/"
                echo "${WP_CONTENT_DIR}/themes/${theme}/dist/"
                echo "${WP_CONTENT_DIR}/themes/${theme}/node_modules/"
                echo "${WP_CONTENT_DIR}/themes/${theme}/vendor/"
                echo "${WP_CONTENT_DIR}/themes/${theme}/.eslintcache"
                echo "${WP_CONTENT_DIR}/themes/${theme}/.stylelintcache"
            done
            echo ""
        fi
        
        # MU-Plugin-specific ignores
        if [ ${#SELECTED_MU_PLUGINS[@]} -gt 0 ]; then
            echo "# MU-Plugin build and dependency directories"
            for mu_plugin in "${SELECTED_MU_PLUGINS[@]}"; do
                echo "${WP_CONTENT_DIR}/mu-plugins/${mu_plugin}/build/"
                echo "${WP_CONTENT_DIR}/mu-plugins/${mu_plugin}/dist/"
                echo "${WP_CONTENT_DIR}/mu-plugins/${mu_plugin}/node_modules/"
                echo "${WP_CONTENT_DIR}/mu-plugins/${mu_plugin}/vendor/"
                echo "${WP_CONTENT_DIR}/mu-plugins/${mu_plugin}/.eslintcache"
                echo "${WP_CONTENT_DIR}/mu-plugins/${mu_plugin}/.stylelintcache"
            done
            echo ""
        fi
        
        # Project-specific backup and temporary files
        echo "# Project-specific temporary files"
        echo "backup-*/"
        echo "${PROJECT_SLUG}-backup-*/"
        echo "*.${PROJECT_SLUG}.tmp"
        echo ".${PROJECT_SLUG}-cache/"
        
    } >> "$target"; then
        log_error "Failed to append project-specific ignores to .gitignore"
        return 1
    fi
    
    log_success "Generated .gitignore with project-specific ignores"
    return 0
}

add_component_build_steps() {
    local target="$1"
    
    log_info "Adding component-specific build steps to pipeline: $target"
    
    if [ ! -f "$target" ]; then
        log_error "Pipeline target file not found: $target"
        return 1
    fi
    
    # Add component-specific build steps to pipeline
    local build_steps=""
    
    # Add theme build steps
    for theme in "${SELECTED_THEMES[@]}"; do
        build_steps+="                  - cd ${WP_CONTENT_DIR}/themes/${theme} && npm ci && npm run build\n"
    done
    
    # Add plugin build steps
    for plugin in "${SELECTED_PLUGINS[@]}"; do
        build_steps+="                  - cd ${WP_CONTENT_DIR}/plugins/${plugin} && npm ci && npm run build\n"
    done
    
    # Add mu-plugin build steps
    for mu_plugin in "${SELECTED_MU_PLUGINS[@]}"; do
        build_steps+="                  - cd ${WP_CONTENT_DIR}/mu-plugins/${mu_plugin} && npm ci && npm run build\n"
    done
    
    if [ -n "$build_steps" ]; then
        # Replace placeholder build steps with actual component builds
        if sed -i.bak "s|cd wordpress/wp-content/themes/my-project-theme && npm ci|${build_steps%\\n}|g" "$target" &&
           sed -i.bak "s|cd ../../../.. && cd wordpress/wp-content/themes/flat101-starter-theme && npm ci||g" "$target" &&
           sed -i.bak "s|cd ../../../.. && cd wordpress/wp-content/plugins/my-project-custom-blocks && npm ci||g" "$target"; then
            rm -f "${target}.bak"
            log_success "Component build steps added to pipeline"
            return 0
        else
            log_error "Failed to update pipeline with component build steps"
            # Restore backup if it exists
            [ -f "${target}.bak" ] && mv "${target}.bak" "$target"
            return 1
        fi
    else
        log_info "No component build steps to add"
        return 0
    fi
}

generate_pipeline_from_template() {
    local source="$1"
    local target="$2"
    
    log_info "Generating pipeline configuration from template: $source"
    
    # Replace project-specific variables in pipeline
    if ! adapt_template_variables "$source" "$target"; then
        log_error "Failed to adapt template variables for pipeline"
        return 1
    fi
    
    # Add component-specific build steps
    if ! add_component_build_steps "$target"; then
        log_warning "Failed to add component build steps to pipeline (continuing anyway)"
        # Don't fail the entire operation for this
    fi
    
    log_success "Generated pipeline configuration"
    return 0
}

generate_lighthouse_config() {
    local source="$1"
    local target="$2"
    
    log_info "Generating Lighthouse configuration from template: $source"
    
    # Generate lighthouse config with project-specific URLs
    local local_url="https://local.${PROJECT_SLUG}.com/"
    local preprod_url="https://dev.${PROJECT_SLUG}.levelstage.com/"
    
    # Replace URLs and project variables
    if ! sed -e "s|https://local.MyProject.com/|$local_url|g" \
             -e "s|https://dev.MyProject.levelstage.com/|$preprod_url|g" \
             -e "s/MyProject/$PROJECT_SLUG/g" \
             -e "s/my-project/$PROJECT_SLUG/g" \
             -e "s|wordpress/wp-content|$WP_CONTENT_DIR|g" \
             "$source" > "$target"; then
        log_error "Failed to generate Lighthouse configuration"
        return 1
    fi
    
    # Add project-specific test URLs if needed
    if ! add_lighthouse_test_urls "$target"; then
        log_warning "Failed to add test URLs to Lighthouse config (continuing anyway)"
        # Don't fail the entire operation for this
    fi
    
    log_success "Generated Lighthouse configuration"
    return 0
}

add_lighthouse_test_urls() {
    local target="$1"
    
    log_info "Adding test URLs to Lighthouse configuration: $target"
    
    if [ ! -f "$target" ]; then
        log_error "Lighthouse target file not found: $target"
        return 1
    fi
    
    # Add common WordPress pages for testing
    local additional_urls=""
    additional_urls+=", 'https://local.${PROJECT_SLUG}.com/about/'"
    additional_urls+=", 'https://local.${PROJECT_SLUG}.com/contact/'"
    additional_urls+=", 'https://local.${PROJECT_SLUG}.com/blog/'"
    
    # Replace the URL array to include additional test URLs
    if sed -i.bak "s|'https://local.${PROJECT_SLUG}.com/'|'https://local.${PROJECT_SLUG}.com/'${additional_urls}|g" "$target"; then
        rm -f "${target}.bak"
        log_success "Test URLs added to Lighthouse configuration"
        return 0
    else
        log_error "Failed to add test URLs to Lighthouse configuration"
        # Restore backup if it exists
        [ -f "${target}.bak" ] && mv "${target}.bak" "$target"
        return 1
    fi
}

generate_component_targets() {
    local component_type="$1"  # "dev", "build", "lint", "format", etc.
    local components_array_name="$2"  # "SELECTED_PLUGINS", "SELECTED_THEMES", etc.
    local component_dir="$3"  # "plugins", "themes", "mu-plugins"
    local icon="$4"  # "🧩", "🎨", "🔌"
    
    # Use nameref to access the array
    local -n components_ref=$components_array_name
    local targets=""
    
    for component in "${components_ref[@]}"; do
        case "$component_type" in
            "dev")
                targets+="dev-${component}: ## ${icon} Development for ${component} ${component_dir%s}\n"
                targets+="\t@echo \"${icon} Starting ${component} ${component_dir%s} development...\"\n"
                targets+="\t@cd \$(WP_CONTENT_DIR)/${component_dir}/${component} && npm run dev 2>/dev/null || echo \"⚠️  npm dev not available\"\n\n"
                ;;
            "build")
                targets+="build-${component}: ## 📦 Build ${component} ${component_dir%s} assets\n"
                targets+="\t@echo \"📦 Building ${component} ${component_dir%s} assets...\"\n"
                targets+="\t@cd \$(WP_CONTENT_DIR)/${component_dir}/${component} && npm run build 2>/dev/null || echo \"⚠️  npm build not available\"\n\n"
                ;;
            "lint")
                targets+="lint-${component}: ## 🔍 Lint ${component} ${component_dir%s}\n"
                targets+="\t@echo \"🔍 Linting ${component} ${component_dir%s}...\"\n"
                targets+="\t@cd \$(WP_CONTENT_DIR)/${component_dir}/${component} && npm run lint 2>/dev/null || echo \"⚠️  npm lint not available\"\n"
                targets+="\t@./vendor/bin/phpcs --standard=phpcs.xml.dist \$(WP_CONTENT_DIR)/${component_dir}/${component} 2>/dev/null || echo \"⚠️  PHPCS not available\"\n\n"
                ;;
            "format")
                targets+="format-${component}: ## 💅 Format ${component} ${component_dir%s}\n"
                targets+="\t@echo \"💅 Formatting ${component} ${component_dir%s}...\"\n"
                targets+="\t@cd \$(WP_CONTENT_DIR)/${component_dir}/${component} && npm run lint:fix 2>/dev/null || echo \"⚠️  npm lint:fix not available\"\n"
                targets+="\t@./vendor/bin/phpcbf --standard=phpcs.xml.dist \$(WP_CONTENT_DIR)/${component_dir}/${component} 2>/dev/null || echo \"⚠️  PHPCBF not available\"\n\n"
                ;;
            "debug")
                targets+="debug-${component}: ## 🐛 Debug ${component} ${component_dir%s}\n"
                targets+="\t@echo \"🐛 Debugging ${component} ${component_dir%s}...\"\n"
                targets+="\t@echo \"📁 Checking structure:\"\n"
                targets+="\t@ls -la \$(WP_CONTENT_DIR)/${component_dir}/${component}/ | head -10\n"
                targets+="\t@echo \"\\n📦 Checking assets:\"\n"
                targets+="\t@ls -la \$(WP_CONTENT_DIR)/${component_dir}/${component}/build/ 2>/dev/null || echo \"Build directory not found\"\n"
                targets+="\t@ls -la \$(WP_CONTENT_DIR)/${component_dir}/${component}/assets/build/ 2>/dev/null || echo \"Assets build directory not found\"\n\n"
                ;;
            "install")
                targets+="\t@echo \"📦 Installing ${component} ${component_dir%s} dependencies...\"\n"
                targets+="\t@cd \$(WP_CONTENT_DIR)/${component_dir}/${component} && npm install 2>/dev/null || echo \"⚠️  npm install failed for ${component}\"\n"
                targets+="\t@cd \$(WP_CONTENT_DIR)/${component_dir}/${component} && composer install 2>/dev/null || echo \"⚠️  composer install failed for ${component}\"\n"
                ;;
            "update")
                targets+="\t@echo \"⬆️ Updating ${component} ${component_dir%s} dependencies...\"\n"
                targets+="\t@cd \$(WP_CONTENT_DIR)/${component_dir}/${component} && npm update 2>/dev/null || echo \"⚠️  npm update failed for ${component}\"\n"
                targets+="\t@cd \$(WP_CONTENT_DIR)/${component_dir}/${component} && composer update 2>/dev/null || echo \"⚠️  composer update failed for ${component}\"\n"
                ;;
            "clean")
                targets+="\t@echo \"🧹 Cleaning ${component} ${component_dir%s} cache...\"\n"
                targets+="\t@rm -rf \$(WP_CONTENT_DIR)/${component_dir}/${component}/node_modules/.cache 2>/dev/null || true\n"
                targets+="\t@rm -rf \$(WP_CONTENT_DIR)/${component_dir}/${component}/.eslintcache 2>/dev/null || true\n"
                ;;
            "status")
                targets+="\t@test -d \$(WP_CONTENT_DIR)/${component_dir}/${component}/node_modules && echo \"  ✅ ${component} dependencies installed\" || echo \"  ❌ ${component} dependencies missing\"\n"
                targets+="\t@test -d \$(WP_CONTENT_DIR)/${component_dir}/${component}/vendor && echo \"  ✅ ${component} composer dependencies installed\" || echo \"  ❌ ${component} composer dependencies missing\"\n"
                ;;
            "dev-all")
                targets+="\t@cd \$(WP_CONTENT_DIR)/${component_dir}/${component} && npm run dev 2>/dev/null &\n"
                ;;
            "build-all")
                targets+="\t@cd \$(WP_CONTENT_DIR)/${component_dir}/${component} && npm run build 2>/dev/null || echo \"⚠️  Build failed for ${component}\"\n"
                ;;
            "help")
                targets+="\t@echo \"  dev-${component}     - ${icon} Development for ${component}\"\n"
                targets+="\t@echo \"  build-${component}   - 📦 Build ${component} assets\"\n"
                targets+="\t@echo \"  lint-${component}    - 🔍 Lint ${component} code\"\n"
                targets+="\t@echo \"  format-${component}  - 💅 Format ${component} code\"\n"
                targets+="\t@echo \"  debug-${component}   - 🐛 Debug ${component} issues\"\n"
                ;;
        esac
    done
    
    echo -e "$targets"
}

add_makefile_component_targets() {
    local target="$1"
    
    log_info "Adding component-specific targets to Makefile"
    
    # Generate .PHONY targets for all components
    local phony_targets=""
    for plugin in "${SELECTED_PLUGINS[@]}"; do
        phony_targets+=".PHONY: dev-${plugin} build-${plugin} lint-${plugin} format-${plugin} debug-${plugin}\n"
    done
    for theme in "${SELECTED_THEMES[@]}"; do
        phony_targets+=".PHONY: dev-${theme} build-${theme} lint-${theme} format-${theme} debug-${theme}\n"
    done
    for mu_plugin in "${SELECTED_MU_PLUGINS[@]}"; do
        phony_targets+=".PHONY: dev-${mu_plugin} build-${mu_plugin} lint-${mu_plugin} format-${mu_plugin} debug-${mu_plugin}\n"
    done
    
    # Generate help targets
    local help_targets=""
    if [ ${#SELECTED_PLUGINS[@]} -gt 0 ]; then
        help_targets+="$(generate_component_targets "help" "SELECTED_PLUGINS" "plugins" "🧩")"
    fi
    if [ ${#SELECTED_THEMES[@]} -gt 0 ]; then
        help_targets+="$(generate_component_targets "help" "SELECTED_THEMES" "themes" "🎨")"
    fi
    if [ ${#SELECTED_MU_PLUGINS[@]} -gt 0 ]; then
        help_targets+="$(generate_component_targets "help" "SELECTED_MU_PLUGINS" "mu-plugins" "🔌")"
    fi
    
    # Generate install targets
    local install_targets=""
    if [ ${#SELECTED_PLUGINS[@]} -gt 0 ]; then
        install_targets+="$(generate_component_targets "install" "SELECTED_PLUGINS" "plugins" "🧩")"
    fi
    if [ ${#SELECTED_THEMES[@]} -gt 0 ]; then
        install_targets+="$(generate_component_targets "install" "SELECTED_THEMES" "themes" "🎨")"
    fi
    if [ ${#SELECTED_MU_PLUGINS[@]} -gt 0 ]; then
        install_targets+="$(generate_component_targets "install" "SELECTED_MU_PLUGINS" "mu-plugins" "🔌")"
    fi
    
    # Generate update targets
    local update_targets=""
    if [ ${#SELECTED_PLUGINS[@]} -gt 0 ]; then
        update_targets+="$(generate_component_targets "update" "SELECTED_PLUGINS" "plugins" "🧩")"
    fi
    if [ ${#SELECTED_THEMES[@]} -gt 0 ]; then
        update_targets+="$(generate_component_targets "update" "SELECTED_THEMES" "themes" "🎨")"
    fi
    if [ ${#SELECTED_MU_PLUGINS[@]} -gt 0 ]; then
        update_targets+="$(generate_component_targets "update" "SELECTED_MU_PLUGINS" "mu-plugins" "🔌")"
    fi
    
    # Generate dev-all and build-all targets
    local dev_all_targets=""
    local build_all_targets=""
    if [ ${#SELECTED_PLUGINS[@]} -gt 0 ]; then
        dev_all_targets+="$(generate_component_targets "dev-all" "SELECTED_PLUGINS" "plugins" "🧩")"
        build_all_targets+="$(generate_component_targets "build-all" "SELECTED_PLUGINS" "plugins" "🧩")"
    fi
    if [ ${#SELECTED_THEMES[@]} -gt 0 ]; then
        dev_all_targets+="$(generate_component_targets "dev-all" "SELECTED_THEMES" "themes" "🎨")"
        build_all_targets+="$(generate_component_targets "build-all" "SELECTED_THEMES" "themes" "🎨")"
    fi
    if [ ${#SELECTED_MU_PLUGINS[@]} -gt 0 ]; then
        dev_all_targets+="$(generate_component_targets "dev-all" "SELECTED_MU_PLUGINS" "mu-plugins" "🔌")"
        build_all_targets+="$(generate_component_targets "build-all" "SELECTED_MU_PLUGINS" "mu-plugins" "🔌")"
    fi
    
    # Generate individual component targets
    local component_dev_targets=""
    local component_build_targets=""
    local component_format_targets=""
    local component_lint_targets=""
    local component_debug_targets=""
    local component_clean_targets=""
    local component_status_targets=""
    
    if [ ${#SELECTED_PLUGINS[@]} -gt 0 ]; then
        component_dev_targets+="$(generate_component_targets "dev" "SELECTED_PLUGINS" "plugins" "🧩")"
        component_build_targets+="$(generate_component_targets "build" "SELECTED_PLUGINS" "plugins" "🧩")"
        component_format_targets+="$(generate_component_targets "format" "SELECTED_PLUGINS" "plugins" "🧩")"
        component_lint_targets+="$(generate_component_targets "lint" "SELECTED_PLUGINS" "plugins" "🧩")"
        component_debug_targets+="$(generate_component_targets "debug" "SELECTED_PLUGINS" "plugins" "🧩")"
        component_clean_targets+="$(generate_component_targets "clean" "SELECTED_PLUGINS" "plugins" "🧩")"
        component_status_targets+="$(generate_component_targets "status" "SELECTED_PLUGINS" "plugins" "🧩")"
    fi
    
    if [ ${#SELECTED_THEMES[@]} -gt 0 ]; then
        component_dev_targets+="$(generate_component_targets "dev" "SELECTED_THEMES" "themes" "🎨")"
        component_build_targets+="$(generate_component_targets "build" "SELECTED_THEMES" "themes" "🎨")"
        component_format_targets+="$(generate_component_targets "format" "SELECTED_THEMES" "themes" "🎨")"
        component_lint_targets+="$(generate_component_targets "lint" "SELECTED_THEMES" "themes" "🎨")"
        component_debug_targets+="$(generate_component_targets "debug" "SELECTED_THEMES" "themes" "🎨")"
        component_clean_targets+="$(generate_component_targets "clean" "SELECTED_THEMES" "themes" "🎨")"
        component_status_targets+="$(generate_component_targets "status" "SELECTED_THEMES" "themes" "🎨")"
    fi
    
    if [ ${#SELECTED_MU_PLUGINS[@]} -gt 0 ]; then
        component_dev_targets+="$(generate_component_targets "dev" "SELECTED_MU_PLUGINS" "mu-plugins" "🔌")"
        component_build_targets+="$(generate_component_targets "build" "SELECTED_MU_PLUGINS" "mu-plugins" "🔌")"
        component_format_targets+="$(generate_component_targets "format" "SELECTED_MU_PLUGINS" "mu-plugins" "🔌")"
        component_lint_targets+="$(generate_component_targets "lint" "SELECTED_MU_PLUGINS" "mu-plugins" "🔌")"
        component_debug_targets+="$(generate_component_targets "debug" "SELECTED_MU_PLUGINS" "mu-plugins" "🔌")"
        component_clean_targets+="$(generate_component_targets "clean" "SELECTED_MU_PLUGINS" "mu-plugins" "🔌")"
        component_status_targets+="$(generate_component_targets "status" "SELECTED_MU_PLUGINS" "mu-plugins" "🔌")"
    fi
    
    # Replace placeholders in the Makefile
    sed -i.bak \
        -e "s|{{COMPONENT_PHONY_TARGETS}}|${phony_targets}|g" \
        -e "s|{{COMPONENT_HELP_TARGETS}}|${help_targets}|g" \
        -e "s|{{COMPONENT_INSTALL_TARGETS}}|${install_targets}|g" \
        -e "s|{{COMPONENT_UPDATE_TARGETS}}|${update_targets}|g" \
        -e "s|{{COMPONENT_DEV_ALL_TARGETS}}|${dev_all_targets}|g" \
        -e "s|{{COMPONENT_BUILD_ALL_TARGETS}}|${build_all_targets}|g" \
        -e "s|{{COMPONENT_DEV_TARGETS}}|${component_dev_targets}|g" \
        -e "s|{{COMPONENT_BUILD_TARGETS}}|${component_build_targets}|g" \
        -e "s|{{COMPONENT_FORMAT_TARGETS}}|${component_format_targets}|g" \
        -e "s|{{COMPONENT_LINT_TARGETS}}|${component_lint_targets}|g" \
        -e "s|{{COMPONENT_FORMAT_INDIVIDUAL_TARGETS}}|${component_format_targets}|g" \
        -e "s|{{COMPONENT_LINT_INDIVIDUAL_TARGETS}}|${component_lint_targets}|g" \
        -e "s|{{COMPONENT_DEBUG_TARGETS}}|${component_debug_targets}|g" \
        -e "s|{{COMPONENT_CLEAN_TARGETS}}|${component_clean_targets}|g" \
        -e "s|{{COMPONENT_STATUS_TARGETS}}|${component_status_targets}|g" \
        "$target"
    
    # Remove backup file
    rm -f "${target}.bak"
    
    log_success "Component targets added to Makefile"
    return 0
}

generate_makefile_from_template() {
    local source="$1"
    local target="$2"
    
    log_info "Generating Makefile from template: $source"
    
    # First, replace basic project variables
    if ! adapt_template_variables "$source" "$target"; then
        log_error "Failed to adapt template variables for Makefile"
        return 1
    fi
    
    # Add component-specific targets by replacing placeholders
    if ! add_makefile_component_targets "$target"; then
        log_warning "Failed to add component targets to Makefile (continuing anyway)"
        # Don't fail the entire operation for this
    fi
    
    log_success "Generated Makefile with dynamic component targets"
    return 0
}

# ====================================================================
# JSON Merge Functions for Mode 4
# ====================================================================

# Intelligent merge function for package.json (used by mode 4)
merge_package_json_intelligent() {
    local new_content="$1"  # Content to merge (from source)
    local target_file="$2"  # Target file path
    
    log_operation_start "MERGE_PACKAGE_JSON_INTELLIGENT" "Intelligent merge for $target_file"
    
    if [ ! -f "$target_file" ]; then
        print_error "Target file not found for merge: $target_file"
        log_operation_end "MERGE_PACKAGE_JSON_INTELLIGENT" "FAILED" "Target file not found"
        return 1
    fi
    
    # Create temporary file with new content
    local temp_new_file="/tmp/new_package_$$.json"
    echo "$new_content" > "$temp_new_file"
    
    # Validate new content is valid JSON
    if ! jq empty "$temp_new_file" 2>/dev/null; then
        print_error "New package.json content is not valid JSON"
        rm -f "$temp_new_file"
        log_operation_end "MERGE_PACKAGE_JSON_INTELLIGENT" "FAILED" "Invalid JSON content"
        return 1
    fi
    
    # Perform intelligent merge using jq
    local temp_merged="/tmp/merged_package_$$.json"
    if jq -s '.[0] * .[1] | 
        .scripts = (.[0].scripts // {}) * (.[1].scripts // {}) |
        .dependencies = (.[0].dependencies // {}) * (.[1].dependencies // {}) |
        .devDependencies = (.[0].devDependencies // {}) * (.[1].devDependencies // {})' \
        "$target_file" "$temp_new_file" > "$temp_merged" 2>/dev/null; then
        
        # Validate merged result
        if jq empty "$temp_merged" 2>/dev/null; then
            if mv "$temp_merged" "$target_file"; then
                print_success "package.json merged intelligently"
                log_operation_end "MERGE_PACKAGE_JSON_INTELLIGENT" "SUCCESS" "Intelligent merge completed"
                rm -f "$temp_new_file"
                return 0
            else
                print_error "Failed to replace package.json with merged version"
                log_operation_end "MERGE_PACKAGE_JSON_INTELLIGENT" "FAILED" "File replacement failed"
                rm -f "$temp_new_file" "$temp_merged"
                return 1
            fi
        else
            print_error "Merged package.json is invalid JSON"
            log_operation_end "MERGE_PACKAGE_JSON_INTELLIGENT" "FAILED" "Merged result invalid"
            rm -f "$temp_new_file" "$temp_merged"
            return 1
        fi
    else
        print_error "jq merge operation failed for package.json"
        log_operation_end "MERGE_PACKAGE_JSON_INTELLIGENT" "FAILED" "jq merge failed"
        rm -f "$temp_new_file" "$temp_merged"
        return 1
    fi
}

# Intelligent merge function for composer.json (used by mode 4)
merge_composer_json_intelligent() {
    local new_content="$1"  # Content to merge (from source)
    local target_file="$2"  # Target file path
    
    log_operation_start "MERGE_COMPOSER_JSON_INTELLIGENT" "Intelligent merge for $target_file"
    
    if [ ! -f "$target_file" ]; then
        print_error "Target file not found for merge: $target_file"
        log_operation_end "MERGE_COMPOSER_JSON_INTELLIGENT" "FAILED" "Target file not found"
        return 1
    fi
    
    # Create temporary file with new content
    local temp_new_file="/tmp/new_composer_$$.json"
    echo "$new_content" > "$temp_new_file"
    
    # Validate new content is valid JSON
    if ! jq empty "$temp_new_file" 2>/dev/null; then
        print_error "New composer.json content is not valid JSON"
        rm -f "$temp_new_file"
        log_operation_end "MERGE_COMPOSER_JSON_INTELLIGENT" "FAILED" "Invalid JSON content"
        return 1
    fi
    
    # Perform intelligent merge using jq
    local temp_merged="/tmp/merged_composer_$$.json"
    if jq -s '.[0] * .[1] | 
        .require = (.[0].require // {}) * (.[1].require // {}) |
        ."require-dev" = (.[0]."require-dev" // {}) * (.[1]."require-dev" // {}) |
        .scripts = (.[0].scripts // {}) * (.[1].scripts // {}) |
        .autoload = (.[0].autoload // {}) * (.[1].autoload // {})' \
        "$target_file" "$temp_new_file" > "$temp_merged" 2>/dev/null; then
        
        # Validate merged result
        if jq empty "$temp_merged" 2>/dev/null; then
            if mv "$temp_merged" "$target_file"; then
                print_success "composer.json merged intelligently"
                log_operation_end "MERGE_COMPOSER_JSON_INTELLIGENT" "SUCCESS" "Intelligent merge completed"
                rm -f "$temp_new_file"
                return 0
            else
                print_error "Failed to replace composer.json with merged version"
                log_operation_end "MERGE_COMPOSER_JSON_INTELLIGENT" "FAILED" "File replacement failed"
                rm -f "$temp_new_file" "$temp_merged"
                return 1
            fi
        else
            print_error "Merged composer.json is invalid JSON"
            log_operation_end "MERGE_COMPOSER_JSON_INTELLIGENT" "FAILED" "Merged result invalid"
            rm -f "$temp_new_file" "$temp_merged"
            return 1
        fi
    else
        print_error "jq merge operation failed for composer.json"
        log_operation_end "MERGE_COMPOSER_JSON_INTELLIGENT" "FAILED" "jq merge failed"
        rm -f "$temp_new_file" "$temp_merged"
        return 1
    fi
}

merge_package_json() {
    local existing_file="package.json"
    local temp_file="package.json.tmp"
    
    # Create recovery point before merge operation
    if command -v create_recovery_point >/dev/null 2>&1 && is_recovery_enabled; then
        local recovery_point_id
        recovery_point_id=$(create_recovery_point "merge_package_json" "Before merging package.json" "$existing_file")
        if [ -n "$recovery_point_id" ]; then
            log_info "Recovery point created before package.json merge: $recovery_point_id" "RECOVERY"
        fi
    fi
    
    log_info "Starting package.json merge process"
    
    if [ ! -f "$existing_file" ]; then
        print_error "package.json not found for merging"
        log_error "package.json merge failed - file not found"
        return 1
    fi
    
    # Create backup
    if ! create_backup "$existing_file"; then
        print_error "Failed to backup package.json"
        log_error "package.json backup failed"
        return 1
    fi
    
    # Define the linting devDependencies to merge
    local linting_deps='{
        "@eslint/js": "^9.9.0",
        "eslint": "^9.9.0",
        "globals": "^15.9.0"
    }'
    
    # Define the linting scripts to merge
    local linting_scripts='{
        "lint:js": "eslint '\''**/*.{js,jsx,ts,tsx}'\''",
        "lint:js:fix": "eslint --fix '\''**/*.{js,jsx,ts,tsx}'\''",
        "lint:php": "./vendor/bin/phpcs --standard=phpcs.xml.dist",
        "lint:php:fix": "./vendor/bin/phpcbf --standard=phpcs.xml.dist",
        "lint": "npm run lint:js && npm run lint:php",
        "format": "npm run lint:js:fix && npm run lint:php:fix"
    }'
    
    # Merge devDependencies and scripts using jq
    if jq --argjson linting_deps "$linting_deps" \
          --argjson linting_scripts "$linting_scripts" \
          '.devDependencies = (.devDependencies // {}) + $linting_deps | 
           .scripts = (.scripts // {}) + $linting_scripts |
           .type = "module"' \
          "$existing_file" > "$temp_file"; then
        
        # Validate the resulting JSON
        if jq empty "$temp_file" 2>/dev/null; then
            if mv "$temp_file" "$existing_file"; then
                print_success "package.json merged successfully"
                log_success "package.json merge completed"
                return 0
            else
                print_error "Failed to replace package.json with merged version"
                log_error "package.json replacement failed"
                rm -f "$temp_file"
                return 1
            fi
        else
            print_error "Merged package.json is invalid JSON"
            log_error "package.json merge produced invalid JSON"
            rm -f "$temp_file"
            return 1
        fi
    else
        print_error "Failed to merge package.json with jq"
        log_error "jq merge operation failed for package.json"
        rm -f "$temp_file"
        return 1
    fi
}

merge_composer_json() {
    local existing_file="composer.json"
    local temp_file="composer.json.tmp"
    
    # Create recovery point before merge operation
    if command -v create_recovery_point >/dev/null 2>&1 && is_recovery_enabled; then
        local recovery_point_id
        recovery_point_id=$(create_recovery_point "merge_composer_json" "Before merging composer.json" "$existing_file")
        if [ -n "$recovery_point_id" ]; then
            log_info "Recovery point created before composer.json merge: $recovery_point_id" "RECOVERY"
        fi
    fi
    
    log_info "Starting composer.json merge process"
    
    if [ ! -f "$existing_file" ]; then
        print_error "composer.json not found for merging"
        log_error "composer.json merge failed - file not found"
        return 1
    fi
    
    # Create backup
    if ! create_backup "$existing_file"; then
        print_error "Failed to backup composer.json"
        log_error "composer.json backup failed"
        return 1
    fi
    
    # Define the linting require-dev dependencies to merge
    local linting_deps='{
        "dealerdirect/phpcodesniffer-composer-installer": "^1.0",
        "phpcompatibility/php-compatibility": "^9.3",
        "phpstan/phpstan": "^1.11",
        "wp-coding-standards/wpcs": "^3.1"
    }'
    
    # Define the linting scripts to merge
    local linting_scripts='{
        "lint": "phpcs --standard=phpcs.xml.dist",
        "lint:fix": "phpcbf --standard=phpcs.xml.dist",
        "analyze": "phpstan analyze"
    }'
    
    # Define config for plugins
    local plugin_config='{
        "allow-plugins": {
            "dealerdirect/phpcodesniffer-composer-installer": true
        }
    }'
    
    # Merge require-dev, scripts, and config using jq
    if jq --argjson linting_deps "$linting_deps" \
          --argjson linting_scripts "$linting_scripts" \
          --argjson plugin_config "$plugin_config" \
          '."require-dev" = (."require-dev" // {}) + $linting_deps | 
           .scripts = (.scripts // {}) + $linting_scripts |
           .config = (.config // {}) + $plugin_config' \
          "$existing_file" > "$temp_file"; then
        
        # Validate the resulting JSON
        if jq empty "$temp_file" 2>/dev/null; then
            if mv "$temp_file" "$existing_file"; then
                print_success "composer.json merged successfully"
                log_success "composer.json merge completed"
                return 0
            else
                print_error "Failed to replace composer.json with merged version"
                log_error "composer.json replacement failed"
                rm -f "$temp_file"
                return 1
            fi
        else
            print_error "Merged composer.json is invalid JSON"
            log_error "composer.json merge produced invalid JSON"
            rm -f "$temp_file"
            return 1
        fi
    else
        print_error "Failed to merge composer.json with jq"
        log_error "jq merge operation failed for composer.json"
        rm -f "$temp_file"
        return 1
    fi
}

rollback_merge_operation() {
    local operation_type="$1"
    
    print_warning "Rolling back $operation_type merge operation..."
    log_warning "Starting rollback for $operation_type"
    
    local rollback_success=true
    
    # Restore files from backup
    if [ -n "$BACKUP_DIR" ] && [ -d "$BACKUP_DIR" ]; then
        case "$operation_type" in
            "package.json")
                if [ -f "$BACKUP_DIR/package.json" ]; then
                    if cp "$BACKUP_DIR/package.json" "package.json"; then
                        print_info "package.json restored from backup"
                        log_success "package.json rollback successful"
                    else
                        print_error "Failed to restore package.json from backup"
                        log_error "package.json rollback failed"
                        rollback_success=false
                    fi
                else
                    print_warning "No package.json backup found"
                    log_warning "package.json backup not found for rollback"
                fi
                ;;
            "composer.json")
                if [ -f "$BACKUP_DIR/composer.json" ]; then
                    if cp "$BACKUP_DIR/composer.json" "composer.json"; then
                        print_info "composer.json restored from backup"
                        log_success "composer.json rollback successful"
                    else
                        print_error "Failed to restore composer.json from backup"
                        log_error "composer.json rollback failed"
                        rollback_success=false
                    fi
                else
                    print_warning "No composer.json backup found"
                    log_warning "composer.json backup not found for rollback"
                fi
                ;;
            "all")
                # Rollback both files
                rollback_merge_operation "package.json"
                rollback_merge_operation "composer.json"
                return $?
                ;;
        esac
    else
        print_error "No backup directory found for rollback"
        log_error "Backup directory not available for rollback"
        rollback_success=false
    fi
    
    if [ "$rollback_success" = true ]; then
        print_success "Rollback completed successfully"
        log_success "Rollback operation completed"
        return 0
    else
        print_error "Rollback failed - manual intervention may be required"
        log_error "Rollback operation failed"
        return 1
    fi
}

generate_adapted_file() {
    local source="$1"
    local target="$2"
    
    log_info "Processing template file: $source -> $target"
    
    if [ ! -f "$source" ]; then
        # Check if this is an optional template that we can skip
        local is_optional=false
        for optional_template in "${MISSING_OPTIONAL_TEMPLATES[@]}"; do
            if [ "$source" = "$optional_template" ]; then
                is_optional=true
                break
            fi
        done
        
        if [ "$is_optional" = true ]; then
            print_info "Skipping optional template: $source (not found)"
            log_info "Optional template skipped: $source"
            return 0  # Success - we're intentionally skipping this
        else
            print_error "Required template file $source not found"
            log_error "Required template file not found: $source"
            FAILED_OPERATIONS+=("template_missing:$source")
            return 1
        fi
    fi
    
    # Create backup if target exists
    if [ -f "$target" ]; then
        if ! create_backup "$target"; then
            print_warning "Failed to backup $target, continuing anyway..."
            log_warning "Backup failed for $target but continuing"
        fi
    fi
    
    # Adapt file content based on project configuration
    local success=true
    case "$source" in
        ".gitignore.template")
            if ! generate_gitignore_from_template "$source" "$target"; then
                success=false
            fi
            ;;
        "bitbucket-pipelines.yml.template")
            if ! generate_pipeline_from_template "$source" "$target"; then
                success=false
            fi
            ;;
        "lighthouserc.js.template")
            if ! generate_lighthouse_config "$source" "$target"; then
                success=false
            fi
            ;;
        "Makefile.template")
            if ! generate_makefile_from_template "$source" "$target"; then
                success=false
            fi
            ;;
        *)
            # For files that need simple variable replacement
            if ! adapt_template_variables "$source" "$target"; then
                success=false
            fi
            ;;
    esac
    
    if [ "$success" = true ]; then
        print_success "Generated $target from $source template"
        log_success "Template processed successfully: $source -> $target"
        COPIED_FILES+=("$target")
        return 0
    else
        print_error "Failed to generate $target from $source template"
        log_error "Template processing failed: $source -> $target"
        FAILED_OPERATIONS+=("template_generation:$source->$target")
        return 1
    fi
}

generate_project_files() {
    # Build template files array dynamically based on what exists
    local template_files=()
    
    # Always try to process .gitignore.template (required) - use INIT_SCRIPT_DIR to find template
    template_files+=("$INIT_SCRIPT_DIR/.gitignore.template:.gitignore")
    
    # Add optional templates only if they exist - use INIT_SCRIPT_DIR to find templates
    [ -f "$INIT_SCRIPT_DIR/bitbucket-pipelines.yml.template" ] && template_files+=("$INIT_SCRIPT_DIR/bitbucket-pipelines.yml.template:bitbucket-pipelines.yml")
    [ -f "$INIT_SCRIPT_DIR/commitlint.config.cjs.template" ] && template_files+=("$INIT_SCRIPT_DIR/commitlint.config.cjs.template:commitlint.config.cjs")
    [ -f "$INIT_SCRIPT_DIR/lighthouserc.js.template" ] && template_files+=("$INIT_SCRIPT_DIR/lighthouserc.js.template:lighthouserc.js")
    [ -f "$INIT_SCRIPT_DIR/Makefile.template" ] && template_files+=("$INIT_SCRIPT_DIR/Makefile.template:Makefile")
    [ -f "$INIT_SCRIPT_DIR/verify-template.sh" ] && template_files+=("$INIT_SCRIPT_DIR/verify-template.sh:verify-project.sh")
    
    print_info "Generating project files from templates..."
    log_info "Starting template file generation process"
    echo ""
    
    local total_files=${#template_files[@]}
    local current_file=0
    local successful_files=0
    local failed_files=0
    
    for file_mapping in "${template_files[@]}"; do
        local source="${file_mapping%:*}"
        local target="${file_mapping#*:}"
        
        ((current_file++))
        show_progress "$current_file" "$total_files" "Processing $source"
        
        if generate_adapted_file "$source" "$target"; then
            ((successful_files++))
        else
            ((failed_files++))
        fi
    done
    
    echo ""
    
    if [ "$failed_files" -eq 0 ]; then
        print_success "All $successful_files template files processed successfully"
        log_success "Template file generation completed: $successful_files/$total_files successful"
    elif [ "$successful_files" -gt 0 ]; then
        print_warning "$successful_files/$total_files template files processed ($failed_files failed)"
        log_warning "Template file generation completed with errors: $successful_files/$total_files successful"
    else
        print_error "All template file operations failed"
        log_error "Template file generation failed completely"
        return 1
    fi
    
    return 0
}

# Initialize logging and capture start time
SCRIPT_START_TIME=$(date '+%Y-%m-%d %H:%M:%S %Z')
init_logging

# Show help if requested (before parsing other arguments)
if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
    show_cli_help
    exit 0
fi

# Parse CLI arguments first
parse_cli_arguments "$@"

# Initialize recovery system
if command -v recovery_manager >/dev/null 2>&1; then
    # Use project root if available, otherwise current directory
    recovery_dir="${PROJECT_ROOT:-./}/recovery"
    init_recovery_system "$recovery_dir"
    log_info "Recovery system initialized at: $recovery_dir" "RECOVERY"
else
    log_warning "Recovery system not available - using legacy backup only" "RECOVERY"
fi

# Banner
clear
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  🚀 WordPress Standards & Formatting                         ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""



# Verificar requisitos
log_info "Starting WordPress Standards & Formatting Script"
log_info "Checking system requirements..."

command -v node >/dev/null 2>&1 || { print_error "Node.js requerido"; exit 1; }
command -v npm >/dev/null 2>&1 || { print_error "npm requerido"; exit 1; }
COMPOSER_AVAILABLE=false
command -v composer >/dev/null 2>&1 && COMPOSER_AVAILABLE=true
JQ_AVAILABLE=false
command -v jq >/dev/null 2>&1 && JQ_AVAILABLE=true

print_success "Requisitos verificados"
log_success "System requirements check completed"
echo ""

# Handle WordPress path configuration
if [ -z "$WORDPRESS_PATH" ]; then
    # No WordPress path provided via CLI, check execution context
    if ! detect_execution_context; then
        # External execution without WordPress path - prompt user
        echo "══════════════════════════════════════════════════════════════"
        echo "  WordPress Directory Configuration"
        echo "══════════════════════════════════════════════════════════════"
        echo ""
        print_info "External execution detected. Please specify WordPress directory path."
        echo ""
        echo "Examples:"
        echo "  /Users/user/Sites/my-project/wordpress"
        echo "  ./my-wordpress-directory"
        echo "  /var/www/my-site"
        echo ""
        
        while true; do
            echo -n "WordPress directory path: "
            read wordpress_input
            echo ""
            
            if [ -n "$wordpress_input" ]; then
                if handle_wordpress_path "$wordpress_input"; then
                    break
                else
                    print_error "Invalid WordPress path. Please try again."
                    echo ""
                fi
            else
                print_warning "WordPress path cannot be empty. Please try again."
                echo ""
            fi
        done
        echo ""
    fi
fi

# Change to project root directory if we're using external WordPress path
if [ -n "$PROJECT_ROOT" ] && [ "$PROJECT_ROOT" != "$(pwd)" ]; then
    print_info "Changing to project root directory: $PROJECT_ROOT"
    if cd "$PROJECT_ROOT"; then
        log_info "Changed working directory to project root: $PROJECT_ROOT" "PATH_HANDLING"
    else
        print_error "Failed to change to project root directory: $PROJECT_ROOT"
        log_error "Failed to change to project root: $PROJECT_ROOT" "PATH_HANDLING"
        exit 1
    fi
fi

# Modo de operación
if [ "$NON_INTERACTIVE" = false ] && [ -z "$MODE" ]; then
    echo "══════════════════════════════════════════════════════════════"
    echo "  Modo de Operación"
    echo "══════════════════════════════════════════════════════════════"
    echo "  1️⃣  Configurar y formatear proyecto"
    echo "  2️⃣  Solo configurar (sin formatear)"
    echo "  3️⃣  Solo formatear código existente"
    echo "  4️⃣  Fusionar configuración (requiere jq)"
    echo ""
    echo -n "Selecciona modo (1-4): "
    read MODE
    echo ""
elif [ -z "$MODE" ]; then
    # Default mode for non-interactive execution
    MODE=1
    print_info "Using default mode: 1 (Configure and format project)"
fi

FORMAT_CODE=false
CONFIGURE_PROJECT=false
MERGE_MODE=false

case $MODE in
    1) CONFIGURE_PROJECT=true; FORMAT_CODE=true; print_info "Modo: Configurar y formatear" ;;
    2) CONFIGURE_PROJECT=true; print_info "Modo: Solo configurar" ;;
    3) FORMAT_CODE=true; print_info "Modo: Solo formatear" ;;
    4) CONFIGURE_PROJECT=true; MERGE_MODE=true; print_info "Modo: Fusionar configuración" ;;
    *) print_error "Opción inválida"; exit 1 ;;
esac

# Validar jq para Modo 4
if [ "$MERGE_MODE" = true ] && [ "$JQ_AVAILABLE" = false ]; then
    print_error "jq es requerido para el Modo 4 (Fusionar configuración)"
    echo ""
    print_info "Instalar jq:"
    echo "  • macOS: brew install jq"
    echo "  • Ubuntu/Debian: sudo apt-get install jq"
    echo "  • CentOS/RHEL: sudo yum install jq"
    echo "  • Windows: choco install jq"
    echo ""
    exit 1
fi

echo ""

# Detectar estructura WordPress
if ! detect_wordpress_structure; then
    print_error "WordPress structure not found"
    echo ""
    print_info "This script requires a valid WordPress installation with wp-content directory."
    echo ""
    print_info "For external execution, use:"
    echo "  $0 /path/to/wordpress [mode]"
    echo ""
    print_info "For legacy execution from project root, ensure one of these exists:"
    echo "  • ./wp-content/"
    echo "  • ./wordpress/wp-content/"
    echo ""
    show_cli_help
    exit 1
fi

print_success "WordPress structure detected: $WP_CONTENT_DIR"
if [ -n "$PROJECT_ROOT" ]; then
    print_info "Project root: $PROJECT_ROOT"
    print_info "WordPress directory: $WORDPRESS_RELATIVE_PATH"
fi
echo ""

# Detectar componentes
print_info "Detectando componentes personalizados..."
echo ""

DETECTED_PLUGINS=($(detect_custom_plugins))
DETECTED_THEMES=($(detect_custom_themes))
DETECTED_MU_PLUGINS=($(detect_custom_mu_plugins))

[ ${#DETECTED_PLUGINS[@]} -gt 0 ] && {
    print_success "Plugins detectados:"
    for p in "${DETECTED_PLUGINS[@]}"; do echo "  📦 $p"; done
    echo ""
}

[ ${#DETECTED_THEMES[@]} -gt 0 ] && {
    print_success "Temas detectados:"
    for t in "${DETECTED_THEMES[@]}"; do echo "  🎨 $t"; done
    echo ""
}

[ ${#DETECTED_MU_PLUGINS[@]} -gt 0 ] && {
    print_success "MU-Plugins detectados:"
    for m in "${DETECTED_MU_PLUGINS[@]}"; do echo "  🔌 $m"; done
    echo ""
}

# Selección de componentes
SELECTED_PLUGINS=()
SELECTED_THEMES=()
SELECTED_MU_PLUGINS=()

if [ "$CONFIGURE_PROJECT" = true ]; then
    echo "══════════════════════════════════════════════════════════════"
    echo "  Selección de Componentes"
    echo "══════════════════════════════════════════════════════════════"
    echo ""
    
    [ ${#DETECTED_PLUGINS[@]} -gt 0 ] && {
        echo "--- Plugins ---"
        for plugin in "${DETECTED_PLUGINS[@]}"; do
            if [ "$NON_INTERACTIVE" = true ]; then
                # In non-interactive mode, include all detected plugins
                SELECTED_PLUGINS+=("$plugin")
                print_success "Plugin '$plugin' añadido (modo automático)"
            else
                while true; do
                    echo -n "¿Incluir '$plugin'? (y/n): "
                    read resp
                    case "$resp" in
                        [Yy]|[Yy][Ee][Ss]|[Ss]|[Ss][Ii])
                            SELECTED_PLUGINS+=("$plugin")
                            print_success "Plugin '$plugin' añadido"
                            break
                            ;;
                        [Nn]|[Nn][Oo])
                            print_info "Plugin '$plugin' omitido"
                            break
                            ;;
                        *)
                            print_warning "Por favor responde 'y' para sí o 'n' para no"
                            ;;
                    esac
                done
            fi
        done
        echo ""
    }
    
    [ ${#DETECTED_THEMES[@]} -gt 0 ] && {
        echo "--- Temas ---"
        for theme in "${DETECTED_THEMES[@]}"; do
            if [ "$NON_INTERACTIVE" = true ]; then
                # In non-interactive mode, include all detected themes
                SELECTED_THEMES+=("$theme")
                print_success "Tema '$theme' añadido (modo automático)"
            else
                while true; do
                    echo -n "¿Incluir '$theme'? (y/n): "
                    read resp
                    case "$resp" in
                        [Yy]|[Yy][Ee][Ss]|[Ss]|[Ss][Ii])
                            SELECTED_THEMES+=("$theme")
                            print_success "Tema '$theme' añadido"
                            break
                            ;;
                        [Nn]|[Nn][Oo])
                            print_info "Tema '$theme' omitido"
                            break
                            ;;
                        *)
                            print_warning "Por favor responde 'y' para sí o 'n' para no"
                            ;;
                    esac
                done
            fi
        done
        echo ""
    }
    
    [ ${#DETECTED_MU_PLUGINS[@]} -gt 0 ] && {
        echo "--- MU-Plugins ---"
        for mu in "${DETECTED_MU_PLUGINS[@]}"; do
            if [ "$NON_INTERACTIVE" = true ]; then
                # In non-interactive mode, include all detected mu-plugins
                SELECTED_MU_PLUGINS+=("$mu")
                print_success "MU-Plugin '$mu' añadido (modo automático)"
            else
                while true; do
                    echo -n "¿Incluir '$mu'? (y/n): "
                    read resp
                    case "$resp" in
                        [Yy]|[Yy][Ee][Ss]|[Ss]|[Ss][Ii])
                            SELECTED_MU_PLUGINS+=("$mu")
                            print_success "MU-Plugin '$mu' añadido"
                            break
                            ;;
                        [Nn]|[Nn][Oo])
                            print_info "MU-Plugin '$mu' omitido"
                            break
                            ;;
                        *)
                            print_warning "Por favor responde 'y' para sí o 'n' para no"
                            ;;
                    esac
                done
            fi
        done
        echo ""
    }
    
    # Debug: mostrar lo que se seleccionó
    print_info "DEBUG: Plugins seleccionados: ${#SELECTED_PLUGINS[@]} (${SELECTED_PLUGINS[@]})"
    print_info "DEBUG: Temas seleccionados: ${#SELECTED_THEMES[@]} (${SELECTED_THEMES[@]})"
    print_info "DEBUG: MU-Plugins seleccionados: ${#SELECTED_MU_PLUGINS[@]} (${SELECTED_MU_PLUGINS[@]})"
    
    [ ${#SELECTED_PLUGINS[@]} -eq 0 ] && [ ${#SELECTED_THEMES[@]} -eq 0 ] && [ ${#SELECTED_MU_PLUGINS[@]} -eq 0 ] && {
        print_error_with_solution "NO_COMPONENTS_SELECTED" "COMPONENT_SELECTION"
        
        # Offer recovery options
        echo -n "Would you like to create a sample component and retry? (y/n): "
        read create_sample
        
        if [[ $create_sample =~ ^[Yy]$ ]]; then
            print_info "Creating sample plugin..." "RECOVERY"
            mkdir -p "$WP_CONTENT_DIR/plugins/mi-proyecto-plugin"
            cat > "$WP_CONTENT_DIR/plugins/mi-proyecto-plugin/init.php" << 'EOF'
<?php
/*
Plugin Name: Mi Proyecto Plugin
Description: Sample plugin created by init-project script
Version: 1.0.0
*/

// Prevent direct access
if (!defined('ABSPATH')) {
    exit;
}

// Plugin initialization
add_action('init', function() {
    // Plugin code here
});
EOF
            print_success "Sample plugin created at $WP_CONTENT_DIR/plugins/mi-proyecto-plugin" "RECOVERY"
            print_info "Please re-run the script to select the new component" "RECOVERY"
            log_info "Sample plugin created for user" "RECOVERY"
        else
            print_warning "Operation cancelled - no components selected" "RECOVERY"
            log_warning "User cancelled due to no component selection" "RECOVERY"
        fi
        
        exit 1
    }
    
    echo "══════════════════════════════════════════════════════════════"
    echo "  Resumen"
    echo "══════════════════════════════════════════════════════════════"
    echo ""
    [ ${#SELECTED_PLUGINS[@]} -gt 0 ] && {
        echo "Plugins (${#SELECTED_PLUGINS[@]}):"
        for p in "${SELECTED_PLUGINS[@]}"; do echo "  ✅ $p"; done
        echo ""
    }
    [ ${#SELECTED_THEMES[@]} -gt 0 ] && {
        echo "Temas (${#SELECTED_THEMES[@]}):"
        for t in "${SELECTED_THEMES[@]}"; do echo "  ✅ $t"; done
        echo ""
    }
    [ ${#SELECTED_MU_PLUGINS[@]} -gt 0 ] && {
        echo "MU-Plugins (${#SELECTED_MU_PLUGINS[@]}):"
        for m in "${SELECTED_MU_PLUGINS[@]}"; do echo "  ✅ $m"; done
        echo ""
    }
    
    echo -n "¿Continuar? (y/n): "
    read CONFIRM
    [[ ! $CONFIRM =~ ^[Yy]$ ]] && { print_warning "Cancelado"; exit 0; }
else
    # Modo 3: usar todos los componentes detectados
    SELECTED_PLUGINS=("${DETECTED_PLUGINS[@]}")
    SELECTED_THEMES=("${DETECTED_THEMES[@]}")
    SELECTED_MU_PLUGINS=("${DETECTED_MU_PLUGINS[@]}")
    
    # Verificar que hay componentes para formatear
    if [ ${#SELECTED_PLUGINS[@]} -eq 0 ] && [ ${#SELECTED_THEMES[@]} -eq 0 ] && [ ${#SELECTED_MU_PLUGINS[@]} -eq 0 ]; then
        print_error "No se encontraron componentes personalizados para formatear"
        exit 1
    fi
fi

# Perform comprehensive validation before proceeding
echo ""
echo "══════════════════════════════════════════════════════════════"
echo "  Validation & Pre-flight Checks"
echo "══════════════════════════════════════════════════════════════"
echo ""

if ! validate_with_recovery; then
    echo ""
    print_error "Validation failed and cannot continue safely" "VALIDATION"
    log_error "Validation failed - operation terminated" "VALIDATION"
    show_operation_summary
    exit 1
fi

echo ""

# Nombre del proyecto
echo ""
echo "══════════════════════════════════════════════════════════════"
echo "  Configuración del Proyecto"
echo "══════════════════════════════════════════════════════════════"
echo ""

PROJECT_SLUG=""

print_info "Buscando nombre del proyecto en archivos de configuración..."

# Intentar detectar desde composer.json
if [ -f "composer.json" ]; then
    DETECTED=$(grep -o '"name": "[^"]*"' composer.json 2>/dev/null | head -1 | cut -d'"' -f4 | cut -d'/' -f2 | sed 's/-wordpress$//' || echo "")
    # Ignorar nombres genéricos
    if [ -n "$DETECTED" ] && [ "$DETECTED" != "wordpress" ] && [ "$DETECTED" != "my-project" ]; then
        echo ""
        print_info "Detectado desde composer.json: $DETECTED"
        if [ "$NON_INTERACTIVE" = true ]; then
            PROJECT_SLUG="$DETECTED"
            print_success "Usando nombre detectado automáticamente: $DETECTED"
        else
            read -p "¿Usar este nombre? (y/n): " resp < /dev/tty
            echo ""
            [[ $resp =~ ^[Yy]$ ]] && PROJECT_SLUG="$DETECTED"
        fi
    fi
fi

# Fallback: intentar desde package.json
if [ -z "$PROJECT_SLUG" ] && [ -f "package.json" ]; then
    DETECTED=$(grep -o '"name": "[^"]*"' package.json 2>/dev/null | head -1 | cut -d'"' -f4 | sed 's/-wordpress$//' || echo "")
    # Ignorar nombres genéricos
    if [ -n "$DETECTED" ] && [ "$DETECTED" != "wordpress" ] && [ "$DETECTED" != "my-project" ]; then
        echo ""
        print_info "Detectado desde package.json: $DETECTED"
        if [ "$NON_INTERACTIVE" = true ]; then
            PROJECT_SLUG="$DETECTED"
            print_success "Usando nombre detectado automáticamente: $DETECTED"
        else
            read -p "¿Usar este nombre? (y/n): " resp < /dev/tty
            echo ""
            [[ $resp =~ ^[Yy]$ ]] && PROJECT_SLUG="$DETECTED"
        fi
    fi
fi

# Generate default project slug from WordPress directory name if in non-interactive mode
if [ -z "$PROJECT_SLUG" ] && [ "$NON_INTERACTIVE" = true ] && [ -n "$WORDPRESS_RELATIVE_PATH" ]; then
    # Use WordPress directory name as project slug, removing common suffixes
    DETECTED=$(echo "$WORDPRESS_RELATIVE_PATH" | sed -e 's/-wordpress$//' -e 's/_wordpress$//' -e 's/wordpress$//' -e 's/wp$//')
    if [ -n "$DETECTED" ] && validate_slug "$DETECTED" 2>/dev/null; then
        PROJECT_SLUG="$DETECTED"
        print_success "Generated project slug from WordPress directory: $PROJECT_SLUG"
    else
        # Fallback to generic name in non-interactive mode
        PROJECT_SLUG="my-project"
        print_warning "Using fallback project slug: $PROJECT_SLUG"
    fi
fi

# Solicitar nombre si no se detectó (solo en modo interactivo)
if [ -z "$PROJECT_SLUG" ] && [ "$NON_INTERACTIVE" = false ]; then
    echo ""
    print_warning "No se pudo detectar el nombre automáticamente"
    
    while [ -z "$PROJECT_SLUG" ]; do
        echo ""
        echo -n "Nombre del proyecto (slug, ej: astro-headless): "
        read PROJECT_SLUG
        echo ""
        if [ -z "$PROJECT_SLUG" ]; then
            print_error "El nombre no puede estar vacío"
            continue
        fi
        if ! validate_slug "$PROJECT_SLUG"; then
            PROJECT_SLUG=""
        fi
    done
elif [ -z "$PROJECT_SLUG" ]; then
    # Final fallback for non-interactive mode
    PROJECT_SLUG="my-project"
    print_warning "Using default project slug: $PROJECT_SLUG"
fi

print_success "Proyecto: $PROJECT_SLUG"
echo ""

PROJECT_CONSTANT=$(generate_constant "$PROJECT_SLUG")
PROJECT_NAMESPACE=$(generate_namespace "$PROJECT_SLUG")
TEXT_DOMAIN="$PROJECT_SLUG"

# Generar archivos de configuración
if [ "$CONFIGURE_PROJECT" = true ]; then
    echo "══════════════════════════════════════════════════════════════"
    echo "  Generando Archivos de Configuración"
    echo "══════════════════════════════════════════════════════════════"
    echo ""
    
    # Create recovery point before configuration generation
    if command -v create_recovery_point >/dev/null 2>&1 && is_recovery_enabled; then
        local config_files=()
        [ -f "phpcs.xml.dist" ] && config_files+=("phpcs.xml.dist")
        [ -f "phpstan.neon.dist" ] && config_files+=("phpstan.neon.dist")
        [ -f "eslint.config.js" ] && config_files+=("eslint.config.js")
        [ -f "package.json" ] && config_files+=("package.json")
        [ -f "composer.json" ] && config_files+=("composer.json")
        [ -f ".gitignore" ] && config_files+=(".gitignore")
        [ -f "bitbucket-pipelines.yml" ] && config_files+=("bitbucket-pipelines.yml")
        [ -f "Makefile" ] && config_files+=("Makefile")
        
        if [ ${#config_files[@]} -gt 0 ]; then
            local recovery_point_id
            recovery_point_id=$(create_recovery_point "configure_project" "Before project configuration generation" "${config_files[@]}")
            if [ -n "$recovery_point_id" ]; then
                print_info "Recovery point created: $recovery_point_id" "RECOVERY"
                log_info "Recovery point created before configuration: $recovery_point_id" "RECOVERY"
            fi
        fi
    fi
    
    # Initialize backup directory
    BACKUP_DIR=""
    
    # Generate adapted template files using the new function
    generate_project_files
    
    # Backup existing configuration files
    for f in phpcs.xml.dist phpstan.neon.dist eslint.config.js; do
        [ -f "$f" ] && create_backup "$f"
    done
    [ -n "$BACKUP_DIR" ] && [ -d "$BACKUP_DIR" ] && print_success "Backup: $BACKUP_DIR"
    echo ""
    
    # Construir prefixes y text domains
    PREFIXES=""
    TEXT_DOMAINS="                <element value=\"${TEXT_DOMAIN}\"/>\n"
    
    add_component() {
        local name="$1"
        local prefix=$(echo "$name" | tr '-' '_')
        local constant=$(generate_constant "$name")
        local namespace=$(generate_namespace "$name")
        PREFIXES+="                <element value=\"${prefix}_\"/>\n"
        PREFIXES+="                <element value=\"${constant}_\"/>\n"
        # Escapar correctamente para XML
        PREFIXES+="                <element value=\"${namespace}\\\\\"/>\n"
        TEXT_DOMAINS+="                <element value=\"${name}\"/>\n"
    }
    
    add_component "$PROJECT_SLUG"
    for p in "${SELECTED_PLUGINS[@]}"; do add_component "$p"; done
    for t in "${SELECTED_THEMES[@]}"; do add_component "$t"; done
    
    # Construir rutas
    FILES=""
    for p in "${SELECTED_PLUGINS[@]}"; do FILES+="    <file>${WP_CONTENT_DIR}/plugins/${p}</file>\n"; done
    for t in "${SELECTED_THEMES[@]}"; do FILES+="    <file>${WP_CONTENT_DIR}/themes/${t}</file>\n"; done
    for m in "${SELECTED_MU_PLUGINS[@]}"; do FILES+="    <file>${WP_CONTENT_DIR}/mu-plugins/${m}</file>\n"; done
    
    # phpcs.xml.dist
    print_info "Generando phpcs.xml.dist..."
    
    # Create phpcs.xml.dist directly with cat heredoc
    cat > phpcs.xml.dist << 'PHPCS_EOF'
<?xml version="1.0"?>
<ruleset name="WordPress Project PHP Standards">
    <description>PHP CodeSniffer rules for WordPress project</description>

    <rule ref="WordPress">
        <exclude name="WordPress.Files.FileName.InvalidClassFileName"/>
        <exclude name="WordPress.Files.FileName.NotHyphenatedLowercase"/>
        <exclude name="Squiz.Commenting.InlineComment.InvalidEndChar"/>
        <exclude name="Squiz.Commenting.FunctionComment.Missing"/>
        <exclude name="Squiz.Commenting.FileComment.Missing"/>
        <exclude name="Squiz.Commenting.ClassComment.Missing"/>
        <exclude name="Squiz.Commenting.VariableComment.Missing"/>
    </rule>

    <rule ref="WordPress.NamingConventions.PrefixAllGlobals">
        <properties>
            <property name="prefixes" type="array">
PHPCS_EOF
    echo -e "$PREFIXES" >> phpcs.xml.dist
    cat >> phpcs.xml.dist << 'PHPCS_EOF2'
            </property>
        </properties>
    </rule>

    <rule ref="WordPress.WP.I18n">
        <properties>
            <property name="text_domain" type="array">
PHPCS_EOF2
    echo -e "$TEXT_DOMAINS" >> phpcs.xml.dist
    cat >> phpcs.xml.dist << 'PHPCS_EOF3'
            </property>
        </properties>
    </rule>

    <!-- Files to check -->
PHPCS_EOF3
    echo -e "$FILES" >> phpcs.xml.dist
    cat >> phpcs.xml.dist << PHPCS_EOF4
    <!-- Exclude directories -->
    <exclude-pattern>*/node_modules/*</exclude-pattern>
    <exclude-pattern>*/build/*</exclude-pattern>
    <exclude-pattern>*/vendor/*</exclude-pattern>
    <exclude-pattern>*/tests/*</exclude-pattern>
    <exclude-pattern>*.min.js</exclude-pattern>
    <exclude-pattern>${WP_CONTENT_DIR%/*}/wp-admin/*</exclude-pattern>
    <exclude-pattern>${WP_CONTENT_DIR%/*}/wp-includes/*</exclude-pattern>

    <arg name="extensions" value="php"/>
    <arg value="p"/>
    <arg value="s"/>
    <arg name="parallel" value="8"/>
    <config name="ignore_warnings_on_exit" value="1"/>
</ruleset>
PHPCS_EOF4
    
    if [ -f "phpcs.xml.dist" ]; then
        print_success "phpcs.xml.dist generado"
    else
        print_error "Error generando phpcs.xml.dist"
    fi
    
    # phpstan.neon.dist
    print_info "Generando phpstan.neon.dist..."
    PATHS=""
    EXCLUDES=""
    for p in "${SELECTED_PLUGINS[@]}"; do
        PATHS+="    - ${WP_CONTENT_DIR}/plugins/${p}/\n"
        EXCLUDES+="    - ${WP_CONTENT_DIR}/plugins/${p}/build/\n"
        EXCLUDES+="    - ${WP_CONTENT_DIR}/plugins/${p}/vendor/\n"
        EXCLUDES+="    - ${WP_CONTENT_DIR}/plugins/${p}/node_modules/\n"
    done
    for t in "${SELECTED_THEMES[@]}"; do
        PATHS+="    - ${WP_CONTENT_DIR}/themes/${t}/\n"
        EXCLUDES+="    - ${WP_CONTENT_DIR}/themes/${t}/build/\n"
        EXCLUDES+="    - ${WP_CONTENT_DIR}/themes/${t}/vendor/\n"
    done
    for m in "${SELECTED_MU_PLUGINS[@]}"; do
        PATHS+="    - ${WP_CONTENT_DIR}/mu-plugins/${m}/\n"
    done
    
    cat > phpstan.neon.dist << PHPSTAN_EOF
parameters:
  level: 5

  paths:
$(echo -e "$PATHS")
  excludePaths:
$(echo -e "$EXCLUDES")    - ${WP_CONTENT_DIR%/*}/wp-admin/
    - ${WP_CONTENT_DIR%/*}/wp-includes/

  ignoreErrors:
    - '#Call to an undefined method#'
    - '#Access to an undefined property#'
    - '#Undefined variable#'

  phpVersion: 80100
  checkMissingTypehints: false
PHPSTAN_EOF
    
    print_success "phpstan.neon.dist generado"
    
    # eslint.config.js
    print_info "Generando eslint.config.js..."
    ESLINT_FILES=""
    for p in "${SELECTED_PLUGINS[@]}"; do
        ESLINT_FILES+="      '${WP_CONTENT_DIR}/plugins/${p}/**/*.{js,jsx,ts,tsx}',\n"
    done
    for t in "${SELECTED_THEMES[@]}"; do
        ESLINT_FILES+="      '${WP_CONTENT_DIR}/themes/${t}/**/*.{js,jsx,ts,tsx}',\n"
    done
    
    # Create eslint.config.js directly
    cat > eslint.config.js << 'ESLINT_EOF'
import js from '@eslint/js';
import globals from 'globals';

export default [
  {
    ignores: ['build/', 'node_modules/', 'vendor/', '**/*.min.js'],
  },
  {
    ...js.configs.recommended,
    languageOptions: {
      ecmaVersion: 2022,
      sourceType: 'module',
      globals: { ...globals.browser, ...globals.node, wp: 'readonly', jQuery: 'readonly', $: 'readonly', __: 'readonly' },
    },
    files: [
ESLINT_EOF
    if [ -n "$ESLINT_FILES" ]; then
        echo -e "$ESLINT_FILES" | sed '$ s/,$//' >> eslint.config.js
    fi
    cat >> eslint.config.js << 'ESLINT_EOF2'
    ],
    rules: {
      'array-bracket-spacing': ['error', 'always'],
      'space-in-parens': ['error', 'always'],
      'object-curly-spacing': ['error', 'always'],
      'computed-property-spacing': ['error', 'always'],
      'space-infix-ops': 'error',
      'keyword-spacing': ['error', { before: true, after: true }],
      'space-before-function-paren': ['error', { anonymous: 'always', named: 'never', asyncArrow: 'always' }],
      'space-before-blocks': 'error',
      'camelcase': ['error', { properties: 'never' }],
      'indent': ['error', 'tab', { SwitchCase: 1 }],
      'quotes': ['error', 'single', { avoidEscape: true }],
      'semi': ['error', 'always'],
      'comma-dangle': ['error', 'always-multiline'],
      'no-trailing-spaces': 'error',
      'eol-last': 'error',
      'no-console': ['warn', { allow: ['warn', 'error'] }],
      'no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
      'prefer-const': 'error',
      'no-var': 'error',
    },
  },
];
ESLINT_EOF2
    
    if [ -f "eslint.config.js" ]; then
        print_success "eslint.config.js generado"
    else
        print_error "Error generando eslint.config.js"
    fi
    
    # Handle package.json
    print_info "Procesando package.json..."
    cat > package.json << PACKAGE_EOF
{
  "name": "${PROJECT_SLUG}",
  "version": "1.0.0",
  "description": "WordPress project with coding standards",
  "type": "module",
  "scripts": {
    "lint:js": "eslint '**/*.{js,jsx,ts,tsx}'",
    "lint:js:fix": "eslint --fix '**/*.{js,jsx,ts,tsx}'",
    "lint:php": "./vendor/bin/phpcs --standard=phpcs.xml.dist",
    "lint:php:fix": "./vendor/bin/phpcbf --standard=phpcs.xml.dist",
    "lint": "npm run lint:js && npm run lint:php",
    "format": "npm run lint:js:fix && npm run lint:php:fix"
  },
  "devDependencies": {
    "@eslint/js": "^9.9.0",
    "eslint": "^9.9.0",
    "globals": "^15.9.0"
  },
  "author": "",
  "license": "MIT"
}
PACKAGE_EOF
    
    if [ -f "package.json" ]; then
        print_success "package.json generado"
    else
        print_error "Error generando package.json"
    fi
    
    # Handle composer.json
    print_info "Procesando composer.json..."
    cat > composer.json << COMPOSER_EOF
{
    "name": "${PROJECT_SLUG}/wordpress",
    "description": "WordPress project with coding standards",
    "type": "project",
    "require": {
        "php": ">=8.1"
    },
    "require-dev": {
        "dealerdirect/phpcodesniffer-composer-installer": "^1.0",
        "phpcompatibility/php-compatibility": "^9.3",
        "phpstan/phpstan": "^1.11",
        "wp-coding-standards/wpcs": "^3.1"
    },
    "config": {
        "allow-plugins": {
            "dealerdirect/phpcodesniffer-composer-installer": true
        }
    },
    "scripts": {
        "lint": "phpcs --standard=phpcs.xml.dist",
        "lint:fix": "phpcbf --standard=phpcs.xml.dist",
        "analyze": "phpstan analyze"
    }
}
COMPOSER_EOF
    
    if [ -f "composer.json" ]; then
        print_success "composer.json generado"
    else
        print_error "Error generando composer.json"
    fi
    
    # Generar configuración de VSCode usando operaciones específicas por modo
    print_info "Procesando configuración de VSCode..."
    
    # extensions.json content
    local extensions_content="{
  \"recommendations\": [
    \"bmewburn.vscode-intelephense-client\",
    \"valeryanm.vscode-phpsab\",
    \"dbaeumer.vscode-eslint\",
    \"stylelint.vscode-stylelint\",
    \"esbenp.prettier-vscode\",
    \"editorconfig.editorconfig\"
  ]
}"
    
    # settings.json content
    local settings_content="{
  \"editor.rulers\": [120],
  \"editor.tabSize\": 4,
  \"editor.insertSpaces\": false,
  \"editor.detectIndentation\": false,
  \"editor.formatOnSave\": true,
  
  // PHPCS configuration
  \"phpcs.enable\": true,
  \"phpcs.standard\": \"./phpcs.xml.dist\",
  \"phpcs.executablePath\": \"./vendor/bin/phpcs\",
  \"phpcs.showSources\": true,
  \"phpcs.showSniffSource\": true,
  
  // PHPSAB configuration
  \"phpsab.snifferMode\": \"onType\",
  \"phpsab.snifferShowSources\": true,
  
  // ESLint configuration
  \"eslint.enable\": true,
  \"eslint.validate\": [\"javascript\", \"javascriptreact\", \"typescript\", \"typescriptreact\"],
  \"eslint.workingDirectories\": [\".\"],
  
  // Stylelint configuration
  \"stylelint.enable\": true,
  \"stylelint.validate\": [\"css\", \"scss\", \"sass\"],
  
  // PHP language settings
  \"[php]\": {
    \"editor.defaultFormatter\": \"valeryanm.vscode-phpsab\",
    \"editor.formatOnSave\": true,
    \"editor.tabSize\": 4,
    \"editor.insertSpaces\": false,
    \"editor.rulers\": [120],
    \"editor.codeActionsOnSave\": {
      \"source.fixAll\": \"always\"
    }
  },
  
  // JavaScript language settings
  \"[javascript]\": {
    \"editor.defaultFormatter\": \"dbaeumer.vscode-eslint\",
    \"editor.formatOnSave\": true,
    \"editor.tabSize\": 2,
    \"editor.insertSpaces\": true,
    \"editor.codeActionsOnSave\": {
      \"source.fixAll.eslint\": \"always\"
    }
  },
  
  // JavaScript React settings
  \"[javascriptreact]\": {
    \"editor.defaultFormatter\": \"dbaeumer.vscode-eslint\",
    \"editor.formatOnSave\": true,
    \"editor.tabSize\": 2,
    \"editor.insertSpaces\": true,
    \"editor.codeActionsOnSave\": {
      \"source.fixAll.eslint\": \"always\"
    }
  },
  
  // TypeScript settings
  \"[typescript]\": {
    \"editor.defaultFormatter\": \"dbaeumer.vscode-eslint\",
    \"editor.formatOnSave\": true,
    \"editor.tabSize\": 2,
    \"editor.insertSpaces\": true,
    \"editor.codeActionsOnSave\": {
      \"source.fixAll.eslint\": \"always\"
    }
  },
  
  // TypeScript React settings
  \"[typescriptreact]\": {
    \"editor.defaultFormatter\": \"dbaeumer.vscode-eslint\",
    \"editor.formatOnSave\": true,
    \"editor.tabSize\": 2,
    \"editor.insertSpaces\": true,
    \"editor.codeActionsOnSave\": {
      \"source.fixAll.eslint\": \"always\"
    }
  },
  
  // CSS language settings
  \"[css]\": {
    \"editor.defaultFormatter\": \"stylelint.vscode-stylelint\",
    \"editor.formatOnSave\": true,
    \"editor.tabSize\": 2,
    \"editor.insertSpaces\": true,
    \"editor.codeActionsOnSave\": {
      \"source.fixAll.stylelint\": \"always\"
    }
  },
  
  // SCSS language settings
  \"[scss]\": {
    \"editor.defaultFormatter\": \"stylelint.vscode-stylelint\",
    \"editor.formatOnSave\": true,
    \"editor.tabSize\": 2,
    \"editor.insertSpaces\": true,
    \"editor.codeActionsOnSave\": {
      \"source.fixAll.stylelint\": \"always\"
    }
  },
  
  // JSON settings
  \"[json]\": {
    \"editor.defaultFormatter\": \"esbenp.prettier-vscode\",
    \"editor.formatOnSave\": true,
    \"editor.tabSize\": 2,
    \"editor.insertSpaces\": true
  },
  
  // JSONC settings
  \"[jsonc]\": {
    \"editor.defaultFormatter\": \"esbenp.prettier-vscode\",
    \"editor.formatOnSave\": true,
    \"editor.tabSize\": 2,
    \"editor.insertSpaces\": true
  },
  
  // Markdown settings
  \"[markdown]\": {
    \"editor.defaultFormatter\": \"esbenp.prettier-vscode\",
    \"editor.formatOnSave\": true,
    \"editor.tabSize\": 2,
    \"editor.insertSpaces\": true,
    \"editor.wordWrap\": \"on\"
  },
  
  // YAML settings
  \"[yaml]\": {
    \"editor.defaultFormatter\": \"esbenp.prettier-vscode\",
    \"editor.formatOnSave\": true,
    \"editor.tabSize\": 2,
    \"editor.insertSpaces\": true
  },
  
  // HTML settings
  \"[html]\": {
    \"editor.defaultFormatter\": \"esbenp.prettier-vscode\",
    \"editor.formatOnSave\": true,
    \"editor.tabSize\": 2,
    \"editor.insertSpaces\": true
  }
}"
    
    # Use mode-specific file operations for VSCode configuration
    if perform_mode_specific_file_operation "$extensions_content" ".vscode/extensions.json" "write" && \
       perform_mode_specific_file_operation "$settings_content" ".vscode/settings.json" "write"; then
        print_success ".vscode/ procesado según modo $MODE"
    else
        print_error "Error procesando configuración de VSCode"
    fi
    
    # Generate workspace file with selected components
    generate_workspace_file
    
    echo ""
    print_success "Archivos de configuración generados"
fi

# Formateo automático
if [ "$FORMAT_CODE" = true ]; then
    echo ""
    echo "══════════════════════════════════════════════════════════════"
    echo "  Formateo Automático del Código"
    echo "══════════════════════════════════════════════════════════════"
    echo ""
    
    [ ! -f "phpcs.xml.dist" ] && {
        print_error "phpcs.xml.dist no encontrado"
        print_info "Ejecuta primero el modo 1 o 2 para generar la configuración"
        exit 1
    }
    
    # Verificar que existan componentes para formatear
    has_components=false
    for plugin in "${SELECTED_PLUGINS[@]}"; do
        [ -d "$WP_CONTENT_DIR/plugins/$plugin" ] && has_components=true && break
    done
    for theme in "${SELECTED_THEMES[@]}"; do
        [ -d "$WP_CONTENT_DIR/themes/$theme" ] && has_components=true && break
    done
    
    [ "$has_components" = false ] && {
        print_warning "Advertencia: No se encontraron directorios de componentes"
        print_info "Verifica que los plugins/temas existan en las rutas esperadas"
        read -p "¿Continuar de todos modos? (y/n): " resp < /dev/tty
        [[ ! $resp =~ ^[Yy]$ ]] && exit 0
    }
    
    # PHP Code Beautifier & Fixer
    if [ -f "vendor/bin/phpcbf" ]; then
        print_info "Formateando código PHP con PHPCBF..."
        echo ""
        ./vendor/bin/phpcbf --standard=phpcs.xml.dist || {
            exitcode=$?
            [ $exitcode -eq 1 ] && print_success "PHP formateado (algunos archivos corregidos)" || print_warning "PHP: revisar warnings"
        }
        echo ""
    elif [ "$COMPOSER_AVAILABLE" = true ] && [ -f "composer.json" ]; then
        print_warning "PHPCBF no encontrado"
        read -p "¿Instalar dependencias de Composer? (y/n): " INSTALL < /dev/tty
        [[ $INSTALL =~ ^[Yy]$ ]] && {
            print_info "Instalando dependencias..."
            if composer install; then
                [ -f "vendor/bin/phpcbf" ] && {
                    print_info "Formateando código PHP..."
                    ./vendor/bin/phpcbf --standard=phpcs.xml.dist || print_success "PHP formateado"
                }
            else
                print_error "Error al instalar dependencias de Composer"
            fi
        }
    elif [ ! -f "composer.json" ]; then
        print_warning "composer.json no encontrado - omitiendo formateo PHP"
    else
        print_warning "Composer no disponible - omitiendo formateo PHP"
    fi
    
    # ESLint (JavaScript) - Updated to use new path building function
    if [ -f "eslint.config.js" ] && command -v npx >/dev/null 2>&1; then
        # Build specific paths for selected components using the new function
        print_info "Building JavaScript paths for selected components..."
        JS_PATHS=($(build_js_paths_for_formatting))
        
        if [ ${#JS_PATHS[@]} -gt 0 ]; then
            print_info "Found ${#JS_PATHS[@]} component path(s) for JavaScript formatting"
            log_info "JavaScript paths: ${JS_PATHS[*]}"
            if [ -d "node_modules" ]; then
                print_info "Formateando código JavaScript con ESLint..."
                echo ""
                npx eslint --fix "${JS_PATHS[@]}" --cache 2>/dev/null || print_warning "ESLint: revisar warnings"
                echo ""
            elif [ -f "package.json" ]; then
                print_warning "node_modules no encontrado"
                read -p "¿Instalar dependencias de npm? (y/n): " INSTALL < /dev/tty
                [[ $INSTALL =~ ^[Yy]$ ]] && {
                    print_info "Instalando dependencias..."
                    if npm install; then
                        print_info "Formateando código JavaScript..."
                        npx eslint --fix "${JS_PATHS[@]}" --cache 2>/dev/null || print_success "JavaScript formateado"
                    else
                        print_error "Error al instalar dependencias de npm"
                    fi
                }
            else
                print_warning "package.json no encontrado - omitiendo formateo JavaScript"
            fi
        else
            print_info "No hay archivos JavaScript para formatear en los componentes seleccionados"
            log_info "No JavaScript files found for formatting in selected components"
        fi
    else
        print_warning "ESLint no disponible - omitiendo formateo JavaScript"
    fi
    
    echo ""
    print_success "Formateo completado"
fi

# Resumen final
echo ""
echo "══════════════════════════════════════════════════════════════"
echo "  🎉 ¡Completado!"
echo "══════════════════════════════════════════════════════════════"
echo ""

if [ "$CONFIGURE_PROJECT" = true ]; then
    print_success "Archivos de configuración generados"
    echo ""
    echo "Archivos creados:"
    [ -f "phpcs.xml.dist" ] && echo "  ✅ phpcs.xml.dist (WordPress PHP Standards)"
    [ -f "phpstan.neon.dist" ] && echo "  ✅ phpstan.neon.dist (PHP Static Analysis)"
    [ -f "eslint.config.js" ] && echo "  ✅ eslint.config.js (WordPress JS Standards)"
    [ -f "composer.json" ] && echo "  ✅ composer.json (Dependencias PHP)"
    [ -f "package.json" ] && echo "  ✅ package.json (Dependencias JS)"
    [ -f "wp.code-workspace" ] && echo "  ✅ wp.code-workspace (VSCode Workspace)"
    [ -d ".vscode" ] && echo "  ✅ .vscode/ (Configuración VSCode)"
    echo ""
fi

if [ "$FORMAT_CODE" = true ]; then
    print_success "Código formateado según estándares WordPress"
    echo ""
fi

echo "══════════════════════════════════════════════════════════════"
echo "  Próximos Pasos"
echo "══════════════════════════════════════════════════════════════"
echo ""

if [ "$CONFIGURE_PROJECT" = true ]; then
    SHOW_INSTALL=false
    [ ! -d "vendor" ] && [ -f "composer.json" ] && SHOW_INSTALL=true
    [ ! -d "node_modules" ] && [ -f "package.json" ] && SHOW_INSTALL=true
    
    if [ "$SHOW_INSTALL" = true ]; then
        echo "1. Instalar dependencias:"
        [ ! -d "vendor" ] && [ -f "composer.json" ] && echo "   ${BLUE}composer install${NC}"
        [ ! -d "node_modules" ] && [ -f "package.json" ] && echo "   ${BLUE}npm install${NC}"
        echo ""
    fi
fi

echo "2. Verificar estándares:"
[ -f "composer.json" ] && echo "   ${BLUE}./vendor/bin/phpcs --standard=phpcs.xml.dist${NC}"
[ -f "package.json" ] && echo "   ${BLUE}npx eslint '**/*.{js,jsx,ts,tsx}'${NC}"
echo ""

echo "3. Formatear código:"
[ -f "composer.json" ] && echo "   ${BLUE}./vendor/bin/phpcbf --standard=phpcs.xml.dist${NC}"
[ -f "package.json" ] && echo "   ${BLUE}npx eslint --fix '**/*.{js,jsx,ts,tsx}'${NC}"
echo ""

print_success "¡Listo para desarrollar con estándares WordPress!"

# Attempt recovery of any failed operations
attempt_recovery_operations

# Clean up old recovery points (keep last 5, max 7 days old)
if command -v cleanup_recovery_points >/dev/null 2>&1 && is_recovery_enabled; then
    cleanup_recovery_points 7 5
fi

# Show comprehensive operation summary with recovery information
show_operation_summary

echo ""

