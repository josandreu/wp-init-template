#!/bin/bash

# ================================================================================================
# WordPress Project Initialization Script
# ================================================================================================
# Inicializa un nuevo proyecto WordPress desde esta plantilla
# 
# Características:
# - Detecta archivos existentes y ofrece opciones
# - 3 modos: Proyecto nuevo, Proyecto existente, Solo estándares
# - Actualización selectiva de archivos
# - Backup automático
# - Compatible macOS y Linux
# ================================================================================================

set -e  # Exit on error
set -o pipefail  # Fail on pipe errors

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Funciones de output
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
print_question() { echo -e "${MAGENTA}❓ $1${NC}"; }

# Banner
clear
echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  🚀 WordPress Project Initialization                           ║"
echo "║  Plantilla con estándares WordPress configurados               ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Verificar que estamos en la raíz del proyecto
if [ ! -f "package.json" ] && [ ! -f "composer.json" ]; then
    print_error "No se encontró package.json ni composer.json"
    print_info "Ejecuta este script desde la raíz del proyecto o un directorio con estos archivos"
    exit 1
fi

# Verificar requisitos
print_info "Verificando requisitos del sistema..."

if ! command -v node >/dev/null 2>&1; then
    print_error "Node.js no está instalado"
    print_info "Instala Node.js desde: https://nodejs.org/"
    exit 1
fi

if ! command -v npm >/dev/null 2>&1; then
    print_error "npm no está instalado"
    exit 1
fi

COMPOSER_AVAILABLE=false
if command -v composer >/dev/null 2>&1; then
    COMPOSER_AVAILABLE=true
    print_success "Composer disponible"
else
    print_warning "Composer no está instalado (recomendado)"
    print_info "Instala desde: https://getcomposer.org/"
fi

print_success "Requisitos verificados"
echo ""

# ================================================================================================
# DETECTAR ARCHIVOS EXISTENTES
# ================================================================================================

echo ""
print_info "Detectando archivos existentes..."

HAS_PACKAGE_JSON=false
HAS_COMPOSER_JSON=false
HAS_PHPCS=false
HAS_ESLINT=false
HAS_MAKEFILE=false

[ -f "package.json" ] && HAS_PACKAGE_JSON=true && print_warning "package.json ya existe"
[ -f "composer.json" ] && HAS_COMPOSER_JSON=true && print_warning "composer.json ya existe"
[ -f "phpcs.xml.dist" ] && HAS_PHPCS=true && print_info "phpcs.xml.dist ya existe"
[ -f "eslint.config.js" ] && HAS_ESLINT=true && print_info "eslint.config.js ya existe"
[ -f "Makefile" ] && HAS_MAKEFILE=true && print_info "Makefile ya existe"

# ================================================================================================
# MODO DE OPERACIÓN
# ================================================================================================

echo "════════════════════════════════════════════════════════════════"
echo "  Modo de Inicialización"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "  1️⃣  Proyecto nuevo          - Plantilla limpia con my-project"
echo "  2️⃣  Proyecto existente      - Reemplazar referencias actuales"
echo "  3️⃣  Solo estándares         - Actualizar solo configuración"
echo "  4️⃣  Añadir estándares       - Añadir archivos config a proyecto existente"
echo ""
read -p "Selecciona modo (1-4): " MODE
echo ""

case $MODE in
    1)
        print_info "Modo: Proyecto nuevo con referencias genéricas"
        OLD_SLUG="my-project"
        ;;
    2)
        print_info "Modo: Proyecto existente - reemplazar referencias"
        ;;
    3)
        print_info "Modo: Solo actualizar estándares de código"
        STANDARDS_ONLY=true
        ;;
    4)
        print_info "Modo: Añadir estándares a proyecto existente"
        ADD_STANDARDS_ONLY=true
        ;;
    *)
        print_error "Opción inválida"
        exit 1
        ;;
esac

# ================================================================================================
# SOLICITAR INFORMACIÓN DEL PROYECTO
# ================================================================================================

if [ "$STANDARDS_ONLY" != "true" ] && [ "$ADD_STANDARDS_ONLY" != "true" ]; then
    echo ""
    echo "════════════════════════════════════════════════════════════════"
    echo "  Configuración del Proyecto"
    echo "════════════════════════════════════════════════════════════════"
    echo ""

    # Detectar slug existente si es modo 2
    if [ "$MODE" = "2" ]; then
        echo "Detectando slug del proyecto existente..."
        if [ -f "package.json" ]; then
            CURRENT_SLUG=$(grep -o '"name": "[^"]*"' package.json | head -1 | cut -d'"' -f4 | sed 's/-wordpress$//')
            print_info "Slug detectado: $CURRENT_SLUG"
            read -p "¿Es correcto? (y/n): " CONFIRM_SLUG
            if [[ ! $CONFIRM_SLUG =~ ^[Yy]$ ]]; then
                read -p "Introduce el slug actual del proyecto: " CURRENT_SLUG
            fi
            OLD_SLUG="$CURRENT_SLUG"
        else
            read -p "Introduce el slug actual del proyecto a reemplazar: " OLD_SLUG
        fi
        echo ""
    fi

    # Nombre del proyecto
    read -p "Nombre del proyecto (ej: mi-proyecto): " PROJECT_NAME
    if [ -z "$PROJECT_NAME" ]; then
        print_error "El nombre del proyecto es obligatorio"
        exit 1
    fi

    # Convertir nombre a diferentes formatos
    PROJECT_SLUG=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
    PROJECT_CONSTANT=$(echo "$PROJECT_NAME" | tr '[:lower:]' '[:upper:]' | tr '-' '_' | tr ' ' '_')
    PROJECT_NAMESPACE=$(echo "$PROJECT_NAME" | sed 's/-/ /g' | sed 's/_/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)}1' | tr -d ' ')

    # URL local
    read -p "URL local de desarrollo (ej: https://local.${PROJECT_SLUG}.com): " LOCAL_URL
    if [ -z "$LOCAL_URL" ]; then
        LOCAL_URL="https://local.${PROJECT_SLUG}.com"
    fi

    # Nombre del theme hijo
    read -p "Nombre del theme hijo (ej: ${PROJECT_SLUG}-theme): " CHILD_THEME_NAME
    if [ -z "$CHILD_THEME_NAME" ]; then
        CHILD_THEME_NAME="${PROJECT_SLUG}-theme"
    fi

    # Nombre del plugin
    read -p "Nombre del plugin de bloques (ej: ${PROJECT_SLUG}-custom-blocks): " PLUGIN_NAME
    if [ -z "$PLUGIN_NAME" ]; then
        PLUGIN_NAME="${PROJECT_SLUG}-custom-blocks"
    fi

    # Text domain
    TEXT_DOMAIN="${PROJECT_SLUG}"

    # Definir OLD_ variables si no están definidas
    if [ "$MODE" = "1" ]; then
        OLD_CONSTANT="MY_PROJECT"
        OLD_NAMESPACE="MyProject"
        OLD_THEME="my-project-theme"
        OLD_PLUGIN="my-project-custom-blocks"
        OLD_URL="https://local.my-project.com"
    else
        OLD_CONSTANT=$(echo "$OLD_SLUG" | tr '[:lower:]' '[:upper:]' | tr '-' '_')
        OLD_NAMESPACE=$(echo "$OLD_SLUG" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)}1' | tr -d ' ')
        OLD_THEME="${OLD_SLUG}-theme"
        OLD_PLUGIN="${OLD_SLUG}-custom-blocks"
        OLD_URL="https://local.${OLD_SLUG}.com"
    fi

    # Resumen
    echo ""
    echo "════════════════════════════════════════════════════════════════"
    echo "  Resumen de la Configuración"
    echo "════════════════════════════════════════════════════════════════"
    echo ""
    echo "Reemplazar: $OLD_SLUG → $PROJECT_SLUG"
    echo "Namespace:  $OLD_NAMESPACE → $PROJECT_NAMESPACE"
    echo "URL local:  $OLD_URL → $LOCAL_URL"
    echo "Theme hijo: $OLD_THEME → $CHILD_THEME_NAME"
    echo "Plugin:     $OLD_PLUGIN → $PLUGIN_NAME"
    echo "Text domain: $TEXT_DOMAIN"
    echo ""

    read -p "¿Confirmar inicialización? (y/n): " CONFIRM
    if [[ ! $CONFIRM =~ ^[Yy]$ ]]; then
        print_warning "Inicialización cancelada"
        exit 0
    fi
fi

# ================================================================================================
# ARCHIVOS OPCIONALES
# ================================================================================================

echo ""
print_info "Selección de archivos a crear/actualizar..."
echo ""

CREATE_MAKEFILE=true
CREATE_README=true
CREATE_GITHOOKS=true
CREATE_CI=true

if [ "$HAS_MAKEFILE" = true ]; then
    read -p "¿Actualizar Makefile existente? (y/n): " resp
    [[ ! $resp =~ ^[Yy]$ ]] && CREATE_MAKEFILE=false
fi

if [ -f "README.md" ]; then
    read -p "¿Actualizar README.md existente? (y/n): " resp
    [[ ! $resp =~ ^[Yy]$ ]] && CREATE_README=false
fi

read -p "¿Configurar Git hooks (Husky)? (y/n): " resp
[[ ! $resp =~ ^[Yy]$ ]] && CREATE_GITHOOKS=false

read -p "¿Crear configuración CI/CD (bitbucket-pipelines.yml)? (y/n): " resp
[[ ! $resp =~ ^[Yy]$ ]] && CREATE_CI=false

# ================================================================================================
# BACKUP
# ================================================================================================

if [ "$STANDARDS_ONLY" != "true" ] && [ "$ADD_STANDARDS_ONLY" != "true" ]; then
    print_info "Creando backup de archivos originales..."
    BACKUP_DIR="./backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP_DIR"

    # Backup de archivos que existen
    [ -f "composer.json" ] && cp composer.json "$BACKUP_DIR/" 2>/dev/null || true
    [ -f "package.json" ] && cp package.json "$BACKUP_DIR/" 2>/dev/null || true
    [ -f "phpcs.xml.dist" ] && cp phpcs.xml.dist "$BACKUP_DIR/" 2>/dev/null || true
    [ -f "phpstan.neon.dist" ] && cp phpstan.neon.dist "$BACKUP_DIR/" 2>/dev/null || true
    [ -f "eslint.config.js" ] && cp eslint.config.js "$BACKUP_DIR/" 2>/dev/null || true
    [ "$CREATE_MAKEFILE" = true ] && [ -f "Makefile" ] && cp Makefile "$BACKUP_DIR/" 2>/dev/null || true
    [ "$CREATE_README" = true ] && [ -f "README.md" ] && cp README.md "$BACKUP_DIR/" 2>/dev/null || true

    print_success "Backup creado en: $BACKUP_DIR"
fi

# ================================================================================================
# ACTUALIZAR ARCHIVOS
# ================================================================================================

echo ""
print_info "Actualizando archivos de configuración..."

# Función helper para sed compatible con macOS y Linux
safe_sed() {
    local pattern="$1"
    local file="$2"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "$pattern" "$file"
    else
        sed -i "$pattern" "$file"
    fi
}

if [ "$STANDARDS_ONLY" != "true" ] && [ "$ADD_STANDARDS_ONLY" != "true" ]; then
    # --- composer.json ---
    if [ -f "composer.json" ]; then
        print_info "Actualizando composer.json..."
        safe_sed "s/${OLD_SLUG}/${PROJECT_SLUG}/g" composer.json
        safe_sed "s/${OLD_NAMESPACE}/${PROJECT_NAMESPACE}/g" composer.json
        print_success "composer.json actualizado"
    fi

    # --- package.json ---
    if [ -f "package.json" ]; then
        print_info "Actualizando package.json..."
        safe_sed "s/${OLD_SLUG}/${PROJECT_SLUG}/g" package.json
        safe_sed "s/${OLD_PLUGIN}/${PLUGIN_NAME}/g" package.json
        safe_sed "s/${OLD_THEME}/${CHILD_THEME_NAME}/g" package.json
        safe_sed "s#${OLD_URL}#${LOCAL_URL}#g" package.json
        print_success "package.json actualizado"
    fi

    # --- phpcs.xml.dist ---
    if [ -f "phpcs.xml.dist" ]; then
        print_info "Actualizando phpcs.xml.dist..."
        safe_sed "s/${OLD_SLUG}_/${PROJECT_SLUG}_/g" phpcs.xml.dist
        safe_sed "s/${OLD_CONSTANT}_/${PROJECT_CONSTANT}_/g" phpcs.xml.dist
        safe_sed "s/${OLD_NAMESPACE}\\\\\\\\/${PROJECT_NAMESPACE}\\\\\\\\/g" phpcs.xml.dist
        safe_sed "s/${OLD_PLUGIN}/${PLUGIN_NAME}/g" phpcs.xml.dist
        safe_sed "s/${OLD_THEME}/${CHILD_THEME_NAME}/g" phpcs.xml.dist
        print_success "phpcs.xml.dist actualizado"
    fi

    # --- phpstan.neon.dist ---
    if [ -f "phpstan.neon.dist" ]; then
        print_info "Actualizando phpstan.neon.dist..."
        safe_sed "s/${OLD_PLUGIN}/${PLUGIN_NAME}/g" phpstan.neon.dist
        safe_sed "s/${OLD_THEME}/${CHILD_THEME_NAME}/g" phpstan.neon.dist
        print_success "phpstan.neon.dist actualizado"
    fi

    # --- eslint.config.js ---
    if [ -f "eslint.config.js" ]; then
        print_info "Actualizando eslint.config.js..."
        safe_sed "s/${OLD_PLUGIN}/${PLUGIN_NAME}/g" eslint.config.js
        safe_sed "s/${OLD_THEME}/${CHILD_THEME_NAME}/g" eslint.config.js
        print_success "eslint.config.js actualizado"
    fi

    # --- Makefile ---
    if [ "$CREATE_MAKEFILE" = true ] && [ -f "Makefile" ]; then
        print_info "Actualizando Makefile..."
        safe_sed "s#${OLD_URL}#${LOCAL_URL}#g" Makefile
        safe_sed "s/${OLD_SLUG}/${PROJECT_SLUG}/g" Makefile
        safe_sed "s/${OLD_PLUGIN}/${PLUGIN_NAME}/g" Makefile
        safe_sed "s/${OLD_THEME}/${CHILD_THEME_NAME}/g" Makefile
        print_success "Makefile actualizado"
    fi

    # --- README.md ---
    if [ "$CREATE_README" = true ] && [ -f "README.md" ]; then
        print_info "Actualizando README.md..."
        safe_sed "s/${OLD_SLUG}/${PROJECT_SLUG}/g" README.md
        safe_sed "s/${OLD_PLUGIN}/${PLUGIN_NAME}/g" README.md
        safe_sed "s/${OLD_THEME}/${CHILD_THEME_NAME}/g" README.md
        safe_sed "s#${OLD_URL}#${LOCAL_URL}#g" README.md
        print_success "README.md actualizado"
    fi
fi

# ================================================================================================
# MODO 4: AÑADIR ESTÁNDARES A PROYECTO EXISTENTE
# ================================================================================================

if [ "$ADD_STANDARDS_ONLY" = "true" ]; then
    echo ""
    print_info "Copiando archivos de configuración de estándares..."
    echo ""
    
    TEMPLATE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    COPIED_FILES=()
    
    # Copiar solo archivos que NO existen
    if [ ! -f "phpcs.xml.dist" ]; then
        cp "$TEMPLATE_DIR/phpcs.xml.dist" .
        COPIED_FILES+=("phpcs.xml.dist")
        print_success "phpcs.xml.dist copiado"
    else
        print_warning "phpcs.xml.dist ya existe - no se sobrescribe"
    fi
    
    if [ ! -f "phpstan.neon.dist" ]; then
        cp "$TEMPLATE_DIR/phpstan.neon.dist" .
        COPIED_FILES+=("phpstan.neon.dist")
        print_success "phpstan.neon.dist copiado"
    else
        print_warning "phpstan.neon.dist ya existe - no se sobrescribe"
    fi
    
    if [ ! -f "eslint.config.js" ]; then
        cp "$TEMPLATE_DIR/eslint.config.js" .
        COPIED_FILES+=("eslint.config.js")
        print_success "eslint.config.js copiado"
    else
        print_warning "eslint.config.js ya existe - no se sobrescribe"
    fi
    
    if [ ! -f "commitlint.config.cjs" ]; then
        cp "$TEMPLATE_DIR/commitlint.config.cjs" .
        COPIED_FILES+=("commitlint.config.cjs")
        print_success "commitlint.config.cjs copiado"
    else
        print_warning "commitlint.config.cjs ya existe - no se sobrescribe"
    fi
    
    if [ ! -f ".gitignore" ]; then
        if [ -f "$TEMPLATE_DIR/.gitignore.template" ]; then
            cp "$TEMPLATE_DIR/.gitignore.template" .gitignore
            COPIED_FILES+=(".gitignore")
            print_success ".gitignore copiado"
        fi
    else
        print_info ".gitignore ya existe"
    fi
    
    # ========================================
    # FUSIONAR package.json
    # ========================================
    
    if [ -f "package.json" ]; then
        echo ""
        print_info "Actualizando package.json existente..."
        
        # Verificar si jq está disponible
        HAS_JQ=false
        if command -v jq >/dev/null 2>&1; then
            HAS_JQ=true
        fi
        
        if [ "$HAS_JQ" = true ]; then
            # Merge automático con jq
            print_info "jq detectado - haciendo merge automático..."
            
            # Backup
            cp package.json package.json.backup
            
            # Añadir devDependencies
            jq '.devDependencies += {
              "@wordpress/eslint-plugin": "^22.14.0",
              "@wordpress/prettier-config": "^4.11.0",
              "@wordpress/stylelint-config": "^20.0.2",
              "eslint": "^9.33.0",
              "husky": "^9.1.7",
              "lint-staged": "^15.3.0",
              "npm-run-all": "^4.1.5",
              "prettier": "^3.4.2",
              "stylelint": "^14.16.1",
              "@commitlint/cli": "^19.8.1",
              "@commitlint/config-conventional": "^19.8.1"
            } | with_entries(select(.value != null))' package.json > package.json.tmp
            
            # Añadir scripts esenciales
            jq '.scripts += {
              "lint:php": "./vendor/bin/phpcs --standard=phpcs.xml.dist",
              "lint:php:fix": "./vendor/bin/phpcbf --standard=phpcs.xml.dist",
              "lint:js": "eslint \"**/*.{js,jsx,ts,tsx}\" --max-warnings=0 --cache",
              "lint:js:fix": "eslint \"**/*.{js,jsx,ts,tsx}\" --fix --cache",
              "lint:css": "stylelint \"**/*.{css,scss}\" --cache",
              "lint:css:fix": "stylelint \"**/*.{css,scss}\" --fix --cache",
              "format:js": "prettier --write \"**/*.{js,jsx,ts,tsx,json,md}\" --cache",
              "format:css": "prettier --write \"**/*.{css,scss}\" --cache",
              "format:all": "npm-run-all format:js format:css lint:php:fix",
              "prepare": "husky install",
              "test:standards": "npm-run-all lint:js lint:css lint:php"
            } | with_entries(select(.value != null))' package.json.tmp > package.json
            
            # Añadir lint-staged si no existe
            if ! jq -e '.["lint-staged"]' package.json > /dev/null 2>&1; then
                jq '. + {
                  "lint-staged": {
                    "**/*.{js,jsx,ts,tsx}": [
                      "eslint --fix --cache --max-warnings=0",
                      "prettier --write --cache"
                    ],
                    "**/*.{css,scss}": [
                      "stylelint --fix --cache",
                      "prettier --write --cache"
                    ],
                    "**/*.php": [
                      "./vendor/bin/phpcbf --standard=phpcs.xml.dist",
                      "./vendor/bin/phpcs --standard=phpcs.xml.dist"
                    ],
                    "*.{json,md,yml,yaml}": [
                      "prettier --write --cache"
                    ]
                  }
                }' package.json > package.json.tmp && mv package.json.tmp package.json
            fi
            
            rm -f package.json.tmp
            print_success "package.json actualizado (backup: package.json.backup)"
        else
            # Sin jq - crear archivo de ayuda
            print_warning "jq no está disponible - creando archivo de referencia..."
            
            cat > package.json.additions << 'EOF'
// ========================================
// AÑADIR A package.json
// ========================================

// 1. En "devDependencies":
{
  "@wordpress/eslint-plugin": "^22.14.0",
  "@wordpress/prettier-config": "^4.11.0",
  "@wordpress/stylelint-config": "^20.0.2",
  "eslint": "^9.33.0",
  "husky": "^9.1.7",
  "lint-staged": "^15.3.0",
  "npm-run-all": "^4.1.5",
  "prettier": "^3.4.2",
  "stylelint": "^14.16.1",
  "@commitlint/cli": "^19.8.1",
  "@commitlint/config-conventional": "^19.8.1"
}

// 2. En "scripts":
{
  "lint:php": "./vendor/bin/phpcs --standard=phpcs.xml.dist",
  "lint:php:fix": "./vendor/bin/phpcbf --standard=phpcs.xml.dist",
  "lint:js": "eslint '**/*.{js,jsx,ts,tsx}' --max-warnings=0 --cache",
  "lint:js:fix": "eslint '**/*.{js,jsx,ts,tsx}' --fix --cache",
  "lint:css": "stylelint '**/*.{css,scss}' --cache",
  "lint:css:fix": "stylelint '**/*.{css,scss}' --fix --cache",
  "format:js": "prettier --write '**/*.{js,jsx,ts,tsx,json,md}' --cache",
  "format:css": "prettier --write '**/*.{css,scss}' --cache",
  "format:all": "npm-run-all format:js format:css lint:php:fix",
  "prepare": "husky install",
  "test:standards": "npm-run-all lint:js lint:css lint:php"
}

// 3. Añadir configuración "lint-staged":
{
  "lint-staged": {
    "**/*.{js,jsx,ts,tsx}": [
      "eslint --fix --cache --max-warnings=0",
      "prettier --write --cache"
    ],
    "**/*.{css,scss}": [
      "stylelint --fix --cache",
      "prettier --write --cache"
    ],
    "**/*.php": [
      "./vendor/bin/phpcbf --standard=phpcs.xml.dist",
      "./vendor/bin/phpcs --standard=phpcs.xml.dist"
    ],
    "*.{json,md,yml,yaml}": [
      "prettier --write --cache"
    ]
  }
}
EOF
            print_success "Archivo creado: package.json.additions"
            print_info "Revisa y añade manualmente las dependencias y scripts"
        fi
    fi
    
    # ========================================
    # FUSIONAR composer.json
    # ========================================
    
    if [ -f "composer.json" ]; then
        echo ""
        print_info "Actualizando composer.json existente..."
        
        if [ "$HAS_JQ" = true ]; then
            # Merge automático con jq
            print_info "Haciendo merge automático de composer.json..."
            
            # Backup
            cp composer.json composer.json.backup
            
            # Añadir require-dev
            jq '."require-dev" += {
              "dealerdirect/phpcodesniffer-composer-installer": "^1.0",
              "php-stubs/wordpress-stubs": "^6.2",
              "phpcsstandards/phpcsextra": "^1.4",
              "phpcsstandards/phpcsutils": "^1.1",
              "phpstan/phpstan": "^2.0",
              "szepeviktor/phpstan-wordpress": "^1.3",
              "wp-coding-standards/wpcs": "^3.2"
            } | with_entries(select(.value != null))' composer.json > composer.json.tmp
            
            # Añadir scripts
            jq '.scripts += {
              "lint": "phpcs --standard=phpcs.xml.dist",
              "lint:fix": "phpcbf --standard=phpcs.xml.dist",
              "analyze": "phpstan analyse --no-progress",
              "test": "phpcs && phpstan analyse"
            } | with_entries(select(.value != null))' composer.json.tmp > composer.json
            
            rm -f composer.json.tmp
            print_success "composer.json actualizado (backup: composer.json.backup)"
        else
            # Sin jq - crear archivo de ayuda
            print_warning "Creando archivo de referencia para composer.json..."
            
            cat > composer.json.additions << 'EOF'
// ========================================
// AÑADIR A composer.json
// ========================================

// 1. En "require-dev":
{
  "dealerdirect/phpcodesniffer-composer-installer": "^1.0",
  "php-stubs/wordpress-stubs": "^6.2",
  "phpcsstandards/phpcsextra": "^1.4",
  "phpcsstandards/phpcsutils": "^1.1",
  "phpstan/phpstan": "^2.0",
  "szepeviktor/phpstan-wordpress": "^1.3",
  "wp-coding-standards/wpcs": "^3.2"
}

// 2. En "scripts":
{
  "lint": "phpcs --standard=phpcs.xml.dist",
  "lint:fix": "phpcbf --standard=phpcs.xml.dist",
  "analyze": "phpstan analyse --no-progress",
  "test": "phpcs && phpstan analyse"
}
EOF
            print_success "Archivo creado: composer.json.additions"
            print_info "Revisa y añade manualmente las dependencias y scripts"
        fi
    fi
    
    # ========================================
    # RESUMEN MODO 4
    # ========================================
    
    echo ""
    echo "════════════════════════════════════════════════════════════════"
    echo "  ✅ Archivos de Configuración Añadidos"
    echo "════════════════════════════════════════════════════════════════"
    echo ""
    
    if [ ${#COPIED_FILES[@]} -gt 0 ]; then
        print_info "Archivos copiados:"
        for file in "${COPIED_FILES[@]}"; do
            echo "  ✅ $file"
        done
        echo ""
    fi
    
    if [ "$HAS_JQ" = true ]; then
        print_success "package.json y composer.json actualizados automáticamente"
        print_info "Se crearon backups: package.json.backup y composer.json.backup"
    else
        print_warning "Instala 'jq' para merge automático: brew install jq"
        print_info "Archivos de referencia creados:"
        echo "  📄 package.json.additions"
        echo "  📄 composer.json.additions"
    fi
    
    echo ""
    print_info "Próximos pasos:"
    echo "  1. Instalar dependencias: npm install && composer install"
    echo "  2. Configurar Husky: npm run prepare"
    echo "  3. Verificar estándares: npm run lint:js && npm run lint:php"
    echo ""
fi

# ================================================================================================
# CREAR ARCHIVO DE CONFIGURACIÓN
# ================================================================================================

if [ "$STANDARDS_ONLY" != "true" ] && [ "$ADD_STANDARDS_ONLY" != "true" ]; then
    print_info "Creando archivo de configuración del proyecto..."

    cat > .project-config << EOF
# Configuración del Proyecto WordPress
# Generado automáticamente por init-project.sh
# Fecha: $(date +%Y-%m-%d\ %H:%M:%S)

PROJECT_NAME="$PROJECT_NAME"
PROJECT_SLUG="$PROJECT_SLUG"
PROJECT_CONSTANT="$PROJECT_CONSTANT"
PROJECT_NAMESPACE="$PROJECT_NAMESPACE"
LOCAL_URL="$LOCAL_URL"
CHILD_THEME_NAME="$CHILD_THEME_NAME"
PLUGIN_NAME="$PLUGIN_NAME"
TEXT_DOMAIN="$TEXT_DOMAIN"

# Slug anterior (para referencia)
OLD_SLUG="$OLD_SLUG"

# URLs de entornos
STAGING_URL="https://dev.${PROJECT_SLUG}.levelstage.com"
PRODUCTION_URL="https://${PROJECT_SLUG}.com"
EOF

    print_success "Archivo .project-config creado"
fi

# ================================================================================================
# RESUMEN FINAL
# ================================================================================================

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "  🎉 ¡Inicialización Completada!"
echo "════════════════════════════════════════════════════════════════"
echo ""

if [ "$STANDARDS_ONLY" = "true" ]; then
    print_success "Estándares de código actualizados"
elif [ "$ADD_STANDARDS_ONLY" = "true" ]; then
    print_success "Estándares añadidos al proyecto existente"
    echo ""
    print_info "Tu proyecto ahora incluye:"
    [ -f "phpcs.xml.dist" ] && echo "  • phpcs.xml.dist (WordPress PHP Standards)"
    [ -f "phpstan.neon.dist" ] && echo "  • phpstan.neon.dist (PHP Static Analysis)"
    [ -f "eslint.config.js" ] && echo "  • eslint.config.js (WordPress JS Standards)"
    [ -f "commitlint.config.cjs" ] && echo "  • commitlint.config.cjs (Conventional Commits)"
    [ -f "package.json.backup" ] && echo "  • package.json (fusionado con backup creado)"
    [ -f "composer.json.backup" ] && echo "  • composer.json (fusionado con backup creado)"
else
    print_success "Proyecto '$PROJECT_NAME' configurado correctamente"
    echo ""
    print_info "Archivos actualizados:"
    [ -f "composer.json" ] && echo "  • composer.json"
    [ -f "package.json" ] && echo "  • package.json"
    [ -f "phpcs.xml.dist" ] && echo "  • phpcs.xml.dist (WordPress PHP Standards)"
    [ -f "phpstan.neon.dist" ] && echo "  • phpstan.neon.dist (PHP Static Analysis)"
    [ -f "eslint.config.js" ] && echo "  • eslint.config.js (WordPress JS Standards)"
    [ "$CREATE_MAKEFILE" = true ] && [ -f "Makefile" ] && echo "  • Makefile"
    [ "$CREATE_README" = true ] && [ -f "README.md" ] && echo "  • README.md"
    echo ""
    [ -f ".project-config" ] && print_info "Configuración guardada en: .project-config"
    [ -d "$BACKUP_DIR" ] && print_info "Backup de archivos originales en: $BACKUP_DIR"
fi

echo ""
echo "════════════════════════════════════════════════════════════════"
echo "  📋 Próximos Pasos"
echo "════════════════════════════════════════════════════════════════"
echo ""

if [ ! -d "node_modules" ]; then
    echo "1. Instalar dependencias:"
    echo "   ${BLUE}make install${NC} o ${BLUE}npm install${NC}"
    echo ""
fi

echo "2. Formatear código según estándares WordPress:"
echo "   ${BLUE}make format${NC}"
echo ""
echo "3. Verificar estándares de código:"
echo "   ${BLUE}make test${NC}"
echo ""
echo "4. Iniciar desarrollo:"
echo "   ${BLUE}make dev${NC}"
echo ""

print_success "¡Listo para comenzar el desarrollo!"
echo ""
