# WordPress Project Template

> **Plantilla profesional de WordPress con detección automática, configuración dinámica y formateo de código según estándares oficiales**

[![WordPress](https://img.shields.io/badge/WordPress-6.5+-blue.svg)](https://wordpress.org/)
[![PHP](https://img.shields.io/badge/PHP-8.1+-purple.svg)](https://www.php.net/)
[![Node](https://img.shields.io/badge/Node-18+-green.svg)](https://nodejs.org/)

## 🎯 Características Principales

- 🔍 **Detección automática** - Identifica plugins y temas personalizados automáticamente
- ⚙️ **Configuración dinámica** - Genera archivos de configuración basados en tu proyecto
- 🎨 **Formateo automático** - Aplica estándares WordPress a todo el código (PHP, JS, CSS)
- ✅ **WordPress Coding Standards** - PHPCS, ESLint, Stylelint configurados
- 📊 **Análisis estático** - PHPStan Level 5
- 🔄 **3 Modos de operación** - Configurar, formatear o ambos
- 🎯 **Selectivo** - Elige qué componentes incluir en la configuración

## 🚀 Inicio Rápido

```bash
# 1. Navega a tu proyecto WordPress
cd /ruta/a/tu/proyecto

# 2. Ejecuta el script
./init-project.sh

# 3. Sigue las instrucciones interactivas
```

## 🎮 Modos de Operación

### 1️⃣  Configurar y Formatear Proyecto

**Cuándo usar**: Primera vez que configuras estándares en tu proyecto.

**Qué hace**:

- Detecta automáticamente todos los plugins y temas personalizados
- Te permite seleccionar cuáles incluir en la configuración
- Genera archivos de configuración dinámicamente
- Formatea automáticamente todo el código según estándares WordPress

### 2️⃣  Solo Configurar (sin formatear)

**Cuándo usar**: Quieres generar/actualizar los archivos de configuración sin tocar el código.

**Qué hace**:

- Detecta componentes y genera archivos de configuración
- NO modifica tu código fuente

### 3️⃣  Solo Formatear Código

**Cuándo usar**: Ya tienes configuración y quieres formatear código nuevo/modificado.

**Qué hace**:

- Usa la configuración existente
- Ejecuta PHPCBF para formatear PHP
- Ejecuta ESLint para formatear JavaScript

## 🔍 Cómo Funciona

### Detección Automática

El script detecta automáticamente:

**Plugins personalizados**:

- Excluye plugins por defecto de WordPress (Akismet, Hello Dolly, etc.)
- Identifica plugins con archivos PHP

**Temas personalizados**:

- Excluye temas Twenty* de WordPress
- Identifica temas con `style.css` o `functions.php`

**MU-Plugins**:

- Detecta todos los directorios en `mu-plugins/`

### Configuración Interactiva

Para cada componente detectado, el script pregunta:

```text
¿Incluir plugin 'mi-plugin-custom'? (y/n):
¿Incluir tema 'mi-tema'? (y/n):
```

### Generación Dinámica

Basándose en tu selección, genera:

**phpcs.xml.dist**:

- Prefixes: `mi_plugin_`, `MI_PLUGIN_`, `MiPlugin\`
- Text domains: `mi-plugin`, `mi-tema`
- Rutas a analizar automáticamente configuradas

**phpstan.neon.dist**:

- Paths de análisis para cada componente seleccionado
- Exclusiones de `build/`, `vendor/`, `node_modules/`

**eslint.config.js**:

- Configuración WordPress JavaScript Standards
- Rutas específicas a tus componentes
- Espaciado estilo WordPress (espacios en paréntesis, etc.)

## 💡 Casos de Uso

### Caso 1: Proyecto Nuevo

```bash
./init-project.sh
# Selecciona: 1 (Configurar y formatear)
# Selecciona los componentes a incluir
# El script configurará todo y formateará el código
```

### Caso 2: Proyecto Existente Sin Estándares

```bash
./init-project.sh
# Selecciona: 1 (Configurar y formatear)
# El script detectará tus plugins/temas existentes
# Los configurará y formateará según WordPress Standards
```

### Caso 3: Actualizar Configuración

```bash
./init-project.sh
# Selecciona: 2 (Solo configurar)
# Útil cuando añades nuevos plugins/temas
```

### Caso 4: Formatear Código Modificado

```bash
./init-project.sh
# Selecciona: 3 (Solo formatear)
# Formatea código según configuración existente
```

## 📦 Archivos Generados

### phpcs.xml.dist

Configuración de PHP CodeSniffer con:

- WordPress Coding Standards
- Validación de prefixes globales
- Validación de text domains i18n
- Exclusiones configuradas

### phpstan.neon.dist

Configuración de PHPStan con:

- Level 5 de análisis
- Paths específicos de tus componentes
- Exclusiones de directorios build/vendor

### eslint.config.js

Configuración de ESLint con:

- WordPress JavaScript Coding Standards
- Espaciado estilo WordPress
- Globals de WordPress (wp, jQuery, __, etc.)

## 🛠️ Comandos Disponibles

### Verificar Estándares

```bash
# PHP
./vendor/bin/phpcs --standard=phpcs.xml.dist

# JavaScript
npx eslint '**/*.{js,jsx,ts,tsx}'

# CSS
npx stylelint '**/*.{css,scss}'
```

### Formatear Código

```bash
# PHP (automático)
./vendor/bin/phpcbf --standard=phpcs.xml.dist

# JavaScript (automático)
npx eslint --fix '**/*.{js,jsx,ts,tsx}'

# Todo (usando el script)
./init-project.sh
# Selecciona: 3 (Solo formatear)
```

## 📚 Requisitos

### Obligatorios

- Node.js 18+
- npm
- Proyecto WordPress con estructura `wordpress/wp-content/` o `wp-content/`

### Opcionales pero Recomendados

- Composer (para estándares PHP)
- Git (para hooks pre-commit)

## 🔧 Instalación de Dependencias

```bash
# Dependencias PHP (estándares de código)
composer install

# Dependencias JavaScript (formateo y linting)
npm install

# Configurar hooks pre-commit
npm run prepare
```

## 📋 Estructura del Proyecto

```text
my-project/
├── wordpress/
│   └── wp-content/
│       ├── plugins/
│       │   ├── mi-plugin-custom/
│       │   └── otro-plugin/
│       ├── themes/
│       │   ├── mi-tema/
│       │   └── otro-tema/
│       └── mu-plugins/
│           └── mi-mu-plugin/
├── init-project.sh              # Script de configuración
├── phpcs.xml.dist               # WordPress PHP Standards
├── phpstan.neon.dist            # PHP Static Analysis
├── eslint.config.js             # WordPress JS Standards
├── package.json                 # Scripts y dependencias JS
└── composer.json                # Dependencias PHP
```

## 🎯 Estándares Aplicados

### PHP (PHPCS)

- WordPress Coding Standards
- Espaciado: 4 espacios (tabs)
- Nombres de funciones: `snake_case`
- Nombres de clases: `PascalCase`
- Prefixes obligatorios para funciones globales

### JavaScript (ESLint)

- WordPress JavaScript Coding Standards
- Espacios dentro de paréntesis: `foo( arg )`
- Espacios en arrays: `[ 1, 2, 3 ]`
- Comillas simples obligatorias
- Tabs para indentación

### CSS (Stylelint)

- WordPress CSS Coding Standards
- Propiedades ordenadas alfabéticamente
- Selectores en líneas separadas

## 🤝 Contribuir

Las contribuciones son bienvenidas. Por favor:

1. Fork el repositorio
2. Crea una rama para tu feature
3. Commit con mensajes descriptivos
4. Push y crea un Pull Request

## 📄 Licencia

Este proyecto está bajo licencia MIT.

## 🆘 Soporte

Si encuentras algún problema:

1. Verifica que tu estructura WordPress sea correcta (`wordpress/wp-content/` o `wp-content/`)
2. Asegúrate de tener Node.js y npm instalados
3. Revisa que tus componentes sean detectables (tienen archivos PHP o `style.css`)

---

**Nota**: Este script solo modifica archivos de configuración y formatea código. No modifica la funcionalidad de tu WordPress.
