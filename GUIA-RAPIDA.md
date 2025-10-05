# 🚀 Guía Rápida - WordPress Init Template

> **Guía de referencia rápida para configurar estándares de código WordPress en tu proyecto**

## 📖 Tabla de Contenidos

- [¿Qué es esto?](#qué-es-esto)
- [¿Qué modo usar?](#qué-modo-usar)
- [Instalación Rápida](#instalación-rápida)
- [Comandos Esenciales](#comandos-esenciales)
- [Troubleshooting](#troubleshooting)

## 🎯 ¿Qué es esto?

**WordPress Init Template** es una plantilla completa que configura automáticamente:

- ✅ WordPress Coding Standards (PHP, JS, CSS)
- ✅ Linting y formateo automático
- ✅ Git hooks con pre-commit
- ✅ 100+ scripts NPM organizados
- ✅ Makefile con comandos de desarrollo
- ✅ Testing (Jest, Playwright, Lighthouse)
- ✅ CI/CD con Bitbucket Pipelines

### ¿Qué archivos necesito?

**TODO el repositorio `wp-init/`**

```bash
# Clona el repositorio completo
git clone https://github.com/tu-usuario/wp-init.git ~/plantillas/wp-init
```

## 🎮 ¿Qué modo usar?

### 🆕 Modo 1: Proyecto Nuevo Completo

**Cuándo**: Inicias un proyecto WordPress desde cero

**Qué hace**:

- Crea estructura completa de directorios
- Genera `package.json` y `composer.json` completos
- Configura todos los archivos de estándares
- Crea Makefile personalizado
- Configura Git hooks

```bash
# 1. Clonar plantilla
git clone https://github.com/tu-usuario/wp-init.git mi-proyecto
cd mi-proyecto

# 2. Ejecutar script
./init-project.sh
# Selecciona: 1

# 3. Instalar dependencias
make install

# 4. Iniciar desarrollo
make dev
```

---

### 🔄 Modo 2: Cambiar Referencias

**Cuándo**: Adaptas proyecto de "cliente-a" para "cliente-b"

**Qué hace**:

- Reemplaza nombres en todos los archivos
- Actualiza namespaces y constantes PHP
- Modifica text domains de i18n
- Actualiza URLs en configuración

```bash
# 1. Copiar proyecto base
cp -r proyecto-cliente-a proyecto-cliente-b
cd proyecto-cliente-b

# 2. Cambiar referencias
./init-project.sh
# Selecciona: 2
# Ingresa: cliente-b

# 3. Verificar cambios
git diff
```

---

### 🔧 Modo 3: Actualizar Reglas de Linting

**Cuándo**: Solo quieres actualizar archivos de linting

**Qué hace**:

- Actualiza `phpcs.xml.dist`
- Actualiza `eslint.config.js`
- Actualiza `phpstan.neon.dist`
- Mantiene tus `package.json` y `composer.json`

```bash
# 1. Desde tu proyecto
cd /ruta/a/tu/proyecto

# 2. Actualizar reglas
~/plantillas/wp-init/init-project.sh
# Selecciona: 3

# 3. Formatear con nuevas reglas
make format
```

---

### ⭐ Modo 4: Fusionar Configuración (RECOMENDADO)

**Cuándo**: Proyecto existente con sus propias dependencias

**Qué hace**:

- Fusiona `package.json` (mantiene tus scripts)
- Fusiona `composer.json` (añade herramientas)
- Crea backups automáticos
- Copia archivos de configuración
- **Requiere**: `jq` instalado

```bash
# 1. Instalar jq (IMPORTANTE)
brew install jq  # macOS
sudo apt-get install jq  # Linux

# 2. Desde tu proyecto
cd /ruta/a/tu/proyecto-wordpress

# 3. Ejecutar script
~/plantillas/wp-init/init-project.sh
# Selecciona: 4

# 4. Instalar nuevas dependencias
npm install && composer install

# 5. Configurar hooks
npm run prepare

# 6. ¡Listo! Probar comandos
make lint
make format
```

## 📦 Archivos Incluidos

### Archivos de Linting

```text
📄 phpcs.xml.dist          → WordPress PHP Coding Standards
📄 phpstan.neon.dist       → Análisis estático PHP Level 5
📄 eslint.config.js        → WordPress JavaScript Standards
📄 commitlint.config.cjs   → Conventional Commits
```

### Archivos de Configuración

```text
📄 package.json            → 100+ scripts NPM organizados
📄 composer.json           → Dependencias PHP y herramientas
📄 Makefile                → 50+ comandos de desarrollo
📄 lighthouserc.js         → Configuración Lighthouse CI
📄 bitbucket-pipelines.yml → CI/CD pipeline
```

### Scripts y Herramientas

```text
📄 init-project.sh         → Script de inicialización
📄 verify-template.sh      → Verificación de plantilla
📁 .vscode/                → Configuración VSCode
📁 .husky/                 → Git hooks
📁 sh/                     → Scripts de deployment y DB
```

### Lo que se genera en tu proyecto

#### Modo 1 (Proyecto Nuevo)

- ✅ Estructura completa de directorios
- ✅ Todos los archivos de configuración
- ✅ `package.json` y `composer.json` completos
- ✅ Makefile personalizado
- ✅ Git hooks configurados

#### Modo 2 (Cambiar Referencias)

- ✅ Nombres actualizados en todos los archivos
- ✅ Namespaces y constantes PHP
- ✅ Text domains i18n
- ✅ URLs en configuración

#### Modo 3 (Actualizar Reglas)

- ✅ `phpcs.xml.dist` actualizado
- ✅ `eslint.config.js` actualizado
- ✅ `phpstan.neon.dist` actualizado
- ⚠️ Mantiene tus `package.json` y `composer.json`

#### Modo 4 (Fusionar - Recomendado)

- ✅ Archivos de configuración copiados
- ✅ `package.json` **fusionado** (tus scripts + linting)
- ✅ `composer.json` **fusionado** (tus deps + herramientas)
- ✅ Backups automáticos: `.backup`
- ⚠️ **Requiere jq instalado**

## ⚡ Instalación Rápida

### Para Proyecto Nuevo

```bash
# 1. Clonar plantilla
git clone https://github.com/tu-usuario/wp-init.git mi-proyecto
cd mi-proyecto

# 2. Inicializar
./init-project.sh  # Modo 1

# 3. Instalar todo
make install

# 4. Desarrollar
make dev
```

### Para Proyecto Existente (Recomendado)

```bash
# PASO 1: Clonar plantilla (una sola vez)
git clone https://github.com/tu-usuario/wp-init.git ~/plantillas/wp-init

# PASO 2: Instalar jq (una sola vez)
brew install jq  # macOS
sudo apt-get install jq  # Linux

# PASO 3: Ir a tu proyecto
cd /ruta/a/tu/proyecto-wordpress

# PASO 4: Ejecutar script
~/plantillas/wp-init/init-project.sh
# Selecciona: 4 (Fusionar configuración)

# PASO 5: Instalar dependencias
npm install && composer install

# PASO 6: Configurar hooks
npm run prepare

# PASO 7: ¡Listo! Probar
make lint
make format
make dev
```

## 🛠️ Comandos Esenciales

### Comandos Make (Más Usados)

```bash
# Desarrollo
make dev              # Inicia desarrollo con hot reload
make dev-blocks       # Solo bloques Gutenberg
make dev-theme        # Solo tema principal

# Linting y Formateo
make lint             # Verifica estándares (PHP, JS, CSS)
make format           # Formatea todo el código
make quick-fix        # Format + lint + test rápido

# Testing
make test             # Tests completos
make quick            # Verificación rápida
make commit-ready     # Verifica antes de commit

# Build
make build            # Build de producción optimizado

# Utilidades
make clean            # Limpia caches y temporales
make health           # Verifica salud del proyecto
make status           # Estado actual
make help             # Ver todos los comandos
```

### Scripts NPM Esenciales

```bash
# Linting
npm run lint:js       # Lint JavaScript
npm run lint:css      # Lint CSS/SCSS
npm run lint:php      # Lint PHP

# Formateo
npm run format:all    # Formatea todo
npm run fix-all       # Alias de format:all

# Análisis
npm run analyze:php   # PHPStan
npm run analyze:security  # Auditoría de seguridad

# Build
npm run build:all     # Build completo
npm run build:production  # Build + lint + test

# Desarrollo
npm run dev:all       # Desarrollo paralelo

# Verificación
npm run verify:standards  # Verifica todo
npm run quick-check      # Verificación rápida

# Cache
npm run cache:clear   # Limpia todos los caches
```

### Comandos Composer

```bash
composer run lint:php      # Lint PHP
composer run lint:php:fix  # Fix PHP
composer run analyze:php   # PHPStan
composer run test:php      # Test completo
```

## ✅ Verificación de Instalación

### Verificar Archivos Generados

```bash
# Archivos de linting
ls -la phpcs.xml.dist eslint.config.js phpstan.neon.dist commitlint.config.cjs

# Archivos de configuración
ls -la package.json composer.json Makefile

# Backups (Modo 4)
ls -la *.backup

# Directorio VSCode
ls -la .vscode/

# Git hooks
ls -la .husky/
```

### Verificar Comandos

```bash
# Verificar estado del proyecto
make status

# Verificar salud
make health

# Probar linting
make lint

# Probar formateo
make format

# Ver todos los comandos
make help
```

### Verificar Dependencias

```bash
# Verificar instalación
node --version    # >= 18.0.0
npm --version     # >= 8.0.0
composer --version  # >= 2.0
php --version     # >= 8.1

# Verificar herramientas
./vendor/bin/phpcs --version
./vendor/bin/phpstan --version
npx eslint --version

# Verificar dependencias desactualizadas
make check-deps
```

### Probar Workflow Completo

```bash
# 1. Iniciar desarrollo
make dev

# 2. Hacer un cambio en código
# ...

# 3. Verificar antes de commit
make quick-fix

# 4. Commit (hooks automáticos)
git add .
git commit -m "feat: nueva funcionalidad"

# 5. Si todo pasa, push
git push
```

## 🆘 Troubleshooting

### Problemas de Instalación

#### "jq: command not found" (Modo 4)

```bash
# macOS
brew install jq

# Linux (Ubuntu/Debian)
sudo apt-get install jq

# Linux (CentOS/RHEL)
sudo yum install jq
```

#### "Script not found"

```bash
# Verificar que el script existe
ls -la ~/plantillas/wp-init/init-project.sh

# Dar permisos de ejecución
chmod +x ~/plantillas/wp-init/init-project.sh

# Usar ruta completa
/Users/tu-usuario/plantillas/wp-init/init-project.sh
```

#### "Estructura WordPress no encontrada"

```bash
# Verificar estructura
ls -la wordpress/wp-content/
# o
ls -la wp-content/

# El script busca estas estructuras
```

### Problemas de Dependencias

#### "PHPCBF no encontrado"

```bash
# Instalar dependencias composer
composer install

# Verificar instalación
./vendor/bin/phpcs --version
./vendor/bin/phpcbf --version
```

#### "ESLint no encontrado"

```bash
# Instalar dependencias npm
npm install

# Verificar instalación
npx eslint --version
```

#### "No se instalaron las dependencias"

```bash
# Limpiar e instalar
rm -rf node_modules vendor
npm install
composer install

# O usar make
make clean
make install
```

### Problemas de Configuración

#### "Mis scripts desaparecieron" (Modo 4)

```bash
# Restaurar desde backup
cp package.json.backup package.json
cp composer.json.backup composer.json

# Los backups se crean automáticamente
```

#### "Git hooks no funcionan"

```bash
# Reinstalar hooks
npm run prepare

# Verificar instalación
ls -la .husky/
cat .husky/pre-commit
```

#### "Permisos denegados"

```bash
# Dar permisos a scripts
chmod +x init-project.sh
chmod +x verify-template.sh
chmod +x sh/**/*.sh
```

### Problemas de Linting

#### "PHPCS encuentra muchos errores"

```bash
# Formatear automáticamente
make format
# o
./vendor/bin/phpcbf --standard=phpcs.xml.dist
```

#### "ESLint encuentra muchos errores"

```bash
# Formatear automáticamente
npm run lint:js:fix
# o
npx eslint --fix '**/*.{js,jsx,ts,tsx}'
```

#### "Linting muy lento"

```bash
# Limpiar caches
make clear-cache
# o
npm run cache:clear
```

### Verificar Instalación

```bash
# Verificar plantilla
./verify-template.sh

# Verificar proyecto
make status
make health

# Verificar versiones
node --version    # >= 18.0.0
npm --version     # >= 8.0.0
composer --version  # >= 2.0
php --version     # >= 8.1
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

# Verificar
make health
```

## 💡 Tips y Mejores Prácticas

### Uso Diario

1. **Usa `make` en lugar de comandos largos**

   ```bash
   make dev      # en lugar de npm run dev:all
   make lint     # en lugar de npm run test:standards
   make format   # en lugar de npm run format:all
   ```

2. **Verifica antes de commit**

   ```bash
   make quick-fix  # Formatea y verifica rápido
   make commit-ready  # Verificación completa
   ```

3. **Usa los hooks automáticos**
   - Los archivos se formatean automáticamente al hacer commit
   - Los mensajes de commit se validan automáticamente

### Selección de Modo

1. **Modo 1**: Solo para proyectos completamente nuevos
2. **Modo 2**: Para adaptar proyectos entre clientes
3. **Modo 3**: Para actualizar solo reglas de linting
4. **Modo 4**: **RECOMENDADO** para proyectos existentes

### Configuración

1. **Instala jq** si vas a usar Modo 4

   ```bash
   brew install jq  # macOS
   ```

2. **Guarda la plantilla** en una ubicación fija

   ```bash
   ~/plantillas/wp-init/
   ```

3. **Revisa los backups** antes de commitear

   ```bash
   ls -la *.backup
   ```

4. **Configura VSCode** con las extensiones recomendadas
   - PHP Intelephense
   - PHPSAB
   - ESLint
   - Stylelint
   - Prettier

### Performance

1. **Usa caches** para linting más rápido

   ```bash
   # Los caches se usan automáticamente
   # Limpiar si hay problemas
   make clear-cache
   ```

2. **Desarrollo paralelo** para múltiples componentes

   ```bash
   make dev  # Inicia todos los componentes en paralelo
   ```

3. **Verificación rápida** antes de commit
   ```bash
   make quick  # Solo JS y CSS (más rápido)
   ```

## 📚 Recursos Adicionales

### Documentación

- **[README.md](README.md)** - Documentación completa
- **[Makefile](Makefile)** - Todos los comandos disponibles
- **[package.json](package.json)** - Scripts NPM
- **[composer.json](composer.json)** - Scripts Composer

### Enlaces Útiles

- [WordPress Coding Standards](https://developer.wordpress.org/coding-standards/)
- [PHP_CodeSniffer](https://github.com/squizlabs/PHP_CodeSniffer)
- [PHPStan](https://phpstan.org/)
- [ESLint](https://eslint.org/)
- [Conventional Commits](https://www.conventionalcommits.org/)

### Comandos de Referencia Rápida

```bash
# Ver todos los comandos
make help

# Estado del proyecto
make status

# Salud del proyecto
make health

# Desarrollo
make dev

# Linting
make lint

# Formateo
make format

# Testing
make test

# Build
make build

# Limpieza
make clean
```

---

**¿Necesitas ayuda?** Consulta el [README.md](README.md) para documentación completa.
