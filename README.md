# WordPress Init Template

> **Plantilla profesional de WordPress con configuración automática de estándares de código, linting, formateo y herramientas de desarrollo**

[![WordPress](https://img.shields.io/badge/WordPress-6.5+-blue.svg)](https://wordpress.org/)
[![PHP](https://img.shields.io/badge/PHP-8.1+-purple.svg)](https://www.php.net/)
[![Node](https://img.shields.io/badge/Node-18+-green.svg)](https://nodejs.org/)
[![License](https://img.shields.io/badge/License-GPL--2.0-blue.svg)](LICENSE)

## 🎯 Características Principales

### Configuración y Estándares

- 🔍 **Detección automática** - Identifica plugins y temas personalizados
- ⚙️ **Configuración dinámica** - Genera archivos de configuración basados en tu proyecto
- 🎨 **Formateo automático** - Aplica WordPress Coding Standards (PHP, JS, CSS)
- ✅ **Linting completo** - PHPCS, PHPStan, ESLint, Stylelint, Prettier
- 📊 **Análisis estático** - PHPStan Level 5 con WordPress stubs
- 🔄 **Múltiples modos** - Configurar, formatear, actualizar o fusionar

### Desarrollo y Automatización

- 🚀 **Scripts NPM optimizados** - Más de 100 comandos para desarrollo
- 🎯 **Makefile completo** - Atajos para tareas comunes
- 🔗 **Git Hooks** - Pre-commit automático con Husky y lint-staged
- 📦 **Build optimizado** - Webpack con hot reload y análisis de bundles
- 🧪 **Testing integrado** - Jest, Playwright, Lighthouse CI
- 🔒 **Seguridad** - Auditorías automáticas de dependencias

## 🚀 Inicio Rápido

### Para Proyecto Nuevo

```bash
# 1. Clona la plantilla
git clone https://github.com/tu-usuario/wp-init.git mi-proyecto
cd mi-proyecto

# 2. Ejecuta el script de inicialización
./init-project.sh
# Selecciona: Modo 1 (Proyecto nuevo)

# 3. Instala dependencias
npm install
composer install

# 4. ¡Listo para desarrollar!
make dev
```

### Para Proyecto Existente

```bash
# 1. Clona la plantilla en una ubicación separada
git clone https://github.com/tu-usuario/wp-init.git ~/plantillas/wp-init

# 2. Navega a tu proyecto existente
cd /ruta/a/tu/proyecto

# 3. Ejecuta el script desde la plantilla
~/plantillas/wp-init/init-project.sh
# Selecciona: Modo 4 (Fusionar configuración)

# 4. Instala nuevas dependencias
npm install
composer install
```

## 🎮 Modos de Operación

El script `init-project.sh` ofrece diferentes modos según tu caso de uso:

### Modo 1: Proyecto Nuevo Completo

**Cuándo usar**: Inicias un proyecto WordPress desde cero.

**Acciones**:

- Crea estructura completa de directorios
- Genera `package.json` y `composer.json` completos
- Configura todos los archivos de estándares
- Crea Makefile personalizado
- Configura Git hooks

### Modo 2: Cambiar Referencias

**Cuándo usar**: Adaptas un proyecto existente para otro cliente.

**Acciones**:

- Reemplaza nombres de proyecto en todos los archivos
- Actualiza namespaces y constantes PHP
- Modifica text domains de i18n
- Actualiza URLs en configuración

### Modo 3: Actualizar Reglas

**Cuándo usar**: Solo quieres actualizar archivos de linting.

**Acciones**:

- Actualiza `phpcs.xml.dist`
- Actualiza `eslint.config.js`
- Actualiza `phpstan.neon.dist`
- Mantiene tus `package.json` y `composer.json`

### Modo 4: Fusionar Configuración (Recomendado)

**Cuándo usar**: Proyecto existente con sus propias dependencias.

**Acciones**:

- Fusiona `package.json` (mantiene tus scripts y dependencias)
- Fusiona `composer.json` (añade herramientas de linting)
- Crea backups automáticos
- Copia archivos de configuración
- **Requiere**: `jq` instalado (`brew install jq`)

## 🔍 Cómo Funciona

### 1. Detección Inteligente

El script analiza tu proyecto WordPress:

**Estructura WordPress**:

- Detecta `wordpress/wp-content/` o `wp-content/`
- Identifica plugins, temas y mu-plugins

**Componentes Personalizados**:

- **Plugins**: Excluye Akismet, Hello Dolly, etc.
- **Temas**: Excluye temas Twenty\* de WordPress
- **MU-Plugins**: Detecta directorios en `mu-plugins/`

**Configuración Existente**:

- Lee `composer.json` y `package.json` si existen
- Detecta nombre del proyecto automáticamente
- Preserva configuración personalizada en Modo 4

### 2. Configuración Interactiva

Selección de componentes:

```bash
¿Incluir plugin 'mi-plugin-custom'? (y/n): y
¿Incluir tema 'mi-tema'? (y/n): y
```

Detección de nombre:

```bash
Detectado desde composer.json: mi-proyecto
¿Usar este nombre? (y/n): y
```

### 3. Generación de Archivos

**Archivos de Linting**:

- `phpcs.xml.dist` - WordPress PHP Coding Standards
- `phpstan.neon.dist` - Análisis estático PHP Level 5
- `eslint.config.js` - WordPress JavaScript Coding Standards
- `commitlint.config.cjs` - Conventional Commits

**Archivos de Configuración**:

- `package.json` - Scripts NPM y dependencias
- `composer.json` - Dependencias PHP y herramientas
- `Makefile` - Comandos de desarrollo
- `.vscode/settings.json` - Configuración VSCode

**Configuración Dinámica**:

- Prefixes: `mi_plugin_`, `MI_PLUGIN_`, `MiPlugin\`
- Text domains: `mi-plugin`, `mi-tema`
- Rutas específicas a tus componentes

## 💡 Casos de Uso

### Caso 1: Nuevo Proyecto WordPress

```bash
# Clonar plantilla
git clone https://github.com/tu-usuario/wp-init.git mi-proyecto
cd mi-proyecto

# Inicializar
./init-project.sh  # Modo 1

# Instalar dependencias
make install

# Iniciar desarrollo
make dev
```

### Caso 2: Añadir Estándares a Proyecto Existente

```bash
# Desde tu proyecto existente
cd /ruta/a/tu/proyecto

# Ejecutar script de plantilla
~/plantillas/wp-init/init-project.sh  # Modo 4

# Instalar nuevas dependencias
npm install && composer install

# Verificar estándares
make lint
```

### Caso 3: Adaptar Proyecto para Nuevo Cliente

```bash
# Copiar proyecto base
cp -r proyecto-base proyecto-nuevo-cliente
cd proyecto-nuevo-cliente

# Cambiar referencias
./init-project.sh  # Modo 2
# Ingresa nuevo nombre: nuevo-cliente

# Verificar cambios
git diff
```

### Caso 4: Actualizar Solo Reglas de Linting

```bash
# Desde tu proyecto
cd /ruta/a/tu/proyecto

# Actualizar reglas
~/plantillas/wp-init/init-project.sh  # Modo 3

# Formatear código con nuevas reglas
make format
```

## 📦 Archivos y Configuración

### Archivos de Linting

#### `phpcs.xml.dist`

- WordPress Coding Standards (WPCS 3.2+)
- Validación de prefixes globales
- Validación de text domains i18n
- Exclusiones: `node_modules/`, `vendor/`, `build/`
- Configuración paralela (8 hilos)

#### `phpstan.neon.dist`

- Level 5 de análisis estático
- WordPress stubs incluidos
- Paths específicos de componentes
- Ignora errores comunes de WordPress

#### `eslint.config.js`

- ESLint 9+ flat config
- WordPress JavaScript Coding Standards
- Espaciado estilo WordPress
- Globals: `wp`, `jQuery`, `$`, `__`

#### `commitlint.config.cjs`

- Conventional Commits
- Tipos: feat, fix, docs, style, refactor, test, chore
- Validación automática en pre-commit

### Archivos de Dependencias

#### `package.json`

- **Scripts**: 100+ comandos NPM organizados
- **DevDependencies**: ESLint, Stylelint, Prettier, Husky
- **Lint-staged**: Formateo automático en pre-commit
- **Engines**: Node >= 18.0.0, npm >= 8.0.0

#### `composer.json`

- **Require-dev**: PHPCS, PHPStan, WordPress stubs
- **Scripts**: Linting y análisis PHP
- **Config**: Instalación automática de WPCS

### Herramientas de Desarrollo

#### `Makefile`

- 50+ comandos para desarrollo
- Atajos para tareas comunes
- Comandos de CI/CD
- Gestión de base de datos
- Lighthouse y testing

#### `.vscode/`

- `settings.json` - Configuración de editor
- `extensions.json` - Extensiones recomendadas
- Formateo automático al guardar
- Integración con PHPCS

## 🛠️ Comandos Disponibles

### Comandos Make (Recomendado)

```bash
# Desarrollo
make dev              # Inicia desarrollo con hot reload
make dev-blocks       # Solo bloques Gutenberg
make dev-theme        # Solo tema principal

# Linting y Formateo
make lint             # Verifica estándares (PHP, JS, CSS)
make format           # Formatea todo el código
make fix              # Alias de format

# Testing
make test             # Tests completos
make quick            # Verificación rápida
make commit-ready     # Verifica antes de commit

# Build
make build            # Build de producción optimizado

# Utilidades
make clean            # Limpia caches y temporales
make health           # Verifica salud del proyecto
make status           # Estado actual del proyecto

# Base de datos
make db-backup        # Backup de base de datos
make db-pull          # Pull desde staging
make db-push          # Push a staging

# Lighthouse
make lighthouse-local    # Análisis local
make lighthouse-preprod  # Análisis preprod

# Ver todos los comandos
make help
```

### Scripts NPM

```bash
# Linting
npm run lint:js       # Lint JavaScript
npm run lint:css      # Lint CSS/SCSS
npm run lint:php      # Lint PHP

# Formateo
npm run format:all    # Formatea todo
npm run lint:js:fix   # Fix JavaScript
npm run lint:css:fix  # Fix CSS
npm run lint:php:fix  # Fix PHP

# Análisis
npm run analyze:php   # PHPStan
npm run analyze:security  # Auditoría de seguridad
npm run analyze:bundle-size  # Tamaño de bundles

# Build
npm run build:all     # Build completo
npm run build:blocks  # Solo bloques
npm run build:themes  # Solo temas

# Desarrollo
npm run dev:all       # Desarrollo paralelo
npm run dev:blocks    # Solo bloques
npm run dev:theme     # Solo tema

# Verificación
npm run verify:standards  # Verifica todo
npm run quick-check      # Verificación rápida

# Cache
npm run cache:clear   # Limpia todos los caches
```

### Comandos Composer

```bash
# Linting PHP
composer run lint:php
composer run lint:php:fix

# Análisis estático
composer run analyze:php

# Test completo
composer run test:php
```

### Comandos Directos

```bash
# PHPCS
./vendor/bin/phpcs --standard=phpcs.xml.dist
./vendor/bin/phpcbf --standard=phpcs.xml.dist

# PHPStan
./vendor/bin/phpstan analyse

# ESLint
npx eslint '**/*.{js,jsx,ts,tsx}'
npx eslint --fix '**/*.{js,jsx,ts,tsx}'

# Stylelint
npx stylelint '**/*.{css,scss}'
npx stylelint --fix '**/*.{css,scss}'

# Prettier
npx prettier --write '**/*.{js,jsx,ts,tsx,css,scss}'
```

## 📚 Requisitos

### Obligatorios

- **Node.js** >= 18.0.0
- **npm** >= 8.0.0
- **Composer** >= 2.0
- **PHP** >= 8.1
- Proyecto WordPress con estructura `wordpress/wp-content/` o `wp-content/`

### Recomendados

- **Git** - Para control de versiones y hooks
- **jq** - Para fusión de JSON en Modo 4 (`brew install jq`)
- **Make** - Para usar comandos del Makefile
- **WP-CLI** - Para gestión de WordPress
- **Docker** - Para entorno de desarrollo local

### Extensiones VSCode Recomendadas

- **PHP Intelephense** - Autocompletado PHP
- **PHPSAB** - Integración PHPCS
- **ESLint** - Linting JavaScript
- **Stylelint** - Linting CSS
- **Prettier** - Formateo de código
- **EditorConfig** - Consistencia de código

## 🔧 Instalación

### Instalación Completa

```bash
# Instalar todo (recomendado)
make install
```

Esto instala:

- Dependencias raíz (npm + composer)
- Dependencias del plugin de bloques
- Dependencias de temas
- Git hooks (Husky)

### Instalación Manual

```bash
# Dependencias raíz
npm install
composer install

# Plugin de bloques
cd wordpress/wp-content/plugins/mi-proyecto-custom-blocks
npm install && composer install

# Tema principal
cd wordpress/wp-content/themes/mi-proyecto-theme
npm install && composer install

# Tema starter
cd wordpress/wp-content/themes/flat101-starter-theme
npm install && composer install

# Git hooks
npm run prepare
```

### Verificar Instalación

```bash
# Verificar estado
make status

# Verificar salud del proyecto
make health

# Verificar dependencias desactualizadas
make check-deps
```

## 📋 Estructura del Proyecto

```text
mi-proyecto/
├── wordpress/                   # WordPress core
│   └── wp-content/
│       ├── plugins/
│       │   └── mi-proyecto-custom-blocks/  # Plugin de bloques Gutenberg
│       │       ├── src/
│       │       ├── build/
│       │       ├── package.json
│       │       ├── composer.json
│       │       └── webpack.config.js
│       ├── themes/
│       │   ├── flat101-starter-theme/      # Tema base
│       │   │   ├── assets/src/
│       │   │   ├── assets/build/
│       │   │   ├── inc/
│       │   │   └── package.json
│       │   └── mi-proyecto-theme/          # Tema hijo personalizado
│       │       ├── assets/src/
│       │       ├── assets/build/
│       │       ├── inc/
│       │       ├── package.json
│       │       └── composer.json
│       └── mu-plugins/          # Must-use plugins
│
├── sh/                          # Scripts de shell
│   ├── deploy/                  # Scripts de deployment
│   └── wp/                      # Scripts de WordPress
│
├── backups/                     # Backups de DB y archivos
├── reports/                     # Reportes de Lighthouse, etc.
│
├── .vscode/                     # Configuración VSCode
│   ├── settings.json
│   └── extensions.json
│
├── .husky/                      # Git hooks
│   └── pre-commit
│
├── init-project.sh              # Script de inicialización
├── verify-template.sh           # Verificación de plantilla
├── Makefile                     # Comandos de desarrollo
│
├── phpcs.xml.dist               # WordPress PHP Standards
├── phpstan.neon.dist            # PHP Static Analysis
├── eslint.config.js             # WordPress JS Standards
├── commitlint.config.cjs        # Conventional Commits
├── lighthouserc.js              # Lighthouse CI
│
├── package.json                 # Dependencias y scripts NPM
├── composer.json                # Dependencias PHP
│
├── .gitignore.template          # Template de .gitignore
├── .project-config.example      # Ejemplo de configuración
│
├── README.md                    # Documentación principal
└── GUIA-RAPIDA.md              # Guía rápida de uso
```

## 🎯 Estándares y Convenciones

### PHP (PHPCS + PHPStan)

**WordPress Coding Standards**:

- Indentación: Tabs (4 espacios)
- Funciones: `snake_case` con prefix
- Clases: `PascalCase`
- Constantes: `UPPER_SNAKE_CASE` con prefix
- Namespaces: `PascalCase\SubNamespace`
- Prefixes obligatorios: `mi_proyecto_`, `MI_PROYECTO_`, `MiProyecto\`

**PHPStan Level 5**:

- Análisis estático de tipos
- Detección de errores potenciales
- WordPress stubs incluidos
- Ignora errores comunes de WordPress

**Documentación**:

- DocBlocks obligatorios en funciones públicas
- `@param`, `@return`, `@throws` documentados
- Hooks documentados con `@action` y `@filter`

### JavaScript (ESLint + Prettier)

**WordPress JavaScript Coding Standards**:

- Indentación: Tabs
- Espacios en paréntesis: `foo( arg )`
- Espacios en arrays: `[ 1, 2, 3 ]`
- Espacios en objetos: `{ key: value }`
- Comillas: Simples `'string'`
- Punto y coma: Obligatorio
- Camel case: `myVariableName`

**Prettier**:

- Formateo automático
- Consistencia en todo el proyecto
- Integrado con ESLint

### CSS/SCSS (Stylelint)

**WordPress CSS Coding Standards**:

- Indentación: Tabs
- Selectores: Un selector por línea
- Propiedades: Orden alfabético
- Colores: Lowercase hexadecimal
- Unidades: Sin espacio entre número y unidad

**SCSS**:

- Nesting máximo: 3 niveles
- Variables con prefix `$mi-proyecto-`
- Mixins con prefix `mi-proyecto-`

### Git Commits (Commitlint)

**Conventional Commits**:

```
feat: añade nueva funcionalidad
fix: corrige bug
docs: actualiza documentación
style: cambios de formato
refactor: refactorización de código
test: añade tests
chore: tareas de mantenimiento
```

**Formato**:

```
type(scope): subject

body (opcional)

footer (opcional)
```

**Ejemplos**:

```bash
feat(blocks): añade bloque de testimonios
fix(theme): corrige responsive en header
docs(readme): actualiza guía de instalación
style(css): formatea estilos del footer
```

## 🧪 Testing y CI/CD

### Testing Local

```bash
# Tests unitarios
make test-unit

# Tests E2E (Playwright)
make test-e2e

# Tests de accesibilidad
make test-a11y

# Auditoría de seguridad
make test-security

# Suite completa
make test-complete
```

### Lighthouse CI

```bash
# Setup
make lighthouse-ci-setup

# Análisis local
make lighthouse-local

# Análisis preprod
make lighthouse-preprod

# CI completo
make lighthouse-ci-run
```

### CI/CD Pipeline

Configurado con **Bitbucket Pipelines** (`bitbucket-pipelines.yml`):

**Stages**:

1. **Lint** - Verifica estándares de código
2. **Test** - Ejecuta tests
3. **Build** - Genera assets de producción
4. **Deploy** - Despliega a staging/production

**Comandos**:

```bash
make deploy-staging    # Deploy a staging
make deploy-prod       # Deploy a producción
make rollback-staging  # Rollback staging
make rollback-prod     # Rollback producción
```

## 🔒 Seguridad

### Auditorías Automáticas

```bash
# Auditoría npm
npm audit

# Auditoría composer
composer audit

# Ambas
npm run analyze:security
```

### Buenas Prácticas

- ✅ Dependencias actualizadas regularmente
- ✅ Secrets en variables de entorno
- ✅ Validación de entrada en PHP
- ✅ Sanitización de salida
- ✅ Nonces en formularios
- ✅ Capability checks en funciones

## 📊 Monitoreo y Performance

### Análisis de Bundles

```bash
# Tamaño de bundles
npm run analyze:bundle-size

# Análisis detallado
npm run analyze:dependencies
```

### Performance

```bash
# Lighthouse
make lighthouse-local

# Performance check
make performance-check

# Generar reportes
make generate-reports
```

## 🔄 Workflow de Desarrollo

### Desarrollo Diario

```bash
# 1. Iniciar desarrollo
make dev

# 2. Hacer cambios en código
# ...

# 3. Verificar antes de commit
make quick-fix

# 4. Commit (hooks automáticos)
git add .
git commit -m "feat: nueva funcionalidad"

# 5. Push
git push
```

### Pre-commit Automático

Gracias a **Husky** y **lint-staged**:

1. Formateo automático de archivos staged
2. Linting de PHP, JS, CSS
3. Validación de mensajes de commit
4. Análisis estático PHP

### Añadir Nuevo Componente

```bash
# 1. Crear plugin/tema
mkdir wordpress/wp-content/plugins/nuevo-plugin

# 2. Re-ejecutar configuración
./init-project.sh  # Modo 3

# 3. Seleccionar nuevo componente
# ¿Incluir 'nuevo-plugin'? (y/n): y

# 4. Listo!
make lint
```

## 🤝 Contribuir

Las contribuciones son bienvenidas:

1. **Fork** el repositorio
2. **Crea** una rama: `git checkout -b feature/nueva-funcionalidad`
3. **Commit** con Conventional Commits: `git commit -m "feat: descripción"`
4. **Push**: `git push origin feature/nueva-funcionalidad`
5. **Pull Request** con descripción detallada

### Guías de Contribución

- Seguir WordPress Coding Standards
- Tests para nuevas funcionalidades
- Documentación actualizada
- Commits semánticos

## 📄 Licencia

Este proyecto está bajo licencia **GPL-2.0-or-later**, compatible con WordPress.

## 🆘 Troubleshooting

### Problemas Comunes

**"Estructura WordPress no encontrada"**

```bash
# Verifica estructura
ls -la wordpress/wp-content/
# o
ls -la wp-content/
```

**"jq: command not found" (Modo 4)**

```bash
# macOS
brew install jq

# Linux
sudo apt-get install jq
```

**"PHPCBF no encontrado"**

```bash
composer install
```

**"ESLint no encontrado"**

```bash
npm install
```

**"Permisos denegados en script"**

```bash
chmod +x init-project.sh
chmod +x verify-template.sh
```

**"Git hooks no funcionan"**

```bash
npm run prepare
```

### Verificar Instalación

```bash
# Verificar plantilla
./verify-template.sh

# Verificar proyecto
make status
make health
```

### Limpiar y Reinstalar

```bash
# Limpiar todo
make clean
rm -rf node_modules vendor
rm -rf wordpress/wp-content/*/node_modules
rm -rf wordpress/wp-content/*/vendor

# Reinstalar
make install
```

## 📚 Documentación Adicional

- **[GUIA-RAPIDA.md](GUIA-RAPIDA.md)** - Guía rápida de uso
- **[Makefile](Makefile)** - Todos los comandos disponibles
- **[package.json](package.json)** - Scripts NPM
- **[composer.json](composer.json)** - Scripts Composer

## 🔗 Enlaces Útiles

- [WordPress Coding Standards](https://developer.wordpress.org/coding-standards/)
- [PHP_CodeSniffer](https://github.com/squizlabs/PHP_CodeSniffer)
- [PHPStan](https://phpstan.org/)
- [ESLint](https://eslint.org/)
- [Stylelint](https://stylelint.io/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Husky](https://typicode.github.io/husky/)

---

**Desarrollado con ❤️ para proyectos WordPress profesionales**
