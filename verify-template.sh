#!/bin/bash

# ================================================================================================
# WordPress Template Verification Script
# ================================================================================================
# Verifica que esta plantilla esté lista para ser usada en un nuevo proyecto
# ================================================================================================

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  WordPress Template Verification                               ║"
echo "║  Verificando que la plantilla esté lista para uso             ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

ERRORS=0
WARNINGS=0

# Verificar archivos esenciales
print_info "Verificando archivos esenciales..."

ESSENTIAL_FILES=(
    "package.json"
    "composer.json"
    "phpcs.xml.dist"
    "phpstan.neon.dist"
    "eslint.config.js"
    "Makefile"
    "README.md"
    "setup.sh"
    "init-project.sh"
    "INIT-GUIDE.md"
    "commitlint.config.cjs"
)

for file in "${ESSENTIAL_FILES[@]}"; do
    if [ -f "$file" ]; then
        print_success "Archivo $file existe"
    else
        print_error "Archivo $file NO encontrado"
        ((ERRORS++))
    fi
done

# Verificar que init-project.sh sea ejecutable
if [ -x "init-project.sh" ]; then
    print_success "init-project.sh es ejecutable"
else
    print_warning "init-project.sh no es ejecutable (se puede corregir con: chmod +x init-project.sh)"
    ((WARNINGS++))
fi

# Verificar estructura de archivos de configuración
echo ""
print_info "Verificando archivos de configuración..."

# Verificar phpcs.xml.dist
if grep -q "WordPress" phpcs.xml.dist 2>/dev/null; then
    print_success "phpcs.xml.dist tiene configuración WordPress"
else
    print_error "phpcs.xml.dist no tiene configuración WordPress correcta"
    ((ERRORS++))
fi

# Verificar eslint.config.js
if grep -q "WordPress" eslint.config.js 2>/dev/null; then
    print_success "eslint.config.js tiene configuración WordPress"
else
    print_error "eslint.config.js no tiene configuración WordPress correcta"
    ((ERRORS++))
fi

# Verificar package.json
if grep -q "scripts" package.json 2>/dev/null; then
    print_success "package.json tiene scripts configurados"
else
    print_error "package.json no tiene scripts"
    ((ERRORS++))
fi

# Verificar composer.json
if grep -q "require-dev" composer.json 2>/dev/null; then
    print_success "composer.json tiene dependencias dev"
else
    print_error "composer.json no tiene dependencias dev"
    ((ERRORS++))
fi

# Verificar Node.js y npm
echo ""
print_info "Verificando requisitos del sistema..."

if command -v node >/dev/null 2>&1; then
    NODE_VERSION=$(node --version)
    print_success "Node.js instalado: $NODE_VERSION"
    
    # Verificar versión mínima
    NODE_MAJOR=$(echo $NODE_VERSION | cut -d'.' -f1 | sed 's/v//')
    if [ "$NODE_MAJOR" -lt 18 ]; then
        print_warning "Node.js < 18 (recomendado >= 18.0.0)"
        ((WARNINGS++))
    fi
else
    print_error "Node.js no está instalado"
    ((ERRORS++))
fi

if command -v npm >/dev/null 2>&1; then
    NPM_VERSION=$(npm --version)
    print_success "npm instalado: v$NPM_VERSION"
else
    print_error "npm no está instalado"
    ((ERRORS++))
fi

if command -v composer >/dev/null 2>&1; then
    print_success "Composer instalado"
else
    print_warning "Composer no está instalado (recomendado)"
    ((WARNINGS++))
fi

# Verificar que no haya node_modules instalados (plantilla limpia)
echo ""
print_info "Verificando estado de la plantilla..."

if [ -d "node_modules" ]; then
    print_warning "node_modules existe (la plantilla debería estar limpia)"
    print_info "Puedes eliminarlos con: rm -rf node_modules"
    ((WARNINGS++))
else
    print_success "Sin node_modules (plantilla limpia)"
fi

if [ -d "vendor" ]; then
    print_warning "vendor existe (la plantilla debería estar limpia)"
    print_info "Puedes eliminarlos con: rm -rf vendor"
    ((WARNINGS++))
else
    print_success "Sin vendor (plantilla limpia)"
fi

# Verificar archivos de ejemplo
echo ""
print_info "Verificando archivos de ejemplo y documentación..."

if [ -f ".project-config.example" ]; then
    print_success "Archivo .project-config.example existe"
else
    print_warning "Archivo .project-config.example no encontrado"
    ((WARNINGS++))
fi

if [ -f ".gitignore.template" ]; then
    print_success "Archivo .gitignore.template existe"
else
    print_warning "Archivo .gitignore.template no encontrado"
    ((WARNINGS++))
fi

if [ -f "INIT-GUIDE.md" ]; then
    print_success "Guía de inicialización existe"
else
    print_error "INIT-GUIDE.md no encontrada"
    ((ERRORS++))
fi

# Verificar que los scripts .sh tengan permisos de ejecución
echo ""
print_info "Verificando permisos de scripts..."

SCRIPTS=(
    "setup.sh"
    "init-project.sh"
    "check-setup.sh"
    "test-precommit.sh"
)

for script in "${SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        if [ -x "$script" ]; then
            print_success "$script es ejecutable"
        else
            print_warning "$script no es ejecutable"
            print_info "Corregir con: chmod +x $script"
            ((WARNINGS++))
        fi
    fi
done

# Resumen final
echo ""
echo "════════════════════════════════════════════════════════════════"
echo "  Resumen de Verificación"
echo "════════════════════════════════════════════════════════════════"
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    print_success "Plantilla perfectamente configurada y lista para usar"
    echo ""
    print_info "Próximos pasos:"
    echo "  1. Ejecutar: ./init-project.sh"
    echo "  2. Seguir las instrucciones del script"
    echo "  3. Consultar INIT-GUIDE.md para más información"
    echo ""
    exit 0
elif [ $ERRORS -eq 0 ]; then
    print_warning "Plantilla funcional con $WARNINGS advertencias"
    echo ""
    print_info "La plantilla puede usarse, pero revisa las advertencias arriba"
    echo ""
    exit 0
else
    print_error "Plantilla tiene $ERRORS errores y $WARNINGS advertencias"
    echo ""
    print_info "Corrige los errores antes de usar la plantilla"
    echo ""
    exit 1
fi
