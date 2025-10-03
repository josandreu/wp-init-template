# WordPress Project Template

> **Plantilla profesional de WordPress con estándares de código y herramientas de desarrollo configuradas**

[![WordPress](https://img.shields.io/badge/WordPress-6.5+-blue.svg)](https://wordpress.org/)
[![PHP](https://img.shields.io/badge/PHP-8.1+-purple.svg)](https://www.php.net/)
[![Node](https://img.shields.io/badge/Node-18+-green.svg)](https://nodejs.org/)

## 🎯 Características

- ✅ **WordPress Coding Standards** - PHP, JavaScript y CSS pre-configurados
- ✅ **Formateo automático** - PHPCS, ESLint, Stylelint, Prettier
- ✅ **Pre-commit hooks** - Husky + lint-staged
- ✅ **Análisis estático** - PHPStan Level 5
- ✅ **CI/CD** - Bitbucket Pipelines configurado
- ✅ **Makefile** - Comandos simplificados para desarrollo
- ✅ **4 Modos de uso** - Para proyectos nuevos y existentes

## 📋 Tabla de Contenidos

- [Caso 1: Proyecto Nuevo desde Cero](#caso-1-proyecto-nuevo-desde-cero)
- [Caso 2: Proyecto Existente (Reemplazar Referencias)](#caso-2-proyecto-existente-reemplazar-referencias)
- [Caso 3: Solo Actualizar Estándares](#caso-3-solo-actualizar-estándares)
- [Caso 4: Añadir Estándares a Proyecto Existente](#caso-4-añadir-estándares-a-proyecto-existente)
- [Comandos Disponibles](#comandos-disponibles)
- [Configuración Detallada](#configuración-detallada)

## 📦 Estructura

```
my-project/
├── wordpress/wp-content/
│   ├── plugins/my-project-custom-blocks/    # Bloques Gutenberg
│   └── themes/
│       ├── flat101-starter-theme/           # Theme base
│       └── my-project-theme/                # Theme del proyecto
├── init-project.sh                          # Script de inicialización
├── verify-template.sh                       # Verificación de plantilla
├── package.json                             # Scripts npm
├── composer.json                            # Dependencias PHP
├── phpcs.xml.dist                           # WordPress PHP Standards
├── eslint.config.js                         # WordPress JS Standards
└── Makefile                                 # Comandos de desarrollo
```

---

## 📖 Guías Detalladas por Caso de Uso

### Caso 1: Proyecto Nuevo desde Cero

**Situación**: Vas a empezar un proyecto WordPress completamente nuevo.

**Pasos**:

```bash
# 1. Clonar esta plantilla
git clone https://github.com/tu-usuario/wp-init.git mi-nuevo-proyecto
cd mi-nuevo-proyecto

# 2. Ejecutar el script de inicialización
./init-project.sh

# 3. Seleccionar: 1️⃣ Proyecto nuevo

# 4. El script te preguntará:
#    - Nombre del proyecto (ej: mi-tienda)
#    - URL local (ej: https://local.mi-tienda.com)
#    - Nombre del theme hijo (ej: mi-tienda-theme)
#    - Nombre del plugin (ej: mi-tienda-custom-blocks)

# 5. Instalar dependencias
npm install
composer install

# 6. Configurar Git hooks
npm run prepare

# 7. Comenzar desarrollo
make dev
```

**¿Qué hace el script?**
- ✅ Reemplaza `my-project` → `mi-tienda` en TODOS los archivos
- ✅ Actualiza `package.json` con el nombre correcto
- ✅ Actualiza `composer.json` con el nombre correcto
- ✅ Configura URLs en `Makefile` y archivos de configuración
- ✅ Crea archivo `.project-config` con toda la configuración
- ✅ Hace backup de archivos originales

**Resultado**:
```
mi-nuevo-proyecto/
├── wordpress/wp-content/
│   ├── plugins/mi-tienda-custom-blocks/
│   └── themes/
│       ├── flat101-starter-theme/
│       └── mi-tienda-theme/
├── package.json          # Configurado para "mi-tienda"
├── composer.json         # Configurado para "mi-tienda"
├── phpcs.xml.dist        # Con prefixes: mi_tienda_
├── eslint.config.js      # WordPress standards
└── Makefile              # Con URLs correctas
```

---

### Caso 2: Proyecto Existente (Reemplazar Referencias)

**Situación**: Tienes un proyecto WordPress que copiaste de otro cliente y necesitas cambiar todas las referencias.

**Ejemplo**: Tienes un proyecto de "cliente-a" y quieres adaptarlo para "cliente-b".

**Pasos**:

```bash
# 1. Ve a tu proyecto existente
cd /ruta/a/proyecto-cliente-a

# 2. Ejecuta el script de inicialización desde la plantilla
/ruta/a/wp-init/init-project.sh

# 3. Seleccionar: 2️⃣ Proyecto existente

# 4. El script detectará automáticamente:
#    - Slug actual: "cliente-a" (desde package.json)
#    - Te preguntará si es correcto
#    - Pedirá el nuevo slug: "cliente-b"

# 5. Confirmar que quieres reemplazar las referencias

# 6. Actualizar dependencias si es necesario
npm install
composer install
```

**¿Qué hace el script?**
- ✅ Detecta el slug actual automáticamente
- ✅ Reemplaza `cliente-a` → `cliente-b` en todos los archivos
- ✅ Actualiza prefixes PHP: `cliente_a_` → `cliente_b_`
- ✅ Actualiza constantes: `CLIENTE_A_` → `CLIENTE_B_`
- ✅ Actualiza namespaces: `ClienteA\` → `ClienteB\`
- ✅ Actualiza text domains en archivos de configuración
- ✅ Hace backup completo antes de cambiar

**Archivos afectados**:
- `package.json` - Nombre del proyecto y scripts
- `composer.json` - Nombre del paquete
- `phpcs.xml.dist` - Prefixes y text domains
- `phpstan.neon.dist` - Rutas
- `eslint.config.js` - Rutas
- `Makefile` - URLs y nombres
- `README.md` - Referencias al proyecto

---

### Caso 3: Solo Actualizar Estándares

**Situación**: Ya tienes tu proyecto configurado con nombres correctos, solo quieres actualizar las reglas de código y estándares a las últimas versiones.

**Pasos**:

```bash
# 1. Ve a tu proyecto
cd /ruta/a/tu/proyecto

# 2. Ejecuta el script
/ruta/a/wp-init/init-project.sh

# 3. Seleccionar: 3️⃣ Solo estándares

# 4. El script actualizará SOLO archivos de configuración
#    SIN modificar package.json ni composer.json

# 5. Revisar cambios y actualizar si es necesario
git diff

# 6. Actualizar dependencias si cambiaron versiones
npm install
composer install
```

**¿Qué hace el script?**
- ✅ Actualiza `phpcs.xml.dist` (WordPress Coding Standards)
- ✅ Actualiza `phpstan.neon.dist` (PHP Static Analysis)
- ✅ Actualiza `eslint.config.js` (WordPress JS Standards)
- ✅ Actualiza `commitlint.config.cjs` (Conventional Commits)
- ✅ NO toca `package.json` existente
- ✅ NO toca `composer.json` existente
- ✅ NO cambia nombres ni referencias

**Ideal para**:
- Actualizar reglas de linting
- Sincronizar estándares con el equipo
- Adoptar nuevas versiones de PHPCS/ESLint

---

### Caso 4: Añadir Estándares a Proyecto Existente

**Situación**: Tienes un proyecto WordPress ya iniciado con tu propio `package.json` y `composer.json`, pero SIN estándares de código configurados.

**Este es el caso MÁS COMÚN** cuando ya trabajas en un proyecto.

**Pasos**:

```bash
# 1. Instalar jq (recomendado para merge automático)
brew install jq  # macOS
# apt-get install jq  # Linux

# 2. Clonar la plantilla en una ubicación separada
cd ~/plantillas
git clone https://github.com/tu-usuario/wp-init.git

# 3. Ve a TU proyecto existente
cd /ruta/a/tu/proyecto-wordpress

# 4. Ejecuta el script desde la plantilla
~/plantillas/wp-init/init-project.sh

# 5. Seleccionar: 4️⃣ Añadir estándares

# 6. El script hará:
#    ✅ Copiar archivos de configuración que NO existen
#    ✅ FUSIONAR dependencias en package.json (con backup)
#    ✅ FUSIONAR dependencias en composer.json (con backup)
#    ✅ AÑADIR scripts de linting SIN borrar los tuyos

# 7. Instalar las nuevas dependencias
npm install
composer install

# 8. Configurar Git hooks
npm run prepare

# 9. Probar los nuevos comandos
npm run lint:js
npm run lint:php
npm run format:all
```

**¿Qué hace el script?**

#### Con `jq` instalado (AUTOMÁTICO):

**Tu `package.json` ANTES**:
```json
{
  "name": "mi-proyecto",
  "scripts": {
    "dev": "vite",
    "build": "vite build"
  },
  "devDependencies": {
    "vite": "^5.0.0",
    "react": "^18.0.0"
  }
}
```

**Tu `package.json` DESPUÉS**:
```json
{
  "name": "mi-proyecto",
  "scripts": {
    "dev": "vite",                        // ✅ Se mantiene
    "build": "vite build",                // ✅ Se mantiene
    "lint:js": "eslint '**/*.js'...",     // ✅ Añadido
    "lint:php": "./vendor/bin/phpcs",     // ✅ Añadido
    "lint:css": "stylelint '**/*.css'",   // ✅ Añadido
    "format:all": "npm-run-all...",       // ✅ Añadido
    "prepare": "husky install"            // ✅ Añadido
  },
  "devDependencies": {
    "vite": "^5.0.0",                     // ✅ Se mantiene
    "react": "^18.0.0",                   // ✅ Se mantiene
    "@wordpress/eslint-plugin": "^22.14.0", // ✅ Añadido
    "eslint": "^9.33.0",                  // ✅ Añadido
    "prettier": "^3.4.2",                 // ✅ Añadido
    "stylelint": "^14.16.1",              // ✅ Añadido
    "husky": "^9.1.7",                    // ✅ Añadido
    "lint-staged": "^15.3.0"              // ✅ Añadido
  },
  "lint-staged": {                        // ✅ Añadido
    "**/*.{js,jsx,ts,tsx}": ["eslint --fix", "prettier --write"],
    "**/*.php": ["./vendor/bin/phpcbf", "./vendor/bin/phpcs"]
  }
}
```

**Archivos que se copian**:
```
tu-proyecto/
├── phpcs.xml.dist         # ✅ Copiado (WordPress PHP Standards)
├── phpstan.neon.dist      # ✅ Copiado (PHP Static Analysis)
├── eslint.config.js       # ✅ Copiado (WordPress JS Standards)
├── commitlint.config.cjs  # ✅ Copiado (Conventional Commits)
├── .gitignore             # ✅ Copiado si no existe
├── package.json           # ✅ Fusionado (backup creado)
├── composer.json          # ✅ Fusionado (backup creado)
├── package.json.backup    # ✅ Tu versión original
└── composer.json.backup   # ✅ Tu versión original
```

#### Sin `jq` (MANUAL):

El script crea archivos de referencia:
```
tu-proyecto/
├── package.json.additions   # 📄 Lo que debes copiar a package.json
├── composer.json.additions  # 📄 Lo que debes copiar a composer.json
├── phpcs.xml.dist           # ✅ Copiado
├── eslint.config.js         # ✅ Copiado
└── phpstan.neon.dist        # ✅ Copiado
```

**Comandos que tendrás disponibles después**:
```bash
# Linting
npm run lint:js          # Verificar JavaScript
npm run lint:css         # Verificar CSS/SCSS
npm run lint:php         # Verificar PHP

# Formateo automático
npm run lint:js:fix      # Arreglar JS automáticamente
npm run lint:css:fix     # Arreglar CSS automáticamente
npm run lint:php:fix     # Arreglar PHP automáticamente
npm run format:all       # Formatear todo

# Verificación completa
npm run test:standards   # Verificar todos los estándares
```

**Ventajas de este modo**:
- ✅ NO pierdes tu configuración actual
- ✅ NO pierdes tus scripts personalizados
- ✅ Merge inteligente de dependencias
- ✅ Backup automático por seguridad
- ✅ Solo añade lo necesario para linting
- ✅ NO incluye scripts de build específicos de la plantilla

---

## ⚙️ Configuración

### Archivos de la Plantilla

Para usar cualquiera de los modos necesitas **TODO el repositorio**:

```
wp-init/                      # 📦 Clona todo esto
├── init-project.sh           # Script principal
├── verify-template.sh        # Verificación
├── package.json              # Template de referencia
├── composer.json             # Template de referencia
├── phpcs.xml.dist            # Config WordPress PHP
├── phpstan.neon.dist         # Config análisis PHP
├── eslint.config.js          # Config WordPress JS
├── commitlint.config.cjs     # Config commits
├── Makefile                  # Comandos de desarrollo
├── .gitignore.template       # Template gitignore
└── .project-config.example   # Ejemplo de config
```

El script **lee** estos archivos y los **copia/fusiona** según el modo que elijas.

## 🛠️ Comandos Principales

### Desarrollo
```bash
make dev              # Desarrollo con hot reload
make dev-blocks       # Solo bloques
make dev-theme        # Solo theme principal
```

### Calidad de Código
```bash
make format           # Formatear todo el código
make lint             # Verificar estándares
make test             # Tests completos
```

### Build
```bash
make build            # Build de producción
make clean            # Limpiar caches
```

## 📋 Estándares Configurados

### PHP
- **PHPCS** con WordPress Coding Standards 3.2+
- **PHPStan** Level 5
- Prefixes: `my_project_`, `MY_PROJECT_`, `MyProject\`
- Text domains configurables

### JavaScript
- **ESLint 9** con reglas WordPress
- Espaciado específico: `array = [ a, b ]`, `foo( arg )`
- Indentación con tabs

### CSS
- **Stylelint** con `@wordpress/stylelint-config`
- Soporte SCSS

## 🔧 Configuración Adicional

### Archivos Principales

| Archivo | Propósito |
|---------|-----------|
| `phpcs.xml.dist` | Reglas PHP CodeSniffer |
| `phpstan.neon.dist` | Análisis estático PHP |
| `eslint.config.js` | Reglas ESLint |
| `commitlint.config.cjs` | Conventional commits |
| `Makefile` | Comandos desarrollo |

### Pre-commit Hooks

Configurado con **lint-staged**:
- Formatea automáticamente archivos modificados
- Ejecuta linting antes de commit
- Verifica estándares WordPress

## 📚 Comandos Útiles

```bash
# Verificar plantilla
./verify-template.sh

# Formatear código
npm run format:all

# Verificar estándares
npm run verify:standards

# Limpiar caches
npm run cache:clear

# Ver todos los comandos
make help
npm run
```

## 🎨 Personalización

### Cambiar Prefixes PHP

Edita `phpcs.xml.dist`:
```xml
<property name="prefixes" type="array">
    <element value="tu_prefix_"/>
</property>
```

### Cambiar Text Domains

Edita `phpcs.xml.dist`:
```xml
<property name="text_domain" type="array">
    <element value="tu-text-domain"/>
</property>
```

## 🔍 Verificación

```bash
# Verificar que la plantilla está lista
./verify-template.sh

# Verificar estándares de código
make test

# Ver estado del proyecto
make status
```

## 📦 Dependencias

### Requeridas
- Node.js >= 18.0.0
- npm >= 8.0.0
- PHP >= 8.1

### Recomendadas
- Composer
- WP-CLI
- Git

## 🤝 Contribuir

1. Usa commits convencionales: `feat:`, `fix:`, `style:`, etc.
2. Ejecuta `make format` antes de commit
3. Verifica con `make test`

## 📄 Licencia

GPL-2.0-or-later - Compatible con WordPress

---

**Creado por**: Flat 101 Team  
**Versión**: 2.0.0
