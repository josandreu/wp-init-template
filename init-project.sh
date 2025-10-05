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

print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }

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

detect_wordpress_structure() {
    [ -d "wordpress/wp-content" ] && { WP_CONTENT_DIR="wordpress/wp-content"; return 0; }
    [ -d "wp-content" ] && { WP_CONTENT_DIR="wp-content"; return 0; }
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

# Banner
clear
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  🚀 WordPress Standards & Formatting                         ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Verificar requisitos
command -v node >/dev/null 2>&1 || { print_error "Node.js requerido"; exit 1; }
command -v npm >/dev/null 2>&1 || { print_error "npm requerido"; exit 1; }
COMPOSER_AVAILABLE=false
command -v composer >/dev/null 2>&1 && COMPOSER_AVAILABLE=true

print_success "Requisitos verificados"
echo ""

# Modo de operación
echo "══════════════════════════════════════════════════════════════"
echo "  Modo de Operación"
echo "══════════════════════════════════════════════════════════════"
echo "  1️⃣  Configurar y formatear proyecto"
echo "  2️⃣  Solo configurar (sin formatear)"
echo "  3️⃣  Solo formatear código existente"
echo ""
read -p "Selecciona modo (1-3): " MODE
echo ""

FORMAT_CODE=false
CONFIGURE_PROJECT=false

case $MODE in
    1) CONFIGURE_PROJECT=true; FORMAT_CODE=true; print_info "Modo: Configurar y formatear" ;;
    2) CONFIGURE_PROJECT=true; print_info "Modo: Solo configurar" ;;
    3) FORMAT_CODE=true; print_info "Modo: Solo formatear" ;;
    *) print_error "Opción inválida"; exit 1 ;;
esac

echo ""

# Detectar estructura WordPress
detect_wordpress_structure || { print_error "Estructura WordPress no encontrada"; exit 1; }
print_success "Estructura detectada: $WP_CONTENT_DIR"
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
            read -p "¿Incluir '$plugin'? (y/n): " resp
            [[ $resp =~ ^[Yy]$ ]] && SELECTED_PLUGINS+=("$plugin")
        done
        echo ""
    }
    
    [ ${#DETECTED_THEMES[@]} -gt 0 ] && {
        echo "--- Temas ---"
        for theme in "${DETECTED_THEMES[@]}"; do
            read -p "¿Incluir '$theme'? (y/n): " resp
            [[ $resp =~ ^[Yy]$ ]] && SELECTED_THEMES+=("$theme")
        done
        echo ""
    }
    
    [ ${#DETECTED_MU_PLUGINS[@]} -gt 0 ] && {
        echo "--- MU-Plugins ---"
        for mu in "${DETECTED_MU_PLUGINS[@]}"; do
            read -p "¿Incluir '$mu'? (y/n): " resp
            [[ $resp =~ ^[Yy]$ ]] && SELECTED_MU_PLUGINS+=("$mu")
        done
        echo ""
    }
    
    [ ${#SELECTED_PLUGINS[@]} -eq 0 ] && [ ${#SELECTED_THEMES[@]} -eq 0 ] && [ ${#SELECTED_MU_PLUGINS[@]} -eq 0 ] && {
        print_error "No se seleccionó ningún componente"
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
    
    read -p "¿Continuar? (y/n): " CONFIRM
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

# Nombre del proyecto
echo ""
echo "══════════════════════════════════════════════════════════════"
echo "  Configuración del Proyecto"
echo "══════════════════════════════════════════════════════════════"
echo ""

PROJECT_SLUG=""

# Intentar detectar desde composer.json
[ -f "composer.json" ] && {
    DETECTED=$(grep -o '"name": "[^"]*"' composer.json | head -1 | cut -d'"' -f4 | cut -d'/' -f2 | sed 's/-wordpress$//')
    [ -n "$DETECTED" ] && {
        print_info "Detectado desde composer.json: $DETECTED"
        read -p "¿Usar este nombre? (y/n): " resp
        [[ $resp =~ ^[Yy]$ ]] && PROJECT_SLUG="$DETECTED"
    }
}

# Fallback: intentar desde package.json
[ -z "$PROJECT_SLUG" ] && [ -f "package.json" ] && {
    DETECTED=$(grep -o '"name": "[^"]*"' package.json | head -1 | cut -d'"' -f4 | sed 's/-wordpress$//')
    [ -n "$DETECTED" ] && {
        print_info "Detectado desde package.json: $DETECTED"
        read -p "¿Usar este nombre? (y/n): " resp
        [[ $resp =~ ^[Yy]$ ]] && PROJECT_SLUG="$DETECTED"
    }
}

while [ -z "$PROJECT_SLUG" ]; do
    read -p "Nombre del proyecto (slug): " PROJECT_SLUG
    validate_slug "$PROJECT_SLUG" || PROJECT_SLUG=""
done

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
    
    # Backup
    BACKUP_DIR="./backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    for f in phpcs.xml.dist phpstan.neon.dist eslint.config.js; do
        [ -f "$f" ] && cp "$f" "$BACKUP_DIR/"
    done
    [ "$(ls -A $BACKUP_DIR 2>/dev/null)" ] && print_success "Backup: $BACKUP_DIR" || rm -rf "$BACKUP_DIR"
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
    cat > phpcs.xml.dist << PHPCS_EOF
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
$(echo -e "$PREFIXES")            </property>
        </properties>
    </rule>

    <rule ref="WordPress.WP.I18n">
        <properties>
            <property name="text_domain" type="array">
$(echo -e "$TEXT_DOMAINS")            </property>
        </properties>
    </rule>

    <!-- Files to check -->
$(echo -e "$FILES")
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
PHPCS_EOF
    
    print_success "phpcs.xml.dist generado"
    
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
ESLINT_EOF
    
    echo "    files: [" >> eslint.config.js
    echo -e "$ESLINT_FILES" | sed '$ s/,$//' >> eslint.config.js
    echo "    ]," >> eslint.config.js
    
    cat >> eslint.config.js << 'ESLINT_RULES'
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
ESLINT_RULES
    
    print_success "eslint.config.js generado"
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
    local has_components=false
    for plugin in "${SELECTED_PLUGINS[@]}"; do
        [ -d "$WP_CONTENT_DIR/plugins/$plugin" ] && has_components=true && break
    done
    for theme in "${SELECTED_THEMES[@]}"; do
        [ -d "$WP_CONTENT_DIR/themes/$theme" ] && has_components=true && break
    done
    
    [ "$has_components" = false ] && {
        print_warning "Advertencia: No se encontraron directorios de componentes"
        print_info "Verifica que los plugins/temas existan en las rutas esperadas"
        read -p "¿Continuar de todos modos? (y/n): " resp
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
    elif [ "$COMPOSER_AVAILABLE" = true ]; then
        print_warning "PHPCBF no encontrado"
        read -p "¿Instalar dependencias de Composer? (y/n): " INSTALL
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
    else
        print_warning "Composer no disponible - omitiendo formateo PHP"
    fi
    
    # ESLint (JavaScript)
    if [ -f "eslint.config.js" ] && command -v npx >/dev/null 2>&1; then
        if [ -d "node_modules" ]; then
            print_info "Formateando código JavaScript con ESLint..."
            echo ""
            npx eslint --fix "**/*.{js,jsx,ts,tsx}" --cache || print_warning "ESLint: revisar warnings"
            echo ""
        else
            print_warning "node_modules no encontrado"
            read -p "¿Instalar dependencias de npm? (y/n): " INSTALL
            [[ $INSTALL =~ ^[Yy]$ ]] && {
                print_info "Instalando dependencias..."
                if npm install; then
                    print_info "Formateando código JavaScript..."
                    npx eslint --fix "**/*.{js,jsx,ts,tsx}" --cache || print_success "JavaScript formateado"
                else
                    print_error "Error al instalar dependencias de npm"
                fi
            }
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

if [ "$CONFIGURE_PROJECT" = true ] && [ ! -d "vendor" ]; then
    echo "1. Instalar dependencias:"
    echo "   ${BLUE}composer install${NC}"
    echo "   ${BLUE}npm install${NC}"
    echo ""
fi

echo "2. Verificar estándares:"
echo "   ${BLUE}./vendor/bin/phpcs --standard=phpcs.xml.dist${NC}"
echo "   ${BLUE}npx eslint '**/*.{js,jsx,ts,tsx}'${NC}"
echo ""

echo "3. Formatear código:"
echo "   ${BLUE}./vendor/bin/phpcbf --standard=phpcs.xml.dist${NC}"
echo "   ${BLUE}npx eslint --fix '**/*.{js,jsx,ts,tsx}'${NC}"
echo ""

print_success "¡Listo para desarrollar con estándares WordPress!"
echo ""

