# 🚀 WordPress Init Template

> **Plantilla profesional de WordPress con configuración automática de estándares de código, linting, formateo y herramientas de desarrollo**

<div align="center">

[![WordPress](https://img.shields.io/badge/WordPress-6.5+-21759B?style=for-the-badge&logo=wordpress&logoColor=white)](https://wordpress.org/)
[![PHP](https://img.shields.io/badge/PHP-8.1+-777BB4?style=for-the-badge&logo=php&logoColor=white)](https://www.php.net/)
[![Node.js](https://img.shields.io/badge/Node.js-18+-339933?style=for-the-badge&logo=node.js&logoColor=white)](https://nodejs.org/)
[![License](https://img.shields.io/badge/License-GPL--2.0-blue?style=for-the-badge)](LICENSE)

[![Build Status](https://img.shields.io/badge/Build-Passing-success?style=flat-square)](https://github.com/tu-usuario/wp-init)
[![Code Quality](https://img.shields.io/badge/Code%20Quality-A+-brightgreen?style=flat-square)](https://github.com/tu-usuario/wp-init)
[![Maintenance](https://img.shields.io/badge/Maintained-Yes-green?style=flat-square)](https://github.com/tu-usuario/wp-init)

</div>

---

## 📋 Tabla de Contenidos

- [🎯 Características Principales](#-características-principales)
- [🚀 Inicio Rápido](#-inicio-rápido)
- [🎮 Modos de Operación](#-modos-de-operación)
- [📖 Guía Detallada de Uso](#-guía-detallada-de-uso)
- [📁 Operaciones de Archivos y Configuración](#-operaciones-de-archivos-y-configuración)
- [📊 Antes y Después: Transformación del Proyecto](#-antes-y-después-transformación-del-proyecto)
- [🔍 Cómo Funciona](#-cómo-funciona)
- [💡 Casos de Uso Detallados](#-casos-de-uso-detallados)
- [📦 Archivos y Configuración](#-archivos-y-configuración)
- [🛠️ Comandos Disponibles](#️-comandos-disponibles)
- [📚 Requisitos del Sistema](#-requisitos-del-sistema)
- [🔧 Instalación y Configuración](#-instalación-y-configuración)
- [📋 Estructura del Proyecto](#-estructura-del-proyecto)
- [🎯 Estándares y Convenciones](#-estándares-y-convenciones)
- [🧪 Testing y CI/CD](#-testing-y-cicd)
- [🔒 Seguridad](#-seguridad)
- [📊 Monitoreo y Performance](#-monitoreo-y-performance)
- [🔄 Workflow de Desarrollo](#-workflow-de-desarrollo)
- [🤝 Contribuir](#-contribuir)
- [🆘 Troubleshooting](#-troubleshooting)
- [📚 Documentación Adicional](#-documentación-adicional)

---

## 🎯 Características Principales

<div align="center">

### ⚡ **Configuración Automática en Minutos**
*Transforma tu proyecto WordPress en una configuración profesional con un solo comando*

</div>

<table>
<tr>
<td width="50%">

### 🔧 **Configuración y Estándares**

- 🔍 **Detección automática** - Identifica plugins y temas personalizados
- ⚙️ **Configuración dinámica** - Genera archivos de configuración basados en tu proyecto
- 📁 **Adaptación de plantillas** - Copia y adapta archivos de configuración automáticamente
- 🎨 **Formateo inteligente** - Aplica WordPress Coding Standards solo a componentes seleccionados
- ✅ **Validación completa** - Verificaciones previas y manejo de errores mejorado
- 📊 **Análisis estático** - PHPStan Level 5 con WordPress stubs
- 🔄 **Cuatro modos** - Configurar, formatear, actualizar o fusionar según necesidad

</td>
<td width="50%">

### 🚀 **Desarrollo y Automatización**

- 🚀 **Scripts NPM optimizados** - Más de 100 comandos para desarrollo
- 🎯 **Makefile dinámico** - Generado con targets específicos para tus componentes
- 🔗 **Git Hooks automáticos** - Pre-commit con Husky y lint-staged
- 📦 **Build optimizado** - Webpack con hot reload y análisis de bundles
- 🧪 **Testing integrado** - Jest, Playwright, Lighthouse CI
- 🔒 **Seguridad mejorada** - Auditorías automáticas y validaciones

</td>
</tr>
<tr>
<td colspan="2">

### 📂 **Operaciones de Archivos y Workspace**

<div align="center">

| Característica | Descripción | Beneficio |
|---|---|---|
| 📂 **Generación de workspace** | VSCode workspace automático con componentes seleccionados | Navegación optimizada |
| 🎯 **Targeting de JavaScript** | Rutas específicas para linting y formateo por componente | Rendimiento mejorado |
| 💾 **Sistema de backups** | Respaldo automático antes de modificar archivos existentes | Seguridad garantizada |
| 🔧 **Operaciones seguras** | Manejo de errores y rollback en caso de fallos | Confiabilidad total |
| 📝 **Logging completo** | Registro detallado de todas las operaciones realizadas | Trazabilidad completa |
| ⚡ **Validación previa** | Verificación de requisitos antes de ejecutar cambios | Prevención de errores |

</div>

</td>
</tr>
</table>

---

## 🎨 Sistema de Templates Externas

<div align="center">

### ✨ **Personalización Sin Límites**

*Modifica fácilmente la configuración de tu proyecto sin tocar el código del script*

</div>

Todos los archivos de configuración se generan desde **templates editables** ubicadas en el directorio `templates/`. Esto te permite:

<table>
<tr>
<td width="33%">

### 📝 **Fácil Edición**

- Modifica templates sin tocar el script
- Cambios visibles inmediatamente
- Sintaxis clara y documentada

</td>
<td width="33%">

### 🔄 **Versionado**

- Templates en Git
- Historial de cambios
- Fácil rollback

</td>
<td width="33%">

### 🎯 **Consistencia**

- Misma configuración base
- Fácil propagación de mejoras
- Estándares unificados

</td>
</tr>
</table>

#### 📁 Templates Disponibles

```
templates/
├── 🔍 Linting y Análisis
│   ├── phpcs.xml.dist.template
│   ├── phpstan.neon.dist.template
│   ├── eslint.config.js.template
│   └── .stylelintrc.json.template
│
├── 📦 Gestión de Dependencias
│   ├── package.json.template
│   └── composer.json.template
│
├── ⚙️ Configuración del Editor
│   ├── .editorconfig.template
│   └── .prettierrc.json.template
│
├── 💻 VSCode
│   ├── vscode-settings.json.template
│   ├── vscode-extensions.json.template
│   └── wp.code-workspace.template
│
└── 🛠️ Otros
    ├── .gitignore.template
    ├── Makefile.template
    ├── bitbucket-pipelines.yml.template
    ├── commitlint.config.cjs.template
    └── lighthouserc.js.template
```

#### 🚀 Uso Rápido

```bash
# 1. Edita la template que necesites
vim templates/phpcs.xml.dist.template

# 2. Ejecuta el script normalmente
./init-project.sh /path/to/wordpress 1

# 3. Los cambios se aplican automáticamente ✨
```

#### 📚 Documentación Completa

- **[templates/README.md](templates/README.md)** - Guía completa de uso de templates
- **[CHANGELOG_TEMPLATES.md](CHANGELOG_TEMPLATES.md)** - Detalles técnicos de implementación
- **[IMPLEMENTACION_TEMPLATES.md](IMPLEMENTACION_TEMPLATES.md)** - Guía de implementación

---

## 🚀 Inicio Rápido

<div align="center">

### ⚡ **¡Configura tu proyecto WordPress en menos de 5 minutos!**

</div>

<table>
<tr>
<td width="50%">

### 🆕 **Para Proyecto Nuevo**

<div align="center">

**🎯 Configuración completa desde cero**

</div>

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

<div align="center">

✅ **Resultado**: Proyecto completamente configurado con estándares WordPress

</div>

</td>
<td width="50%">

### 🔄 **Para Proyecto Existente (RECOMENDADO)**

<div align="center">

**🛠️ Flujo externo seguro - Sin interferir con tu proyecto**

</div>

```bash
# 1. Clona la plantilla externamente
git clone https://github.com/tu-usuario/wp-init.git /tmp/wp-init

# 2. Ejecuta desde ubicación externa
/tmp/wp-init/init-project.sh /ruta/a/tu/wordpress 1

# 3. Instala nuevas dependencias
cd /ruta/a/tu/proyecto
npm install && composer install

# 4. ¡Listo para desarrollar!
make dev
```

<div align="center">

✅ **Resultado**: Estándares integrados preservando tu configuración

</div>

</td>
</tr>
</table>

---

## 🌟 Nuevo: Flujo de Trabajo Externo

<div align="center">

### 🎯 **Flujo Recomendado para Proyectos Reales**

*Ejecuta desde ubicación externa para máxima seguridad y compatibilidad*

</div>

<table>
<tr>
<td align="center" width="50%">

### 🔴 **Flujo Anterior (Riesgoso)**
*Clonar en raíz del proyecto*

</td>
<td align="center" width="50%">

### 🟢 **Nuevo Flujo (Seguro)**
*Ejecutar desde ubicación externa*

</td>
</tr>
<tr>
<td width="50%">

```bash
# ❌ Flujo anterior (no recomendado)
cd /ruta/a/mi/proyecto
git clone wp-init .
./init-project.sh

# Problemas:
# - Puede sobrescribir archivos
# - Conflictos con .gitignore
# - Interfiere con Docker/CI/CD
# - Riesgo de perder configuración
```

</td>
<td width="50%">

```bash
# ✅ Nuevo flujo (recomendado)
git clone wp-init /tmp/wp-init
/tmp/wp-init/init-project.sh /ruta/a/mi/wordpress

# Ventajas:
# ✅ No interfiere con archivos del proyecto
# ✅ Preserva Docker/CI/CD existente
# ✅ Funciona con cualquier estructura
# ✅ Permite múltiples proyectos
# ✅ Cero riesgo de conflictos
```

</td>
</tr>
</table>

### 📋 Sintaxis del Flujo Externo

```bash
# Sintaxis completa
/ruta/a/wp-init/init-project.sh [WORDPRESS_PATH] [MODE] [OPTIONS]

# Ejemplos prácticos
/tmp/wp-init/init-project.sh /Users/dev/mi-proyecto/wordpress 1
/tmp/wp-init/init-project.sh ./mi-wordpress 2
/tmp/wp-init/init-project.sh /var/www/cliente/wp --help
```

### 🏗️ Estructuras de Proyecto Compatibles

<div align="center">

**🎯 El script detecta automáticamente la estructura y se adapta**

</div>

<table>
<tr>
<th width="33%">🐳 **Con Docker**</th>
<th width="33%">🔧 **Con CI/CD**</th>
<th width="33%">📁 **Estructura Personalizada**</th>
</tr>
<tr>
<td>

```text
mi-proyecto/
├── docker/
├── docker-compose.yml
├── Jenkinsfile
└── wordpress/          ← WordPress aquí
    └── wp-content/
```

**Comando:**
```bash
/tmp/wp-init/init-project.sh \
  /path/to/mi-proyecto/wordpress 1
```

</td>
<td>

```text
cliente-web/
├── .gitlab-ci.yml
├── README.md
├── docs/
└── wp/                 ← WordPress aquí
    └── wp-content/
```

**Comando:**
```bash
/tmp/wp-init/init-project.sh \
  /path/to/cliente-web/wp 2
```

</td>
<td>

```text
sitio-complejo/
├── backend/
├── frontend/
├── config/
└── cms-wordpress/      ← WordPress aquí
    └── wp-content/
```

**Comando:**
```bash
/tmp/wp-init/init-project.sh \
  /path/to/sitio-complejo/cms-wordpress
```

</td>
</tr>
</table>

### 🔍 Detección Automática de Estructura

El script incluye validación y confirmación automática:

```bash
══════════════════════════════════════════════════════════════
  📋 Resumen de Estructura Detectada
══════════════════════════════════════════════════════════════

✅ Estructura WordPress válida detectada

📁 Rutas del proyecto:
  • Raíz del proyecto: /Users/dev/mi-proyecto
  • Directorio WordPress: /Users/dev/mi-proyecto/wordpress
  • Ruta relativa: wordpress

📂 Estructura WordPress encontrada:
  • wp-content: ✓ /Users/dev/mi-proyecto/wordpress/wp-content
  • plugins: ✓ (3 directorios)
  • themes: ✓ (2 directorios)
  • mu-plugins: ⚠ (será creado automáticamente)

📄 Archivos del proyecto existentes:
  • ✓ composer.json (será preservado)
  • ✓ package.json (será preservado)
  • ✓ docker-compose.yml (será preservado)
  • ✓ Jenkinsfile (será preservado)

🔐 Permisos de escritura:
  • Raíz del proyecto: ✓ Escribible
  • Directorio WordPress: ✓ Escribible

══════════════════════════════════════════════════════════════
  ✅ Confirmación de Configuración
══════════════════════════════════════════════════════════════

¿La configuración detectada es correcta?

  Raíz del proyecto: /Users/dev/mi-proyecto
  WordPress: /Users/dev/mi-proyecto/wordpress
  Ruta relativa: wordpress

¿Continuar con esta configuración? (y/n): y
```

---

## 🎮 Modos de Operación

<div align="center">

### 🎯 **Cuatro modos optimizados para cada situación**

*El script `init-project.sh` se adapta perfectamente a tu caso de uso específico*

</div>

<table>
<tr>
<td align="center" width="25%">

### 1️⃣ **Proyecto Nuevo**
🆕 Configuración completa

</td>
<td align="center" width="25%">

### 2️⃣ **Solo Configuración**
⚙️ Sin tocar código

</td>
<td align="center" width="25%">

### 3️⃣ **Solo Formateo**
🎨 Usar config existente

</td>
<td align="center" width="25%">

### 4️⃣ **Fusionar Config**
🔄 Preservar dependencias

</td>
</tr>
</table>

---

### 1️⃣ Modo 1: Proyecto Nuevo Completo

<div align="center">

**🎯 Cuándo usar**: Inicias un proyecto WordPress desde cero y necesitas configuración completa con formateo.

</div>

<details>
<summary><strong>📋 Casos ideales (click para expandir)</strong></summary>

- ✅ Acabas de clonar la plantilla para un nuevo proyecto
- ✅ Quieres configurar todo desde el principio
- ✅ Necesitas formatear código existente que no sigue estándares
- ✅ Proyecto sin configuración previa de linting

</details>

<table>
<tr>
<td width="50%">

#### 🔧 **Lo que hace**

- ✅ **Detección automática**: Analiza estructura WordPress
- ✅ **Copia plantillas**: Adapta archivos de configuración
- ✅ **Genera configuración**: Crea archivos de linting
- ✅ **Configura dependencias**: Actualiza package.json y composer.json
- ✅ **Workspace VSCode**: Genera workspace optimizado
- ✅ **Formateo automático**: Aplica estándares WordPress
- ✅ **Backups seguros**: Respaldo antes de modificar
- ✅ **Validación completa**: Verifica requisitos

</td>
<td width="50%">

#### 🎯 **Resultado**

<div align="center">

**🚀 Proyecto completamente configurado y formateado**

*Listo para desarrollo profesional*

</div>

```bash
✅ Configuración completa
✅ Código formateado
✅ Herramientas instaladas
✅ Workspace optimizado
✅ Git hooks configurados
✅ CI/CD preparado
```

</td>
</tr>
</table>

---

### 2️⃣ Modo 2: Solo Configuración

<div align="center">

**⚙️ Cuándo usar**: Quieres configurar estándares sin tocar el código existente.

</div>

<details>
<summary><strong>📋 Casos ideales (click para expandir)</strong></summary>

- ✅ Proyecto con código ya formateado que no quieres modificar
- ✅ Necesitas solo la configuración de herramientas
- ✅ Quieres preservar el formateo actual del código
- ✅ Configuración inicial sin formateo automático

</details>

<table>
<tr>
<td width="50%">

#### 🔧 **Lo que hace**

- ✅ **Copia plantillas adaptadas**: Procesa archivos template
- ✅ **Genera configuración**: Crea archivos de linting
- ✅ **Workspace dinámico**: Configura VSCode optimizado
- ✅ **Targeting inteligente**: Rutas específicas por componente
- ✅ **Validación previa**: Verifica estructura y requisitos
- ✅ **Configuración personalizada**: Adapta prefixes y namespaces
- ❌ **No formatea código**: Respeta formateo actual

</td>
<td width="50%">

#### 🎯 **Resultado**

<div align="center">

**🛠️ Herramientas configuradas**

*Código existente intacto*

</div>

```bash
✅ Configuración lista
✅ Código preservado
✅ Herramientas instaladas
✅ Workspace configurado
❌ Sin formateo automático
```

</td>
</tr>
</table>

---

### 3️⃣ Modo 3: Solo Formateo

<div align="center">

**🎨 Cuándo usar**: Ya tienes configuración y solo necesitas formatear código.

</div>

<details>
<summary><strong>📋 Casos ideales (click para expandir)</strong></summary>

- ✅ Configuración de linting ya establecida
- ✅ Quieres aplicar formateo con reglas actuales
- ✅ Actualizar formateo sin cambiar configuración
- ✅ Formatear código después de cambios manuales

</details>

<table>
<tr>
<td width="50%">

#### 🔧 **Lo que hace**

- ✅ **Formateo PHP**: Aplica PHPCBF con config existente
- ✅ **Formateo JavaScript**: Ejecuta ESLint fix
- ✅ **Targeting específico**: Solo componentes seleccionados
- ✅ **Validación de configuración**: Verifica archivos existentes
- ✅ **Rutas dinámicas**: Paths específicos por componente
- ✅ **Reportes detallados**: Muestra cambios realizados
- ❌ **No modifica configuración**: Usa archivos existentes

</td>
<td width="50%">

#### 🎯 **Resultado**

<div align="center">

**✨ Código formateado**

*Configuración preservada*

</div>

```bash
✅ Código formateado
✅ Configuración intacta
✅ Reportes detallados
✅ Solo componentes seleccionados
❌ Sin cambios de config
```

</td>
</tr>
</table>

---

### 4️⃣ Modo 4: Fusionar Configuración (Avanzado)

<div align="center">

**🔄 Cuándo usar**: Proyecto existente con dependencias propias que necesitas preservar.

**⚠️ Requisitos**: `jq` instalado (`brew install jq` en macOS)

</div>

<details>
<summary><strong>📋 Casos ideales (click para expandir)</strong></summary>

- ✅ Proyecto con `package.json` y `composer.json` personalizados
- ✅ Necesitas añadir herramientas de linting sin perder dependencias
- ✅ Migración gradual a estándares WordPress
- ✅ Integración en proyectos con configuración compleja

</details>

<table>
<tr>
<td width="50%">

#### 🔧 **Lo que hace**

- ✅ **Fusión inteligente**: Combina package.json preservando dependencias
- ✅ **Merge de Composer**: Añade herramientas PHP sin eliminar paquetes
- ✅ **Backups automáticos**: Respaldo completo antes de cambios
- ✅ **Configuración adaptada**: Archivos de linting personalizados
- ✅ **Validación JSON**: Verifica sintaxis antes y después
- ✅ **Rollback automático**: Restaura backups si hay errores
- ✅ **Detección de conflictos**: Identifica y resuelve conflictos
- ✅ **Preservación de scripts**: Mantiene scripts NPM existentes

</td>
<td width="50%">

#### 🎯 **Resultado**

<div align="center">

**🔄 Integración perfecta**

*Sin perder configuración previa*

</div>

```bash
✅ Herramientas integradas
✅ Dependencias preservadas
✅ Scripts mantenidos
✅ Backups automáticos
✅ Rollback disponible
✅ Configuración fusionada
```

</td>
</tr>
</table>

---

### 🎯 Guía de Selección de Modo

<div align="center">

**¿No sabes qué modo elegir? Esta tabla te ayuda a decidir**

</div>

<table>
<tr>
<th width="40%">🎯 Situación</th>
<th width="20%">🎮 Modo Recomendado</th>
<th width="40%">💡 Razón</th>
</tr>
<tr>
<td>🆕 Proyecto nuevo desde plantilla</td>
<td align="center"><strong>Modo 1</strong></td>
<td>Configuración completa + formateo</td>
</tr>
<tr>
<td>🔧 Proyecto existente sin linting</td>
<td align="center"><strong>Modo 2</strong></td>
<td>Solo configuración, código intacto</td>
</tr>
<tr>
<td>🎨 Actualizar formateo solamente</td>
<td align="center"><strong>Modo 3</strong></td>
<td>Usar configuración actual</td>
</tr>
<tr>
<td>🔄 Proyecto con dependencias propias</td>
<td align="center"><strong>Modo 4</strong></td>
<td>Fusión sin pérdida de configuración</td>
</tr>
<tr>
<td>📝 Cambiar nombre de proyecto</td>
<td align="center"><strong>Modo 2</strong></td>
<td>Regenera configuración con nuevo nombre</td>
</tr>
<tr>
<td>➕ Añadir nuevos componentes</td>
<td align="center"><strong>Modo 3</strong></td>
<td>Formatear solo componentes nuevos</td>
</tr>
</table>

---

## 📖 Guía Detallada de Uso

<div align="center">

### 🎯 **Ejemplo Completo: Modo 1 (Proyecto Nuevo)**

*Esta guía te muestra paso a paso cómo usar el script para configurar un proyecto WordPress completamente desde cero*

</div>

<div align="center">

**⏱️ Tiempo estimado: 5-10 minutos** | **🎯 Dificultad: Principiante** | **📋 Requisitos: Node.js, Composer, Git**

</div>

---

#### 📋 Paso 1: Preparación del Proyecto

<div align="center">

**🎯 Objetivo**: Clonar la plantilla y verificar la estructura WordPress

</div>

```bash
# Clonar la plantilla para tu nuevo proyecto
git clone https://github.com/tu-usuario/wp-init.git mi-proyecto-ecommerce
cd mi-proyecto-ecommerce

# Verificar que tienes la estructura WordPress correcta
ls -la wordpress/wp-content/
```

<details>
<summary><strong>📋 Salida esperada (click para ver)</strong></summary>

```text
drwxr-xr-x  plugins/
drwxr-xr-x  themes/
drwxr-xr-x  mu-plugins/
```

</details>

<div align="center">

✅ **Verificación**: Si ves los directorios `plugins/`, `themes/` y `mu-plugins/`, ¡estás listo!

</div>

---

#### 🚀 Paso 2: Ejecutar el Script de Inicialización

<div align="center">

**🎯 Objetivo**: Iniciar el script y seleccionar el modo de operación

</div>

```bash
./init-project.sh
```

<details>
<summary><strong>📋 Salida del script (click para ver)</strong></summary>

```text
╔══════════════════════════════════════════════════════════════╗
║  🚀 WordPress Standards & Formatting                         ║
╚══════════════════════════════════════════════════════════════╝

✅ Requisitos verificados

══════════════════════════════════════════════════════════════
  Modo de Operación
══════════════════════════════════════════════════════════════
  1️⃣  Configurar y formatear proyecto
  2️⃣  Solo configurar (sin formatear)
  3️⃣  Solo formatear código existente

Selecciona modo (1-3): 1

ℹ️  Modo: Configurar y formatear

✅ Estructura detectada: wordpress/wp-content
```

</details>

<div align="center">

💡 **Tip**: Para un proyecto nuevo, siempre selecciona **Modo 1** para obtener la configuración completa

</div>

---

#### Paso 3: Detección y Selección de Componentes

```bash
ℹ️  Detectando componentes personalizados...

✅ Plugins detectados:
  📦 mi-plugin-custom
  📦 ecommerce-integration

✅ Temas detectados:
  🎨 mi-tema-principal
  🎨 flat101-starter-theme

══════════════════════════════════════════════════════════════
  Selección de Componentes
══════════════════════════════════════════════════════════════

--- Plugins ---
¿Incluir 'mi-plugin-custom'? (y/n): y
✅ Plugin 'mi-plugin-custom' añadido

¿Incluir 'ecommerce-integration'? (y/n): y
✅ Plugin 'ecommerce-integration' añadido

--- Temas ---
¿Incluir 'mi-tema-principal'? (y/n): y
✅ Tema 'mi-tema-principal' añadido

¿Incluir 'flat101-starter-theme'? (y/n): n
ℹ️  Tema 'flat101-starter-theme' omitido

══════════════════════════════════════════════════════════════
  Resumen
══════════════════════════════════════════════════════════════

Plugins (2):
  ✅ mi-plugin-custom
  ✅ ecommerce-integration

Temas (1):
  ✅ mi-tema-principal

¿Continuar? (y/n): y
```

#### Paso 4: Validación y Configuración del Proyecto

```bash
══════════════════════════════════════════════════════════════
  Validation & Pre-flight Checks
══════════════════════════════════════════════════════════════

ℹ️  Performing pre-execution validation checks...
✅ All validation checks passed

══════════════════════════════════════════════════════════════
  Configuración del Proyecto
══════════════════════════════════════════════════════════════

ℹ️  Buscando nombre del proyecto en archivos de configuración...

ℹ️  Detectado desde composer.json: mi-proyecto-ecommerce
¿Usar este nombre? (y/n): y

✅ Proyecto: mi-proyecto-ecommerce
```

#### Paso 5: Generación de Archivos de Configuración

```bash
══════════════════════════════════════════════════════════════
  Generando Archivos de Configuración
══════════════════════════════════════════════════════════════

ℹ️  Generando archivos de proyecto desde plantillas...

[100%] [████████████████████████████████] Processing .gitignore.template

✅ Generated .gitignore from .gitignore.template template
✅ Generated bitbucket-pipelines.yml from bitbucket-pipelines.yml template
✅ Generated commitlint.config.cjs from commitlint.config.cjs template
✅ Generated lighthouserc.js from lighthouserc.js template
✅ Generated Makefile from Makefile template
✅ Generated verify-template.sh from verify-template.sh template

ℹ️  Backup creado: ./backup-20241027-143022

ℹ️  Generando phpcs.xml.dist...
✅ phpcs.xml.dist generado

ℹ️  Generando phpstan.neon.dist...
✅ phpstan.neon.dist generado

ℹ️  Generando eslint.config.js...
✅ eslint.config.js generado

ℹ️  Generando package.json...
✅ package.json generado

ℹ️  Generando composer.json...
✅ composer.json generado

ℹ️  Generando configuración de VSCode...
✅ .vscode/ generado

ℹ️  Generating workspace file: wp.code-workspace
✅ Generated wp.code-workspace with 2 plugins, 1 themes, 0 mu-plugins

✅ Archivos de configuración generados
```

#### Paso 6: Formateo Automático del Código

```bash
══════════════════════════════════════════════════════════════
  Formateo Automático del Código
══════════════════════════════════════════════════════════════

ℹ️  Formateando código PHP con PHPCBF...

FILE                                                  FIXED  REMAINING
wordpress/wp-content/plugins/mi-plugin-custom/init.php    12        0
wordpress/wp-content/plugins/ecommerce-integration/main.php  8        0
wordpress/wp-content/themes/mi-tema-principal/functions.php  15        0

✅ PHP formateado (algunos archivos corregidos)

ℹ️  Building JavaScript paths for selected components...
ℹ️  Found 2 component path(s) for JavaScript formatting
ℹ️  Formateando código JavaScript con ESLint...

wordpress/wp-content/plugins/mi-plugin-custom/assets/js/admin.js
  ✓ 15 problems fixed

wordpress/wp-content/themes/mi-tema-principal/assets/js/theme.js
  ✓ 8 problems fixed

✅ Formateo completado
```

#### Paso 7: Resumen Final y Próximos Pasos

```bash
══════════════════════════════════════════════════════════════
  🎉 ¡Completado!
══════════════════════════════════════════════════════════════

✅ Archivos de configuración generados

Archivos creados:
  ✅ phpcs.xml.dist (WordPress PHP Standards)
  ✅ phpstan.neon.dist (PHP Static Analysis)
  ✅ eslint.config.js (WordPress JS Standards)
  ✅ composer.json (Dependencias PHP)
  ✅ package.json (Dependencias JS)
  ✅ wp.code-workspace (VSCode Workspace)
  ✅ .vscode/ (Configuración VSCode)

✅ Código formateado según estándares WordPress

══════════════════════════════════════════════════════════════
  Próximos Pasos
══════════════════════════════════════════════════════════════

1. Instalar dependencias:
   composer install
   npm install

2. Verificar estándares:
   ./vendor/bin/phpcs --standard=phpcs.xml.dist
   npx eslint '**/*.{js,jsx,ts,tsx}'

3. Formatear código:
   ./vendor/bin/phpcbf --standard=phpcs.xml.dist
   npx eslint --fix '**/*.{js,jsx,ts,tsx}'

✅ ¡Listo para desarrollar con estándares WordPress!

══════════════════════════════════════════════════════════════
  Operation Summary
══════════════════════════════════════════════════════════════

✅ Successfully processed 12 file(s)
ℹ️  Backup directory: ./backup-20241027-143022
ℹ️  Detailed log: ./init-project-20241027-143022.log
```

### Ejemplo Modo 2: Solo Configuración (Sin Formatear)

Para proyectos donde ya tienes código formateado y solo necesitas la configuración:

```bash
./init-project.sh

# Seleccionar modo 2
Selecciona modo (1-3): 2

ℹ️  Modo: Solo configurar

# El proceso es similar pero omite el formateo automático:
# - Detecta componentes
# - Permite selección
# - Genera archivos de configuración
# - NO formatea código existente

✅ Archivos de configuración generados
ℹ️  Código existente preservado sin cambios
```

### Ejemplo Modo 3: Solo Formatear Código

Para aplicar formateo usando configuración existente:

```bash
./init-project.sh

# Seleccionar modo 3
Selecciona modo (1-3): 3

ℹ️  Modo: Solo formatear

# Usa todos los componentes detectados automáticamente
# Requiere que phpcs.xml.dist ya exista

✅ Código formateado según estándares configurados
```

### Detección Automática de Nombre del Proyecto

El script intenta detectar automáticamente el nombre del proyecto desde:

1. **composer.json**: Extrae el nombre del campo `"name"`
2. **package.json**: Extrae el nombre del campo `"name"`
3. **Entrada manual**: Si no puede detectar, solicita entrada manual

```bash
# Ejemplo de detección exitosa:
ℹ️  Detectado desde composer.json: mi-proyecto-ecommerce
¿Usar este nombre? (y/n): y

# Ejemplo cuando no puede detectar:
⚠️  No se pudo detectar el nombre automáticamente

Nombre del proyecto (slug, ej: astro-headless): mi-nuevo-proyecto
```

### Validación de Componentes

El script valida que los componentes seleccionados realmente existan:

```bash
# Si un componente no existe:
❌ Selected plugin directory not found: wordpress/wp-content/plugins/plugin-inexistente

# Validación exitosa:
✅ All validation checks passed
```

### Sistema de Backups Automático

Antes de modificar archivos existentes, el script crea backups automáticos:

```bash
ℹ️  Backup creado: ./backup-20241027-143022/phpcs.xml.dist
ℹ️  Backup creado: ./backup-20241027-143022/eslint.config.js

# Estructura del backup:
backup-20241027-143022/
├── phpcs.xml.dist
├── eslint.config.js
├── package.json
└── composer.json
```

### Workspace de VSCode Generado

El script genera automáticamente un workspace de VSCode con los componentes seleccionados:

```json
{
  "folders": [
    {
      "path": "."
    },
    {
      "path": "wordpress/wp-content/plugins/mi-plugin-custom"
    },
    {
      "path": "wordpress/wp-content/themes/mi-tema-principal"
    }
  ],
  "settings": {
    "editor.rulers": [120],
    "phpsab.snifferMode": "onType",
    "[php]": {
      "editor.formatOnSave": true,
      "editor.defaultFormatter": "valeryanm.vscode-phpsab"
    }
  }
}
```

### Configuración Dinámica por Componente

Los archivos de configuración se adaptan automáticamente a tus componentes:

#### phpcs.xml.dist - Prefixes y Text Domains

```xml
<rule ref="WordPress.NamingConventions.PrefixAllGlobals">
    <properties>
        <property name="prefixes" type="array">
            <element value="mi_proyecto_ecommerce_"/>
            <element value="MI_PROYECTO_ECOMMERCE_"/>
            <element value="MiProyectoEcommerce\"/>
            <element value="mi_plugin_custom_"/>
            <element value="MI_PLUGIN_CUSTOM_"/>
            <element value="MiPluginCustom\"/>
        </property>
    </properties>
</rule>

<rule ref="WordPress.WP.I18n">
    <properties>
        <property name="text_domain" type="array">
            <element value="mi-proyecto-ecommerce"/>
            <element value="mi-plugin-custom"/>
            <element value="mi-tema-principal"/>
        </property>
    </properties>
</rule>

<!-- Files to check -->
<file>wordpress/wp-content/plugins/mi-plugin-custom</file>
<file>wordpress/wp-content/themes/mi-tema-principal</file>
```

#### eslint.config.js - Rutas Específicas

```javascript
export default [
  {
    files: [
      'wordpress/wp-content/plugins/mi-plugin-custom/**/*.{js,jsx,ts,tsx}',
      'wordpress/wp-content/themes/mi-tema-principal/**/*.{js,jsx,ts,tsx}',
    ],
    // ... reglas de WordPress
  }
];
```

## 📁 Operaciones de Archivos y Configuración

Esta sección detalla cómo el script procesa archivos de plantilla, genera configuraciones específicas del proyecto y maneja las operaciones de archivos de forma segura.

### Archivos de Plantilla Procesados

El script copia y adapta automáticamente varios archivos de plantilla, reemplazando variables con valores específicos de tu proyecto:

#### `.gitignore.template` → `.gitignore`

**Adaptaciones realizadas**:
- Rutas específicas de componentes seleccionados
- Directorios build/, node_modules/, vendor/ por componente
- Archivos de configuración locales

**Ejemplo de contenido adaptado**:
```gitignore
# Generado automáticamente para mi-proyecto-ecommerce

# WordPress core
wordpress/wp-config-local.php
wordpress/wp-content/uploads/

# Plugin build directories
wordpress/wp-content/plugins/mi-plugin-custom/build/
wordpress/wp-content/plugins/mi-plugin-custom/node_modules/
wordpress/wp-content/plugins/ecommerce-integration/build/
wordpress/wp-content/plugins/ecommerce-integration/node_modules/

# Theme build directories  
wordpress/wp-content/themes/mi-tema-principal/assets/build/
wordpress/wp-content/themes/mi-tema-principal/node_modules/

# Development files
.vscode/settings.json
.env.local
*.log
```

#### `bitbucket-pipelines.yml`

**Adaptaciones realizadas**:
- Nombres de proyecto en variables de entorno
- Rutas de componentes para build steps
- URLs específicas para deployment

**Ejemplo de contenido adaptado**:
```yaml
# Pipeline generado para mi-proyecto-ecommerce
image: node:18

definitions:
  steps:
    - step: &build-assets
        name: Build Assets
        script:
          # Build plugin assets
          - cd wordpress/wp-content/plugins/mi-plugin-custom && npm ci && npm run build
          - cd wordpress/wp-content/plugins/ecommerce-integration && npm ci && npm run build
          # Build theme assets
          - cd wordpress/wp-content/themes/mi-tema-principal && npm ci && npm run build
        artifacts:
          - wordpress/wp-content/plugins/*/build/**
          - wordpress/wp-content/themes/*/assets/build/**

pipelines:
  branches:
    develop:
      - step: *build-assets
      - step:
          name: Deploy to Staging
          deployment: staging
          script:
            - echo "Deploying mi-proyecto-ecommerce to staging..."
```

#### `lighthouserc.js`

**Adaptaciones realizadas**:
- URLs específicas del proyecto
- Configuración de CI adaptada al nombre del proyecto

**Ejemplo de contenido adaptado**:
```javascript
module.exports = {
  ci: {
    collect: {
      url: [
        'https://local.mi-proyecto-ecommerce.com/',
        'https://dev.mi-proyecto-ecommerce.levelstage.com/',
        'https://mi-proyecto-ecommerce.levelstage.com/'
      ],
      settings: {
        chromeFlags: '--no-sandbox --disable-dev-shm-usage'
      }
    },
    assert: {
      assertions: {
        'categories:performance': ['warn', { minScore: 0.8 }],
        'categories:accessibility': ['error', { minScore: 0.9 }]
      }
    },
    upload: {
      target: 'temporary-public-storage'
    }
  }
};
```

#### `Makefile`

**Adaptaciones realizadas**:
- Targets específicos para cada componente seleccionado
- Comandos dev y build personalizados
- Rutas dinámicas basadas en componentes

**Ejemplo de contenido adaptado**:
```makefile
# Makefile generado para mi-proyecto-ecommerce

# Plugin targets
dev-mi-plugin-custom: ## 🧩 Development for mi-plugin-custom plugin
    @cd wordpress/wp-content/plugins/mi-plugin-custom && npm run dev

build-mi-plugin-custom: ## 📦 Build mi-plugin-custom plugin assets
    @cd wordpress/wp-content/plugins/mi-plugin-custom && npm run build

dev-ecommerce-integration: ## 🧩 Development for ecommerce-integration plugin
    @cd wordpress/wp-content/plugins/ecommerce-integration && npm run dev

build-ecommerce-integration: ## 📦 Build ecommerce-integration plugin assets
    @cd wordpress/wp-content/plugins/ecommerce-integration && npm run build

# Theme targets
dev-mi-tema-principal: ## 🎨 Development for mi-tema-principal theme
    @cd wordpress/wp-content/themes/mi-tema-principal && npm run dev

build-mi-tema-principal: ## 📦 Build mi-tema-principal theme assets
    @cd wordpress/wp-content/themes/mi-tema-principal && npm run build

# Combined targets
dev-all: dev-mi-plugin-custom dev-ecommerce-integration dev-mi-tema-principal ## 🚀 Start all development servers

build-all: build-mi-plugin-custom build-ecommerce-integration build-mi-tema-principal ## 📦 Build all component assets
```

### Archivos de Configuración Generados

El script genera archivos de configuración específicos basados en los componentes seleccionados:

#### `phpcs.xml.dist` - WordPress PHP Coding Standards

**Configuración dinámica**:
- Prefixes globales basados en nombre del proyecto y componentes
- Text domains para i18n
- Rutas específicas de componentes a verificar
- Exclusiones automáticas de directorios build/

**Ejemplo de configuración generada**:
```xml
<?xml version="1.0"?>
<ruleset name="mi-proyecto-ecommerce">
    <description>WordPress Coding Standards para mi-proyecto-ecommerce</description>

    <!-- Prefixes para funciones globales -->
    <rule ref="WordPress.NamingConventions.PrefixAllGlobals">
        <properties>
            <property name="prefixes" type="array">
                <!-- Proyecto principal -->
                <element value="mi_proyecto_ecommerce_"/>
                <element value="MI_PROYECTO_ECOMMERCE_"/>
                <element value="MiProyectoEcommerce\"/>
                <!-- Plugin mi-plugin-custom -->
                <element value="mi_plugin_custom_"/>
                <element value="MI_PLUGIN_CUSTOM_"/>
                <element value="MiPluginCustom\"/>
                <!-- Plugin ecommerce-integration -->
                <element value="ecommerce_integration_"/>
                <element value="ECOMMERCE_INTEGRATION_"/>
                <element value="EcommerceIntegration\"/>
            </property>
        </properties>
    </rule>

    <!-- Text domains para i18n -->
    <rule ref="WordPress.WP.I18n">
        <properties>
            <property name="text_domain" type="array">
                <element value="mi-proyecto-ecommerce"/>
                <element value="mi-plugin-custom"/>
                <element value="ecommerce-integration"/>
                <element value="mi-tema-principal"/>
            </property>
        </properties>
    </rule>

    <!-- Archivos a verificar -->
    <file>wordpress/wp-content/plugins/mi-plugin-custom</file>
    <file>wordpress/wp-content/plugins/ecommerce-integration</file>
    <file>wordpress/wp-content/themes/mi-tema-principal</file>

    <!-- Exclusiones automáticas -->
    <exclude-pattern>*/node_modules/*</exclude-pattern>
    <exclude-pattern>*/vendor/*</exclude-pattern>
    <exclude-pattern>*/build/*</exclude-pattern>
    <exclude-pattern>*/assets/build/*</exclude-pattern>
</ruleset>
```

#### `eslint.config.js` - WordPress JavaScript Standards

**Configuración dinámica**:
- Rutas específicas de JavaScript por componente
- Globals de WordPress configurados
- Reglas específicas para diferentes tipos de archivos

**Ejemplo de configuración generada**:
```javascript
import js from '@eslint/js';
import globals from 'globals';

export default [
  js.configs.recommended,
  {
    files: [
      'wordpress/wp-content/plugins/mi-plugin-custom/**/*.{js,jsx,ts,tsx}',
      'wordpress/wp-content/plugins/ecommerce-integration/**/*.{js,jsx,ts,tsx}',
      'wordpress/wp-content/themes/mi-tema-principal/**/*.{js,jsx,ts,tsx}',
    ],
    languageOptions: {
      ecmaVersion: 2022,
      sourceType: 'module',
      globals: {
        ...globals.browser,
        ...globals.jquery,
        wp: 'readonly',
        jQuery: 'readonly',
        $: 'readonly',
        __: 'readonly',
        _e: 'readonly',
        _x: 'readonly',
        _n: 'readonly',
        _nx: 'readonly',
        sprintf: 'readonly',
        ajaxurl: 'readonly'
      }
    },
    rules: {
      // WordPress JavaScript Coding Standards
      'array-bracket-spacing': ['error', 'always'],
      'brace-style': ['error', '1tbs'],
      'comma-spacing': 'error',
      'computed-property-spacing': ['error', 'always'],
      'constructor-super': 'error',
      'dot-notation': 'error',
      'eol-last': 'error',
      'func-call-spacing': 'error',
      'indent': ['error', 'tab'],
      'key-spacing': 'error',
      'keyword-spacing': 'error',
      'lines-around-comment': 'off',
      'no-alert': 'error',
      'no-bitwise': 'error',
      'no-caller': 'error',
      'no-console': 'warn',
      'no-debugger': 'error',
      'no-dupe-args': 'error',
      'no-dupe-keys': 'error',
      'no-duplicate-case': 'error',
      'no-else-return': 'error',
      'no-eval': 'error',
      'no-extra-semi': 'error',
      'no-fallthrough': 'error',
      'no-lonely-if': 'error',
      'no-mixed-spaces-and-tabs': 'error',
      'no-multiple-empty-lines': ['error', { max: 1 }],
      'no-nested-ternary': 'error',
      'no-redeclare': 'error',
      'no-shadow': 'error',
      'no-undef': 'error',
      'no-undef-init': 'error',
      'no-unreachable': 'error',
      'no-unsafe-negation': 'error',
      'no-unused-expressions': 'error',
      'no-unused-vars': 'error',
      'object-curly-spacing': ['error', 'always'],
      'padded-blocks': ['error', 'never'],
      'prefer-const': 'error',
      'quote-props': ['error', 'as-needed'],
      'quotes': ['error', 'single'],
      'semi': 'error',
      'semi-spacing': 'error',
      'space-before-blocks': ['error', 'always'],
      'space-before-function-paren': ['error', 'never'],
      'space-in-parens': ['error', 'always'],
      'space-infix-ops': ['error', { int32Hint: false }],
      'space-unary-ops': [
        'error',
        {
          overrides: {
            '!': true
          }
        }
      ],
      'valid-jsdoc': ['error', { requireReturn: false }],
      'valid-typeof': 'error',
      'yoda': 'off'
    }
  }
];
```

#### `phpstan.neon.dist` - PHP Static Analysis

**Configuración dinámica**:
- Paths específicos de componentes
- WordPress stubs incluidos
- Configuración de nivel de análisis

**Ejemplo de configuración generada**:
```neon
parameters:
    level: 5
    paths:
        - wordpress/wp-content/plugins/mi-plugin-custom
        - wordpress/wp-content/plugins/ecommerce-integration
        - wordpress/wp-content/themes/mi-tema-principal
    
    bootstrapFiles:
        - vendor/php-stubs/wordpress-stubs/wordpress-stubs.php
    
    excludePaths:
        - */node_modules/*
        - */vendor/*
        - */build/*
        - */assets/build/*
    
    ignoreErrors:
        # WordPress specific ignores
        - '#Function apply_filters invoked with [0-9]+ parameters, 2 required#'
        - '#Function do_action invoked with [0-9]+ parameters, 1 required#'
        - '#Function add_action invoked with [0-9]+ parameters, 2 required#'
        - '#Function add_filter invoked with [0-9]+ parameters, 2 required#'
```

### Generación de Workspace VSCode

El script genera automáticamente un archivo `wp.code-workspace` que configura VSCode para trabajar eficientemente con los componentes seleccionados:

#### Estructura del Workspace

**Ejemplo de workspace generado**:
```json
{
  "folders": [
    {
      "name": "🏠 Proyecto Principal",
      "path": "."
    },
    {
      "name": "🧩 mi-plugin-custom",
      "path": "wordpress/wp-content/plugins/mi-plugin-custom"
    },
    {
      "name": "🧩 ecommerce-integration", 
      "path": "wordpress/wp-content/plugins/ecommerce-integration"
    },
    {
      "name": "🎨 mi-tema-principal",
      "path": "wordpress/wp-content/themes/mi-tema-principal"
    }
  ],
  "settings": {
    "editor.rulers": [120],
    "editor.insertSpaces": false,
    "editor.detectIndentation": false,
    "editor.tabSize": 4,
    
    // PHP Settings
    "phpsab.snifferMode": "onType",
    "phpsab.standard": "phpcs.xml.dist",
    "[php]": {
      "editor.formatOnSave": true,
      "editor.defaultFormatter": "valeryanm.vscode-phpsab"
    },
    
    // JavaScript Settings
    "eslint.workingDirectories": [
      "wordpress/wp-content/plugins/mi-plugin-custom",
      "wordpress/wp-content/plugins/ecommerce-integration", 
      "wordpress/wp-content/themes/mi-tema-principal"
    ],
    "[javascript]": {
      "editor.formatOnSave": true,
      "editor.defaultFormatter": "dbaeumer.vscode-eslint"
    },
    "[javascriptreact]": {
      "editor.formatOnSave": true,
      "editor.defaultFormatter": "dbaeumer.vscode-eslint"
    },
    
    // CSS Settings
    "stylelint.validate": ["css", "scss"],
    "[css]": {
      "editor.formatOnSave": true,
      "editor.defaultFormatter": "stylelint.vscode-stylelint"
    },
    "[scss]": {
      "editor.formatOnSave": true,
      "editor.defaultFormatter": "stylelint.vscode-stylelint"
    },
    
    // File associations
    "files.associations": {
      "*.php": "php",
      "*.inc": "php",
      "*.module": "php"
    },
    
    // Search settings
    "search.exclude": {
      "**/node_modules": true,
      "**/vendor": true,
      "**/build": true,
      "**/*.min.js": true,
      "**/*.min.css": true
    }
  },
  "extensions": {
    "recommendations": [
      "bmewburn.vscode-intelephense-client",
      "valeryanm.vscode-phpsab", 
      "dbaeumer.vscode-eslint",
      "stylelint.vscode-stylelint",
      "esbenp.prettier-vscode",
      "editorconfig.editorconfig"
    ]
  }
}
```

### Sistema de Backups Automático

Antes de modificar cualquier archivo existente, el script crea backups automáticos para permitir rollback en caso de problemas:

#### Estructura de Backups

**Directorio de backup creado**:
```bash
backup-20241027-143022/
├── phpcs.xml.dist              # Backup de configuración PHP anterior
├── eslint.config.js            # Backup de configuración JS anterior  
├── package.json                # Backup de dependencias NPM anteriores
├── composer.json               # Backup de dependencias PHP anteriores
├── wp.code-workspace           # Backup de workspace anterior
├── .vscode/
│   └── settings.json           # Backup de configuración VSCode anterior
└── backup-info.json            # Metadatos del backup
```

**Archivo de metadatos del backup**:
```json
{
  "timestamp": "2024-10-27T14:30:22.123Z",
  "mode": "1",
  "project_name": "mi-proyecto-ecommerce",
  "components": {
    "plugins": ["mi-plugin-custom", "ecommerce-integration"],
    "themes": ["mi-tema-principal"],
    "mu_plugins": []
  },
  "files_backed_up": [
    "phpcs.xml.dist",
    "eslint.config.js", 
    "package.json",
    "composer.json",
    "wp.code-workspace"
  ],
  "script_version": "2.1.0"
}
```

#### Proceso de Backup

**Secuencia automática**:
1. **Detección**: El script identifica archivos existentes que serán modificados
2. **Creación de directorio**: Crea `backup-YYYYMMDD-HHMMSS/`
3. **Copia de archivos**: Copia cada archivo existente al directorio de backup
4. **Generación de metadatos**: Crea `backup-info.json` con información del backup
5. **Verificación**: Confirma que todos los archivos fueron respaldados correctamente
6. **Continuación**: Procede con la modificación de archivos originales

**Ejemplo de salida durante backup**:
```bash
ℹ️  Creando backup de archivos existentes...
ℹ️  Backup creado: ./backup-20241027-143022

✅ Backup creado: ./backup-20241027-143022/phpcs.xml.dist
✅ Backup creado: ./backup-20241027-143022/eslint.config.js
✅ Backup creado: ./backup-20241027-143022/package.json
✅ Backup creado: ./backup-20241027-143022/composer.json
✅ Backup creado: ./backup-20241027-143022/wp.code-workspace

ℹ️  5 archivos respaldados correctamente
```

### Fusión Inteligente de Archivos (Modo 4)

En el Modo 4, el script utiliza `jq` para fusionar archivos JSON de forma inteligente, preservando configuración existente:

#### Fusión de package.json

**Proceso de fusión**:
1. **Lectura**: Lee `package.json` existente y plantilla
2. **Merge de dependencias**: Combina `devDependencies` sin duplicados
3. **Merge de scripts**: Añade scripts de linting preservando existentes
4. **Preservación**: Mantiene `dependencies`, `name`, `version` originales
5. **Validación**: Verifica sintaxis JSON del resultado

**Ejemplo de fusión**:
```bash
# package.json original
{
  "name": "mi-proyecto-existente",
  "version": "1.0.0", 
  "dependencies": {
    "lodash": "^4.17.21",
    "axios": "^1.6.0"
  },
  "scripts": {
    "build": "webpack --mode=production",
    "dev": "webpack serve --mode=development"
  }
}

# Después de la fusión
{
  "name": "mi-proyecto-existente",        # Preservado
  "version": "1.0.0",                     # Preservado
  "dependencies": {                       # Preservado completamente
    "lodash": "^4.17.21",
    "axios": "^1.6.0"
  },
  "devDependencies": {                    # Fusionado
    "@wordpress/eslint-plugin": "^17.0.0",
    "eslint": "^8.57.0",
    "stylelint": "^16.0.0",
    "husky": "^8.0.3",
    "lint-staged": "^15.0.0"
  },
  "scripts": {                            # Fusionado
    "build": "webpack --mode=production", # Preservado
    "dev": "webpack serve --mode=development", # Preservado
    "lint:js": "eslint '**/*.{js,jsx,ts,tsx}'", # Añadido
    "lint:css": "stylelint '**/*.{css,scss}'",  # Añadido
    "lint:php": "./vendor/bin/phpcs --standard=phpcs.xml.dist", # Añadido
    "format": "npm run lint:js:fix && npm run lint:css:fix && npm run lint:php:fix" # Añadido
  }
}
```

#### Fusión de composer.json

**Proceso similar para PHP**:
```bash
# composer.json original
{
  "name": "mi-empresa/mi-proyecto",
  "require": {
    "guzzlehttp/guzzle": "^7.8",
    "monolog/monolog": "^3.0"
  }
}

# Después de la fusión  
{
  "name": "mi-empresa/mi-proyecto",       # Preservado
  "require": {                            # Preservado completamente
    "guzzlehttp/guzzle": "^7.8",
    "monolog/monolog": "^3.0"
  },
  "require-dev": {                        # Fusionado
    "squizlabs/php_codesniffer": "^3.8.0",
    "wp-coding-standards/wpcs": "^3.0.0",
    "phpstan/phpstan": "^1.10.0",
    "php-stubs/wordpress-stubs": "^6.4.0"
  },
  "scripts": {                            # Añadido
    "lint:php": "phpcs --standard=phpcs.xml.dist",
    "lint:php:fix": "phpcbf --standard=phpcs.xml.dist",
    "analyze:php": "phpstan analyse"
  }
}
```

### Validación y Manejo de Errores

El script incluye múltiples capas de validación para garantizar operaciones seguras:

#### Validaciones Pre-ejecución

**Verificaciones automáticas**:
```bash
✅ Verificando estructura WordPress...
✅ Verificando permisos de escritura...
✅ Verificando dependencias requeridas...
✅ Verificando componentes seleccionados...
✅ Verificando archivos de plantilla...
```

#### Validaciones Durante Ejecución

**Verificaciones continuas**:
- **Sintaxis JSON**: Valida archivos JSON antes y después de modificaciones
- **Permisos de archivos**: Verifica permisos antes de escribir
- **Integridad de backups**: Confirma que los backups se crearon correctamente
- **Existencia de directorios**: Verifica que los componentes seleccionados existen

#### Manejo de Errores y Rollback

**En caso de error**:
```bash
❌ Error detectado durante la generación de phpcs.xml.dist
ℹ️  Iniciando rollback automático...
✅ Restaurado: phpcs.xml.dist desde backup-20241027-143022/
✅ Restaurado: eslint.config.js desde backup-20241027-143022/
ℹ️  Rollback completado. Proyecto restaurado al estado anterior.
```

**Proceso de rollback**:
1. **Detección de error**: El script detecta fallo en cualquier operación
2. **Parada inmediata**: Detiene todas las operaciones pendientes
3. **Restauración**: Copia archivos desde el directorio de backup
4. **Verificación**: Confirma que la restauración fue exitosa
5. **Reporte**: Informa al usuario sobre el rollback realizado

Esta arquitectura de operaciones de archivos garantiza que el script sea seguro, confiable y reversible, permitiendo a los desarrolladores experimentar con configuraciones sin riesgo de perder trabajo previo.

## 📊 Antes y Después: Transformación del Proyecto

<div align="center">

### 🔄 **Transformación Completa de tu Proyecto WordPress**

*Observa cómo el script convierte un proyecto básico en una configuración profesional*

</div>

<table>
<tr>
<td align="center" width="50%">

### 🔴 **ANTES**
*Proyecto WordPress básico*

</td>
<td align="center" width="50%">

### 🟢 **DESPUÉS**
*Proyecto WordPress profesional*

</td>
</tr>
</table>

---

### 🔄 Estructura del Proyecto: Antes vs Después

<table>
<tr>
<td width="50%">

#### 🔴 **ANTES: Proyecto WordPress Básico**

```text
mi-proyecto-ecommerce/
├── wordpress/
│   └── wp-content/
│       ├── plugins/
│       │   ├── mi-plugin-custom/
│       │   │   ├── init.php                    # ❌ Sin formatear
│       │   │   ├── includes/
│       │   │   │   └── functions.php           # ❌ Sin formatear
│       │   │   └── assets/
│       │   │       └── js/
│       │   │           └── admin.js            # ❌ Sin formatear
│       │   └── ecommerce-integration/
│       │       ├── main.php                    # ❌ Sin formatear
│       │       └── assets/
│       │           └── js/
│       │               └── checkout.js         # ❌ Sin formatear
│       └── themes/
│           └── mi-tema-principal/
│               ├── functions.php               # ❌ Sin formatear
│               ├── style.css
│               └── assets/
│                   └── js/
│                       └── theme.js            # ❌ Sin formatear
│
├── composer.json                               # ⚠️  Básico, sin herramientas
├── package.json                                # ⚠️  Básico, sin herramientas
└── README.md
```

**❌ Problemas identificados**:
- Sin estándares de código configurados
- Sin herramientas de linting
- Sin formateo automático
- Sin configuración de desarrollo
- Sin workspace de VSCode
- Sin pipeline de CI/CD

</td>
<td width="50%">

#### 🟢 **DESPUÉS: Proyecto WordPress Profesional**

```text
mi-proyecto-ecommerce/
├── wordpress/
│   └── wp-content/
│       ├── plugins/
│       │   ├── mi-plugin-custom/
│       │   │   ├── init.php                    # ✅ Formateado con WPCS
│       │   │   ├── includes/
│       │   │   │   └── functions.php           # ✅ Formateado con WPCS
│       │   │   └── assets/
│       │   │       └── js/
│       │   │           └── admin.js            # ✅ Formateado con ESLint
│       │   └── ecommerce-integration/
│       │       ├── main.php                    # ✅ Formateado con WPCS
│       │       └── assets/
│       │           └── js/
│       │               └── checkout.js         # ✅ Formateado con ESLint
│       └── themes/
│           └── mi-tema-principal/
│               ├── functions.php               # ✅ Formateado con WPCS
│               ├── style.css
│               └── assets/
│                   └── js/
│                       └── theme.js            # ✅ Formateado con ESLint
│
├── .vscode/                                    # 🆕 Configuración VSCode
│   ├── settings.json                           # 🆕 Formateo automático
│   └── extensions.json                         # 🆕 Extensiones recomendadas
│
├── .husky/                                     # 🆕 Git hooks
│   └── pre-commit                              # 🆕 Linting automático
│
├── backup-20241027-143022/                     # 🆕 Backup automático
│   ├── phpcs.xml.dist                          # 🆕 Backup configuración anterior
│   ├── package.json                            # 🆕 Backup dependencias anteriores
│   └── composer.json                           # 🆕 Backup dependencias anteriores
│
├── .gitignore                                  # 🆕 Generado desde template
├── bitbucket-pipelines.yml                     # 🆕 Pipeline CI/CD
├── commitlint.config.cjs                       # 🆕 Conventional Commits
├── lighthouserc.js                             # 🆕 Performance testing
├── Makefile                                    # 🆕 Comandos de desarrollo
│
├── phpcs.xml.dist                              # 🆕 WordPress PHP Standards
├── phpstan.neon.dist                           # 🆕 PHP Static Analysis
├── eslint.config.js                            # 🆕 WordPress JS Standards
│
├── composer.json                               # ✅ Actualizado con herramientas
├── package.json                                # ✅ Actualizado con herramientas
├── wp.code-workspace                           # 🆕 Workspace VSCode
│
├── init-project-20241027-143022.log            # 🆕 Log detallado
└── README.md
```

**✅ Mejoras implementadas**:
- WordPress Coding Standards configurados
- Herramientas de linting (PHPCS, ESLint, Stylelint)
- Formateo automático en pre-commit
- Configuración de desarrollo completa
- Workspace VSCode optimizado
- Pipeline CI/CD configurado
- Backups automáticos de seguridad

</td>
</tr>
</table>

### Ejemplos de Archivos Generados

#### 📄 phpcs.xml.dist - WordPress PHP Coding Standards

**Configuración generada automáticamente**:

```xml
<?xml version="1.0"?>
<ruleset name="mi-proyecto-ecommerce">
    <description>WordPress Coding Standards para mi-proyecto-ecommerce</description>
    
    <!-- WordPress Coding Standards -->
    <rule ref="WordPress"/>
    <rule ref="WordPress-Extra"/>
    <rule ref="WordPress-Docs"/>
    
    <!-- Prefixes para funciones globales -->
    <rule ref="WordPress.NamingConventions.PrefixAllGlobals">
        <properties>
            <property name="prefixes" type="array">
                <!-- 🎯 Proyecto principal -->
                <element value="mi_proyecto_ecommerce_"/>
                <element value="MI_PROYECTO_ECOMMERCE_"/>
                <element value="MiProyectoEcommerce\"/>
                
                <!-- 🧩 Plugin mi-plugin-custom -->
                <element value="mi_plugin_custom_"/>
                <element value="MI_PLUGIN_CUSTOM_"/>
                <element value="MiPluginCustom\"/>
                
                <!-- 🛒 Plugin ecommerce-integration -->
                <element value="ecommerce_integration_"/>
                <element value="ECOMMERCE_INTEGRATION_"/>
                <element value="EcommerceIntegration\"/>
            </property>
        </properties>
    </rule>
    
    <!-- Text domains para i18n -->
    <rule ref="WordPress.WP.I18n">
        <properties>
            <property name="text_domain" type="array">
                <element value="mi-proyecto-ecommerce"/>      <!-- 🏠 Proyecto -->
                <element value="mi-plugin-custom"/>           <!-- 🧩 Plugin -->
                <element value="ecommerce-integration"/>      <!-- 🛒 Plugin -->
                <element value="mi-tema-principal"/>          <!-- 🎨 Tema -->
            </property>
        </properties>
    </rule>
    
    <!-- 📁 Archivos a verificar (solo componentes seleccionados) -->
    <file>wordpress/wp-content/plugins/mi-plugin-custom</file>
    <file>wordpress/wp-content/plugins/ecommerce-integration</file>
    <file>wordpress/wp-content/themes/mi-tema-principal</file>
    
    <!-- ❌ Exclusiones automáticas -->
    <exclude-pattern>*/node_modules/*</exclude-pattern>
    <exclude-pattern>*/vendor/*</exclude-pattern>
    <exclude-pattern>*/build/*</exclude-pattern>
    <exclude-pattern>*/assets/build/*</exclude-pattern>
    <exclude-pattern>*.min.js</exclude-pattern>
    <exclude-pattern>*.min.css</exclude-pattern>
</ruleset>
```

#### 📄 eslint.config.js - WordPress JavaScript Standards

**Configuración con rutas específicas**:

```javascript
import js from '@eslint/js';
import globals from 'globals';

export default [
    js.configs.recommended,
    {
        // 🎯 Solo archivos de componentes seleccionados
        files: [
            'wordpress/wp-content/plugins/mi-plugin-custom/**/*.{js,jsx,ts,tsx}',
            'wordpress/wp-content/plugins/ecommerce-integration/**/*.{js,jsx,ts,tsx}',
            'wordpress/wp-content/themes/mi-tema-principal/**/*.{js,jsx,ts,tsx}',
        ],
        
        languageOptions: {
            ecmaVersion: 2022,
            sourceType: 'module',
            globals: {
                ...globals.browser,
                ...globals.jquery,
                
                // 🌐 WordPress globals
                wp: 'readonly',
                jQuery: 'readonly',
                $: 'readonly',
                
                // 🌍 WordPress i18n
                __: 'readonly',
                _e: 'readonly',
                _x: 'readonly',
                _n: 'readonly',
                _nx: 'readonly',
                sprintf: 'readonly',
                
                // 🔗 WordPress AJAX
                ajaxurl: 'readonly',
                
                // 📦 Proyecto específico
                miProyectoEcommerce: 'readonly',
                MI_PROYECTO_ECOMMERCE: 'readonly'
            }
        },
        
        rules: {
            // 📏 WordPress JavaScript Coding Standards
            'array-bracket-spacing': ['error', 'always'],
            'brace-style': ['error', '1tbs'],
            'comma-spacing': 'error',
            'computed-property-spacing': ['error', 'always'],
            'indent': ['error', 'tab'],
            'key-spacing': 'error',
            'keyword-spacing': 'error',
            'no-console': 'warn',
            'no-debugger': 'error',
            'no-unused-vars': 'error',
            'object-curly-spacing': ['error', 'always'],
            'quotes': ['error', 'single'],
            'semi': 'error',
            'space-before-blocks': ['error', 'always'],
            'space-before-function-paren': ['error', 'never'],
            'space-in-parens': ['error', 'always'],
            'space-infix-ops': ['error', { int32Hint: false }]
        }
    }
];
```

#### 📄 wp.code-workspace - VSCode Workspace

**Workspace generado dinámicamente**:

```json
{
    "folders": [
        {
            "name": "🏠 Proyecto Principal",
            "path": "."
        },
        {
            "name": "🧩 mi-plugin-custom",
            "path": "wordpress/wp-content/plugins/mi-plugin-custom"
        },
        {
            "name": "🛒 ecommerce-integration",
            "path": "wordpress/wp-content/plugins/ecommerce-integration"
        },
        {
            "name": "🎨 mi-tema-principal",
            "path": "wordpress/wp-content/themes/mi-tema-principal"
        }
    ],
    
    "settings": {
        // 📏 Editor general
        "editor.rulers": [120],
        "editor.insertSpaces": false,
        "editor.detectIndentation": false,
        "editor.tabSize": 4,
        
        // 🐘 PHP Settings
        "phpsab.snifferMode": "onType",
        "phpsab.standard": "phpcs.xml.dist",
        "[php]": {
            "editor.formatOnSave": true,
            "editor.defaultFormatter": "valeryanm.vscode-phpsab"
        },
        
        // 🟨 JavaScript Settings
        "eslint.workingDirectories": [
            "wordpress/wp-content/plugins/mi-plugin-custom",
            "wordpress/wp-content/plugins/ecommerce-integration",
            "wordpress/wp-content/themes/mi-tema-principal"
        ],
        "[javascript]": {
            "editor.formatOnSave": true,
            "editor.defaultFormatter": "dbaeumer.vscode-eslint"
        },
        
        // 🎨 CSS Settings
        "stylelint.validate": ["css", "scss"],
        "[css]": {
            "editor.formatOnSave": true,
            "editor.defaultFormatter": "stylelint.vscode-stylelint"
        },
        
        // 🔍 Search settings
        "search.exclude": {
            "**/node_modules": true,
            "**/vendor": true,
            "**/build": true,
            "**/*.min.js": true,
            "**/*.min.css": true
        }
    },
    
    "extensions": {
        "recommendations": [
            "bmewburn.vscode-intelephense-client",    // 🐘 PHP IntelliSense
            "valeryanm.vscode-phpsab",                // 🐘 PHP Standards
            "dbaeumer.vscode-eslint",                 // 🟨 JavaScript Linting
            "stylelint.vscode-stylelint",             // 🎨 CSS Linting
            "esbenp.prettier-vscode",                 // ✨ Code Formatter
            "editorconfig.editorconfig"               // 📏 Editor Config
        ]
    }
}
```

#### 📄 package.json - Scripts NPM Actualizados

**Antes (básico)**:
```json
{
    "name": "mi-proyecto-ecommerce",
    "version": "1.0.0",
    "scripts": {
        "build": "webpack --mode=production"
    },
    "dependencies": {
        "lodash": "^4.17.21"
    }
}
```

**Después (completo)**:
```json
{
    "name": "mi-proyecto-ecommerce",
    "version": "1.0.0",
    "scripts": {
        "build": "webpack --mode=production",
        
        // 🔍 Linting
        "lint:js": "eslint 'wordpress/wp-content/**/*.{js,jsx,ts,tsx}'",
        "lint:css": "stylelint 'wordpress/wp-content/**/*.{css,scss}'",
        "lint:php": "./vendor/bin/phpcs --standard=phpcs.xml.dist",
        
        // ✨ Formateo
        "lint:js:fix": "eslint --fix 'wordpress/wp-content/**/*.{js,jsx,ts,tsx}'",
        "lint:css:fix": "stylelint --fix 'wordpress/wp-content/**/*.{css,scss}'",
        "lint:php:fix": "./vendor/bin/phpcbf --standard=phpcs.xml.dist",
        
        // 🚀 Desarrollo
        "dev:all": "concurrently \"npm run dev:plugin\" \"npm run dev:theme\"",
        "dev:plugin": "cd wordpress/wp-content/plugins/mi-plugin-custom && npm run dev",
        "dev:theme": "cd wordpress/wp-content/themes/mi-tema-principal && npm run dev",
        
        // 📦 Build
        "build:all": "npm run build:plugin && npm run build:theme",
        "build:plugin": "cd wordpress/wp-content/plugins/mi-plugin-custom && npm run build",
        "build:theme": "cd wordpress/wp-content/themes/mi-tema-principal && npm run build",
        
        // ✅ Verificación
        "verify:standards": "npm run lint:js && npm run lint:css && npm run lint:php",
        "quick-check": "npm run lint:js && npm run lint:php",
        "commit-ready": "npm run verify:standards && npm run analyze:php"
    },
    
    "dependencies": {
        "lodash": "^4.17.21"                        // ✅ Preservado
    },
    
    "devDependencies": {
        // 🔍 Linting tools
        "@wordpress/eslint-plugin": "^17.0.0",
        "eslint": "^8.57.0",
        "stylelint": "^16.0.0",
        "stylelint-config-wordpress": "^17.0.0",
        
        // 🎯 Git hooks
        "husky": "^8.0.3",
        "lint-staged": "^15.0.0",
        
        // 🛠️ Development tools
        "concurrently": "^8.2.0",
        "cross-env": "^7.0.3"
    },
    
    "lint-staged": {
        "*.php": [
            "./vendor/bin/phpcbf --standard=phpcs.xml.dist",
            "./vendor/bin/phpcs --standard=phpcs.xml.dist"
        ],
        "*.{js,jsx,ts,tsx}": [
            "eslint --fix",
            "eslint"
        ],
        "*.{css,scss}": [
            "stylelint --fix",
            "stylelint"
        ]
    }
}
```

### Targeting Específico por Componente

El script configura rutas específicas para cada componente seleccionado, optimizando el rendimiento del linting:

#### 🎯 Rutas de Linting Configuradas

**PHPCS (phpcs.xml.dist)**:
```xml
<!-- ✅ Solo componentes seleccionados -->
<file>wordpress/wp-content/plugins/mi-plugin-custom</file>
<file>wordpress/wp-content/plugins/ecommerce-integration</file>
<file>wordpress/wp-content/themes/mi-tema-principal</file>

<!-- ❌ Componentes excluidos automáticamente -->
<!-- <file>wordpress/wp-content/plugins/akismet</file> -->
<!-- <file>wordpress/wp-content/themes/twentytwentyfour</file> -->
```

**ESLint (eslint.config.js)**:
```javascript
files: [
    // ✅ Solo JavaScript de componentes seleccionados
    'wordpress/wp-content/plugins/mi-plugin-custom/**/*.{js,jsx,ts,tsx}',
    'wordpress/wp-content/plugins/ecommerce-integration/**/*.{js,jsx,ts,tsx}',
    'wordpress/wp-content/themes/mi-tema-principal/**/*.{js,jsx,ts,tsx}',
    
    // ❌ Excluye automáticamente otros componentes
    // '!wordpress/wp-content/plugins/akismet/**/*',
    // '!wordpress/wp-content/themes/twentytwentyfour/**/*'
]
```

**VSCode Workspace**:
```json
{
    "folders": [
        {"path": "."},                                                          // 🏠 Raíz
        {"path": "wordpress/wp-content/plugins/mi-plugin-custom"},              // ✅ Incluido
        {"path": "wordpress/wp-content/plugins/ecommerce-integration"},         // ✅ Incluido
        {"path": "wordpress/wp-content/themes/mi-tema-principal"}               // ✅ Incluido
        // ❌ Otros componentes no incluidos en workspace
    ],
    "settings": {
        "eslint.workingDirectories": [
            "wordpress/wp-content/plugins/mi-plugin-custom",                    // ✅ ESLint activo
            "wordpress/wp-content/plugins/ecommerce-integration",               // ✅ ESLint activo
            "wordpress/wp-content/themes/mi-tema-principal"                     // ✅ ESLint activo
        ]
    }
}
```

### Indicadores Visuales: Creado vs Modificado

#### 🆕 Archivos Creados (Nuevos)

```text
🆕 .gitignore                    # Generado desde .gitignore.template
🆕 bitbucket-pipelines.yml       # Pipeline CI/CD
🆕 commitlint.config.cjs         # Conventional Commits
🆕 lighthouserc.js               # Performance testing
🆕 Makefile                      # Comandos de desarrollo
🆕 phpcs.xml.dist                # WordPress PHP Standards
🆕 phpstan.neon.dist             # PHP Static Analysis
🆕 eslint.config.js              # WordPress JS Standards
🆕 wp.code-workspace             # VSCode Workspace
🆕 .vscode/settings.json         # Configuración VSCode
🆕 .vscode/extensions.json       # Extensiones recomendadas
🆕 .husky/pre-commit             # Git hook pre-commit
🆕 backup-YYYYMMDD-HHMMSS/       # Directorio de backups
```

#### ✅ Archivos Modificados (Actualizados)

```text
✅ package.json                  # Scripts y dependencias añadidas
✅ composer.json                 # Herramientas PHP añadidas
✅ wordpress/wp-content/plugins/mi-plugin-custom/init.php           # Formateado
✅ wordpress/wp-content/plugins/mi-plugin-custom/includes/*.php     # Formateado
✅ wordpress/wp-content/plugins/mi-plugin-custom/assets/js/*.js     # Formateado
✅ wordpress/wp-content/plugins/ecommerce-integration/main.php      # Formateado
✅ wordpress/wp-content/plugins/ecommerce-integration/assets/js/*.js # Formateado
✅ wordpress/wp-content/themes/mi-tema-principal/functions.php      # Formateado
✅ wordpress/wp-content/themes/mi-tema-principal/assets/js/*.js     # Formateado
```

#### 🔒 Archivos Preservados (Sin cambios)

```text
🔒 README.md                     # Documentación existente
🔒 wordpress/                    # WordPress core intacto
🔒 wordpress/wp-content/uploads/ # Contenido de usuario
🔒 .env                          # Variables de entorno
🔒 .git/                         # Historial de Git
🔒 node_modules/                 # Dependencias (se reinstalan)
🔒 vendor/                       # Dependencias PHP (se reinstalan)
```

### Comparación de Rendimiento

#### ⚡ Antes: Linting Manual

```bash
# Sin configuración - proceso manual lento
find . -name "*.php" -exec php -l {} \;     # ❌ Sintaxis básica solamente
# No hay estándares de código                # ❌ Sin validación de calidad
# No hay formateo automático                 # ❌ Inconsistencias de estilo
# No hay integración con editor              # ❌ Sin feedback en tiempo real
```

#### 🚀 Después: Linting Optimizado

```bash
# Con configuración - proceso automático rápido
make lint                                    # ✅ Verifica solo componentes seleccionados
# Tiempo: ~15 segundos (vs ~2 minutos antes) # ✅ 8x más rápido
# Cobertura: 100% de estándares WordPress    # ✅ Calidad garantizada
# Integración: VSCode + Git hooks            # ✅ Feedback inmediato
# Formateo: Automático en pre-commit         # ✅ Consistencia garantizada
```

#### 📊 Métricas de Mejora

| Aspecto | Antes | Después | Mejora |
|---------|-------|---------|--------|
| **Tiempo de linting** | ~2 min | ~15 seg | 8x más rápido |
| **Cobertura de estándares** | 0% | 100% | Completa |
| **Automatización** | Manual | Automática | 100% |
| **Feedback en editor** | No | Sí | Tiempo real |
| **Consistencia de código** | Variable | Garantizada | 100% |
| **Detección de errores** | Básica | Avanzada | PHPStan Level 5 |
| **Configuración por proyecto** | No | Sí | Personalizada |

Esta transformación convierte un proyecto WordPress básico en una configuración de desarrollo profesional, con herramientas modernas, estándares de código y flujos de trabajo optimizados.

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

## 💡 Casos de Uso Detallados

Esta sección proporciona ejemplos completos y detallados de cómo usar el script en diferentes situaciones reales, con comandos específicos y resultados esperados.

### Caso 1: Nuevo Proyecto WordPress desde Cero

**Situación**: Acabas de clonar la plantilla para iniciar un proyecto completamente nuevo para un cliente. Necesitas configurar todo desde cero con estándares profesionales.

**Contexto**: Proyecto de ecommerce para una tienda online que necesita plugin personalizado y tema hijo.

**Pasos detallados**:

```bash
# 1. Clonar la plantilla con el nombre del proyecto
git clone https://github.com/tu-usuario/wp-init.git tienda-online-cliente
cd tienda-online-cliente

# 2. Verificar que la estructura WordPress está presente
ls -la wordpress/wp-content/
# Salida esperada:
# drwxr-xr-x  plugins/
# drwxr-xr-x  themes/
# drwxr-xr-x  mu-plugins/

# 3. Ejecutar el script de inicialización
./init-project.sh

# Interacción esperada:
# ╔══════════════════════════════════════════════════════════════╗
# ║  🚀 WordPress Standards & Formatting                         ║
# ╚══════════════════════════════════════════════════════════════╝
# 
# ✅ Requisitos verificados
# 
# ══════════════════════════════════════════════════════════════
#   Modo de Operación
# ══════════════════════════════════════════════════════════════
#   1️⃣  Configurar y formatear proyecto
#   2️⃣  Solo configurar (sin formatear)
#   3️⃣  Solo formatear código existente
# 
# Selecciona modo (1-3): 1

# 4. El script detecta componentes automáticamente
# ✅ Plugins detectados:
#   📦 tienda-online-ecommerce
#   📦 tienda-online-custom-blocks
# 
# ✅ Temas detectados:
#   🎨 tienda-online-theme
#   🎨 flat101-starter-theme
# 
# --- Plugins ---
# ¿Incluir 'tienda-online-ecommerce'? (y/n): y
# ¿Incluir 'tienda-online-custom-blocks'? (y/n): y
# 
# --- Temas ---
# ¿Incluir 'tienda-online-theme'? (y/n): y
# ¿Incluir 'flat101-starter-theme'? (y/n): n

# 5. Configuración del nombre del proyecto
# ℹ️  Detectado desde composer.json: tienda-online-cliente
# ¿Usar este nombre? (y/n): y

# 6. El script genera todos los archivos de configuración
# ✅ Generated .gitignore from .gitignore.template template
# ✅ Generated bitbucket-pipelines.yml from bitbucket-pipelines.yml template
# ✅ phpcs.xml.dist generado
# ✅ eslint.config.js generado
# ✅ package.json generado
# ✅ composer.json generado
# ✅ Generated wp.code-workspace with 2 plugins, 1 themes, 0 mu-plugins

# 7. Formateo automático del código existente
# ✅ PHP formateado (algunos archivos corregidos)
# ✅ Formateo completado

# 8. Instalar dependencias
npm install
composer install

# 9. Verificar que todo funciona correctamente
make lint
# Salida esperada:
# ✅ PHP Standards: No violations found
# ✅ JavaScript Standards: No problems found
# ✅ CSS Standards: No violations found

# 10. Iniciar desarrollo
make dev
# Inicia webpack dev server con hot reload
```

**Resultado esperado**:
- Proyecto completamente configurado con estándares WordPress
- Código existente formateado según las reglas
- Workspace de VSCode configurado con componentes seleccionados
- Herramientas de desarrollo listas para usar
- Pipeline de CI/CD configurado

**Verificación del éxito**:
```bash
# Verificar archivos generados
ls -la | grep -E "\.(xml|js|json|yml)$"
# Debe mostrar: phpcs.xml.dist, eslint.config.js, package.json, composer.json, etc.

# Verificar workspace
cat wp.code-workspace
# Debe incluir rutas a los componentes seleccionados

# Verificar que el linting funciona
make quick
# Debe pasar todas las verificaciones
```

### Caso 2: Integrar Estándares en Proyecto Existente

**Situación**: Tienes un proyecto WordPress funcionando en producción que fue desarrollado sin estándares de código. Necesitas añadir herramientas de linting y formateo sin romper la funcionalidad existente.

**Contexto**: Proyecto de 2 años con código personalizado que necesita mantenimiento y nuevos desarrolladores.

**Pasos detallados**:

```bash
# 1. Hacer backup completo del proyecto existente
cd /ruta/a/tu/proyecto-wordpress-existente
cp -r . ../backup-proyecto-$(date +%Y%m%d)

# 2. Clonar la plantilla en ubicación temporal
git clone https://github.com/tu-usuario/wp-init.git ~/temp/wp-standards-template

# 3. Ejecutar el script desde la plantilla apuntando a tu proyecto
cd ~/temp/wp-standards-template
./init-project.sh

# Cuando pregunte por la estructura, proporcionar la ruta
# ℹ️  Estructura detectada: /ruta/a/tu/proyecto-wordpress-existente/wp-content

# 4. Seleccionar Modo 4 para fusión segura
# Selecciona modo (1-4): 4
# ℹ️  Modo: Fusionar configuración (requiere jq)

# 5. El script detecta componentes existentes
# ✅ Plugins detectados:
#   📦 mi-plugin-personalizado
#   📦 woocommerce-customizations
# 
# ✅ Temas detectados:
#   🎨 mi-tema-hijo
# 
# ¿Incluir 'mi-plugin-personalizado'? (y/n): y
# ¿Incluir 'woocommerce-customizations'? (y/n): y
# ¿Incluir 'mi-tema-hijo'? (y/n): y

# 6. Fusión inteligente de archivos de configuración
# ℹ️  Backup creado: /ruta/a/tu/proyecto/backup-20241027-143022
# ℹ️  Fusionando package.json...
# ✅ package.json fusionado (preservadas 15 dependencias existentes)
# ℹ️  Fusionando composer.json...
# ✅ composer.json fusionado (preservados 8 paquetes existentes)

# 7. Navegar de vuelta a tu proyecto
cd /ruta/a/tu/proyecto-wordpress-existente

# 8. Instalar las nuevas dependencias de linting
npm install
composer install

# 9. Verificar que no se rompió nada
# Revisar que tus dependencias originales siguen ahí
npm list --depth=0
composer show

# 10. Ejecutar linting por primera vez (probablemente con errores)
make lint
# Salida esperada (primera vez):
# ❌ PHP Standards: 45 violations found
# ❌ JavaScript Standards: 23 problems found
# ℹ️  Usa 'make format' para corregir automáticamente

# 11. Formatear código gradualmente (opcional)
# Formatear solo un componente primero para probar
./vendor/bin/phpcbf --standard=phpcs.xml.dist wp-content/plugins/mi-plugin-personalizado/

# 12. Si el formateo es seguro, formatear todo
make format
```

**Resultado esperado**:
- Herramientas de linting integradas sin perder configuración previa
- Dependencias existentes preservadas
- Código funcional intacto
- Capacidad de formatear gradualmente

**Verificación del éxito**:
```bash
# Verificar que las dependencias originales siguen
npm list | grep "tu-dependencia-importante"
composer show | grep "tu-paquete-importante"

# Verificar que el sitio sigue funcionando
# (probar en entorno de desarrollo)

# Verificar configuración de linting
./vendor/bin/phpcs --config-show
npx eslint --print-config wp-content/themes/mi-tema-hijo/assets/js/main.js
```

### Caso 3: Adaptar Proyecto para Nuevo Cliente

**Situación**: Tienes un proyecto base que has usado para varios clientes y necesitas adaptarlo rápidamente para un nuevo cliente, cambiando nombres, prefixes y configuraciones específicas.

**Contexto**: Proyecto base de restaurante que necesitas adaptar para una cafetería con diferentes componentes y branding.

**Pasos detallados**:

```bash
# 1. Copiar proyecto base existente
cp -r proyecto-base-restaurante proyecto-cafeteria-nueva
cd proyecto-cafeteria-nueva

# 2. Ejecutar reconfiguración para cambiar referencias
./init-project.sh

# 3. Seleccionar Modo 2 para solo reconfigurar
# Selecciona modo (1-3): 2
# ℹ️  Modo: Solo configurar

# 4. El script detecta la estructura y componentes actuales
# ✅ Plugins detectados:
#   📦 restaurante-reservas
#   📦 restaurante-menu
#   📦 restaurante-eventos
# 
# ✅ Temas detectados:
#   🎨 restaurante-theme
# 
# 5. Seleccionar solo los componentes relevantes para cafetería
# ¿Incluir 'restaurante-reservas'? (y/n): y  # Útil para cafetería también
# ¿Incluir 'restaurante-menu'? (y/n): y     # Necesario para carta
# ¿Incluir 'restaurante-eventos'? (y/n): n  # No necesario para cafetería
# ¿Incluir 'restaurante-theme'? (y/n): y

# 6. Cambiar el nombre del proyecto
# ℹ️  Detectado desde composer.json: proyecto-base-restaurante
# ¿Usar este nombre? (y/n): n
# Nombre del proyecto (slug): cafeteria-nueva

# 7. El script actualiza todas las referencias automáticamente
# ✅ Actualizando prefixes en phpcs.xml.dist
#     - restaurante_ → cafeteria_nueva_
#     - RESTAURANTE_ → CAFETERIA_NUEVA_
#     - Restaurante\ → CafeteriaNueva\
# 
# ✅ Actualizando text domains
#     - restaurante-reservas → cafeteria-nueva-reservas
#     - restaurante-menu → cafeteria-nueva-menu
#     - restaurante-theme → cafeteria-nueva-theme
# 
# ✅ Actualizando URLs en lighthouserc.js
#     - local.restaurante.com → local.cafeteria-nueva.com
#     - dev.restaurante.levelstage.com → dev.cafeteria-nueva.levelstage.com

# 8. Verificar los cambios realizados
git diff --name-only
# Salida esperada:
# phpcs.xml.dist
# eslint.config.js
# package.json
# composer.json
# lighthouserc.js
# wp.code-workspace

# 9. Revisar cambios específicos en archivos clave
git diff phpcs.xml.dist
# Debe mostrar cambios en prefixes y text domains

# 10. Instalar dependencias (si es necesario)
npm install
composer install

# 11. Verificar que la configuración es correcta
make lint
# Debe pasar sin errores si el código ya estaba bien formateado
```

**Resultado esperado**:
- Todas las referencias del proyecto anterior cambiadas al nuevo nombre
- Prefixes y namespaces actualizados automáticamente
- Text domains de i18n actualizados
- URLs de desarrollo actualizadas
- Configuración lista para el nuevo cliente

**Verificación del éxito**:
```bash
# Verificar cambios en prefixes
grep -r "cafeteria_nueva_" phpcs.xml.dist
grep -r "CAFETERIA_NUEVA_" phpcs.xml.dist

# Verificar text domains
grep -r "cafeteria-nueva" phpcs.xml.dist eslint.config.js

# Verificar URLs
grep -r "cafeteria-nueva" lighthouserc.js

# Verificar workspace
grep -r "cafeteria" wp.code-workspace
```

### Caso 4: Solo Actualizar Reglas de Linting

**Situación**: Tu proyecto ya está configurado y funcionando, pero quieres actualizar a las últimas reglas de linting sin cambiar dependencias ni configuración existente.

**Contexto**: Proyecto en desarrollo activo donde solo necesitas aplicar formateo con las reglas más recientes.

**Pasos detallados**:

```bash
# 1. Desde tu proyecto ya configurado
cd /ruta/a/tu/proyecto-configurado

# 2. Verificar estado actual del linting
make lint
# Salida actual:
# ❌ PHP Standards: 12 violations found
# ❌ JavaScript Standards: 5 problems found
# ℹ️  Algunos archivos necesitan formateo

# 3. Ejecutar script solo para formateo
~/plantillas/wp-init/init-project.sh

# 4. Seleccionar Modo 3 para solo formatear
# Selecciona modo (1-3): 3
# ℹ️  Modo: Solo formatear código existente

# 5. El script usa la configuración existente
# ℹ️  Usando configuración existente: phpcs.xml.dist
# ℹ️  Usando configuración existente: eslint.config.js

# 6. Detecta automáticamente todos los componentes
# ✅ Detectados automáticamente:
#   📦 mi-plugin (desde phpcs.xml.dist)
#   🎨 mi-tema (desde phpcs.xml.dist)
# 
# ℹ️  Usando componentes configurados previamente
# ℹ️  Para cambiar selección, usa Modo 2

# 7. Aplica formateo solo a código
# ℹ️  Formateando código PHP con PHPCBF...
# 
# FILE                                                  FIXED  REMAINING
# wp-content/plugins/mi-plugin/includes/class-admin.php     8        0
# wp-content/plugins/mi-plugin/includes/functions.php       4        0
# wp-content/themes/mi-tema/functions.php                   3        0
# wp-content/themes/mi-tema/inc/customizer.php             2        0
# 
# ✅ PHP formateado (17 problemas corregidos)
# 
# ℹ️  Formateando código JavaScript con ESLint...
# 
# wp-content/plugins/mi-plugin/assets/js/admin.js
#   ✓ 3 problems fixed
# wp-content/themes/mi-tema/assets/js/theme.js
#   ✓ 2 problems fixed
# 
# ✅ JavaScript formateado (5 problemas corregidos)

# 8. Verificar que el formateo fue exitoso
make lint
# Salida esperada:
# ✅ PHP Standards: No violations found
# ✅ JavaScript Standards: No problems found
# ✅ CSS Standards: No violations found

# 9. Revisar los cambios realizados
git diff --stat
# Salida esperada:
# wp-content/plugins/mi-plugin/includes/class-admin.php | 15 ++++++++-------
# wp-content/plugins/mi-plugin/includes/functions.php  |  8 ++++----
# wp-content/themes/mi-tema/functions.php              |  6 +++---
# wp-content/themes/mi-tema/inc/customizer.php        |  4 ++--
# wp-content/plugins/mi-plugin/assets/js/admin.js     |  6 +++---
# wp-content/themes/mi-tema/assets/js/theme.js        |  4 ++--

# 10. Commit los cambios de formateo
git add .
git commit -m "style: aplicar formateo automático con estándares WordPress"
```

**Resultado esperado**:
- Código formateado según las reglas configuradas
- Sin cambios en archivos de configuración
- Sin cambios en dependencias
- Linting limpio después del formateo

**Verificación del éxito**:
```bash
# Verificar que no se modificaron archivos de configuración
git diff --name-only | grep -v -E "\.(php|js|css|scss)$"
# No debe mostrar archivos de configuración

# Verificar que el linting pasa
make quick
# Debe pasar todas las verificaciones

# Verificar que solo se formateó código
git show --stat
# Debe mostrar solo archivos de código, no configuración
```

### Caso 5: Proyecto Multi-componente Complejo

**Situación**: Proyecto grande con múltiples plugins personalizados, varios temas y mu-plugins que necesita configuración selectiva y optimizada.

**Contexto**: Plataforma de elearning con plugin de cursos, plugin de pagos, tema principal, tema de administración y varios mu-plugins.

**Pasos detallados**:

```bash
# 1. Navegar al proyecto complejo existente
cd /ruta/a/plataforma-elearning

# 2. Verificar la estructura compleja
find wp-content -maxdepth 2 -type d
# Salida esperada:
# wp-content/plugins/elearning-courses
# wp-content/plugins/elearning-payments
# wp-content/plugins/elearning-certificates
# wp-content/plugins/elearning-analytics
# wp-content/themes/elearning-main-theme
# wp-content/themes/elearning-admin-theme
# wp-content/mu-plugins/elearning-core
# wp-content/mu-plugins/elearning-security

# 3. Ejecutar configuración selectiva
./init-project.sh

# 4. Seleccionar Modo 1 para configuración completa
# Selecciona modo (1-3): 1

# 5. Selección cuidadosa de componentes
# ✅ Plugins detectados:
#   📦 elearning-courses
#   📦 elearning-payments
#   📦 elearning-certificates
#   📦 elearning-analytics
# 
# ✅ Temas detectados:
#   🎨 elearning-main-theme
#   🎨 elearning-admin-theme
# 
# ✅ MU-Plugins detectados:
#   🔧 elearning-core
#   🔧 elearning-security

# Seleccionar solo componentes activos en desarrollo
# ¿Incluir 'elearning-courses'? (y/n): y      # Componente principal
# ¿Incluir 'elearning-payments'? (y/n): y     # En desarrollo activo
# ¿Incluir 'elearning-certificates'? (y/n): n # Estable, no necesita linting
# ¿Incluir 'elearning-analytics'? (y/n): y    # Nuevas funcionalidades
# ¿Incluir 'elearning-main-theme'? (y/n): y   # Tema principal
# ¿Incluir 'elearning-admin-theme'? (y/n): n  # Tema estable
# ¿Incluir 'elearning-core'? (y/n): y         # MU-plugin crítico
# ¿Incluir 'elearning-security'? (y/n): n     # MU-plugin estable

# 6. Configuración optimizada generada
# ✅ Generated wp.code-workspace with 3 plugins, 1 themes, 1 mu-plugins
# 
# ℹ️  Generando phpcs.xml.dist optimizado...
# ✅ Configurado para 5 componentes seleccionados
# 
# ℹ️  Generando eslint.config.js con rutas específicas...
# ✅ Configurado targeting para JavaScript de componentes activos

# 7. Verificar configuración generada
cat phpcs.xml.dist | grep -A 10 "Files to check"
# Salida esperada:
# <!-- Files to check -->
# <file>wp-content/plugins/elearning-courses</file>
# <file>wp-content/plugins/elearning-payments</file>
# <file>wp-content/plugins/elearning-analytics</file>
# <file>wp-content/themes/elearning-main-theme</file>
# <file>wp-content/mu-plugins/elearning-core</file>

# 8. Verificar workspace generado
cat wp.code-workspace | jq '.folders[].path'
# Salida esperada:
# "."
# "wp-content/plugins/elearning-courses"
# "wp-content/plugins/elearning-payments"
# "wp-content/plugins/elearning-analytics"
# "wp-content/themes/elearning-main-theme"
# "wp-content/mu-plugins/elearning-core"

# 9. Instalar dependencias y verificar
npm install
composer install
make lint

# 10. Verificar que solo se procesan componentes seleccionados
make lint | grep "Checking"
# Debe mostrar solo los 5 componentes seleccionados
```

**Resultado esperado**:
- Configuración optimizada solo para componentes en desarrollo activo
- Workspace de VSCode enfocado en componentes relevantes
- Linting rápido al procesar solo código necesario
- Configuración escalable para proyectos grandes

**Verificación del éxito**:
```bash
# Verificar que solo se incluyen componentes seleccionados
grep -c "<file>" phpcs.xml.dist
# Debe mostrar: 5

# Verificar workspace optimizado
jq '.folders | length' wp.code-workspace
# Debe mostrar: 6 (raíz + 5 componentes)

# Verificar tiempo de linting optimizado
time make lint
# Debe ser significativamente más rápido que procesar todos los componentes
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

<div align="center">

### ⚡ **Comandos Dinámicos Generados Automáticamente**

*El script genera comandos optimizados basados en los componentes que selecciones*

</div>

<table>
<tr>
<td align="center" width="25%">

### 🔨 **Make**
Comandos principales

</td>
<td align="center" width="25%">

### 📦 **NPM**
Scripts JavaScript

</td>
<td align="center" width="25%">

### 🐘 **Composer**
Scripts PHP

</td>
<td align="center" width="25%">

### 🧩 **Componentes**
Comandos específicos

</td>
</tr>
</table>

---

### 🔨 Comandos Make (Generados Dinámicamente)

<div align="center">

**🎯 El `Makefile` se adapta automáticamente a los componentes que selecciones**

</div>

```bash
# === COMANDOS PRINCIPALES ===

# Instalación y configuración
make install          # Instala todas las dependencias (npm + composer)
make help            # Muestra todos los comandos disponibles

# Desarrollo
make dev             # Inicia desarrollo paralelo (todos los componentes)
make dev-blocks      # Solo desarrollo de bloques Gutenberg
make dev-theme       # Solo desarrollo del tema principal

# Linting y formateo
make lint            # Verifica estándares completos (PHP, JS, CSS)
make format          # Formatea todo el código según estándares WordPress
make fix             # Alias de format
make quick           # Verificación rápida antes de commit

# Build y producción
make build           # Build de producción optimizado y minificado

# Utilidades
make clean           # Limpia caches y archivos temporales
make status          # Muestra estado actual del proyecto
make health          # Verifica salud del proyecto (dependencias, configs)

# === COMANDOS ESPECÍFICOS POR COMPONENTE ===
# (Generados automáticamente según componentes seleccionados)

# Plugins detectados
make dev-mi-plugin-custom              # Desarrollo para plugin específico
make build-mi-plugin-custom            # Build para plugin específico
make dev-ecommerce-integration         # Desarrollo para plugin ecommerce
make build-ecommerce-integration       # Build para plugin ecommerce

# Temas detectados  
make dev-mi-tema-principal             # Desarrollo para tema específico
make build-mi-tema-principal           # Build para tema específico
make dev-flat101-starter-theme         # Desarrollo para starter theme
make build-flat101-starter-theme       # Build para starter theme

# Comandos combinados
make dev-all         # Inicia desarrollo para todos los componentes
make build-all       # Build de todos los componentes

# === HERRAMIENTAS DE ANÁLISIS ===

# Lighthouse y performance
make lighthouse-local     # Análisis Lighthouse en local
make lighthouse-preprod   # Análisis Lighthouse en preprod
make performance-check    # Análisis completo de rendimiento

# Base de datos (requiere configuración adicional)
make db-backup           # Backup de base de datos
make db-pull            # Pull desde staging
make db-push            # Push a staging

# Debugging
make debug-theme        # Debug de problemas del tema
make debug-blocks       # Debug de registro de bloques
make debug-assets       # Debug de carga de assets
make debug-performance  # Debug de rendimiento

# Testing
make test-unit          # Tests unitarios
make test-e2e           # Tests end-to-end
make test-a11y          # Tests de accesibilidad
make test-security      # Auditoría de seguridad
make test-complete      # Suite completa de tests

# Ver todos los comandos disponibles
make help
```

### Scripts NPM (Generados por el Script)

#### Comandos Básicos (Siempre Generados)

```bash
# === LINTING BÁSICO ===
npm run lint:js         # Lint JavaScript/TypeScript
npm run lint:js:fix     # Fix automático JavaScript
npm run lint:php        # Lint PHP con WordPress Coding Standards
npm run lint:php:fix    # Fix automático PHP (PHPCBF)
npm run lint            # Lint completo (JS + PHP)
npm run format          # Formateo completo (JS + PHP)
```

#### Comandos Avanzados (Proyecto Completo)

Si tu proyecto ya tiene una configuración avanzada, también tendrás:

```bash
# === LINTING AVANZADO ===
npm run lint:css        # Lint CSS/SCSS con Stylelint
npm run lint:css:fix    # Fix automático CSS

# === ANÁLISIS ===
npm run analyze:php     # PHPStan análisis estático
npm run analyze:security # Auditoría de seguridad
npm run analyze:bundle-size # Análisis de tamaño de bundles

# === BUILD Y DESARROLLO ===
npm run build:all       # Build completo de todos los componentes
npm run build:blocks    # Build solo de bloques Gutenberg
npm run build:themes    # Build solo de temas
npm run dev:all         # Desarrollo paralelo de todos los componentes
npm run dev:blocks      # Desarrollo solo de bloques
npm run dev:theme       # Desarrollo solo del tema principal

# === VERIFICACIÓN ===
npm run verify:standards    # Verificación completa de estándares
npm run quick-check        # Verificación rápida
npm run commit-ready       # Verificación antes de commit

# === MANTENIMIENTO ===
npm run cache:clear        # Limpia todas las caches
npm run clean:all          # Limpieza completa
npm run health:check       # Verificación de salud del proyecto
```

### Comandos Composer (Generados por el Script)

#### Comandos Básicos (Siempre Generados)

```bash
# === LINTING PHP ===
composer run lint          # Verifica estándares PHP (alias de lint:php)
composer run lint:fix      # Corrige estándares PHP (alias de lint:php:fix)
composer run analyze       # Análisis estático con PHPStan
```

#### Comandos Directos Equivalentes

```bash
# === PHPCS (WordPress Coding Standards) ===
./vendor/bin/phpcs --standard=phpcs.xml.dist           # Verificar estándares
./vendor/bin/phpcbf --standard=phpcs.xml.dist          # Corregir automáticamente

# === PHPStan (Análisis Estático) ===
./vendor/bin/phpstan analyse                           # Análisis estático completo
./vendor/bin/phpstan analyse --no-progress             # Sin barra de progreso

# === Comandos con rutas específicas ===
./vendor/bin/phpcs --standard=phpcs.xml.dist wp-content/plugins/mi-plugin/
./vendor/bin/phpcbf --standard=phpcs.xml.dist wp-content/themes/mi-tema/
```

### Comandos Directos por Herramienta

#### ESLint (JavaScript)

```bash
# === LINTING JAVASCRIPT ===
npx eslint '**/*.{js,jsx,ts,tsx}'                      # Verificar JavaScript
npx eslint --fix '**/*.{js,jsx,ts,tsx}'                # Corregir automáticamente
npx eslint 'wp-content/plugins/mi-plugin/**/*.js'      # Plugin específico
npx eslint 'wp-content/themes/mi-tema/**/*.js'         # Tema específico

# === CON CACHE PARA VELOCIDAD ===
npx eslint '**/*.{js,jsx,ts,tsx}' --cache              # Con cache
npx eslint --fix '**/*.{js,jsx,ts,tsx}' --cache        # Fix con cache
```

#### Stylelint (CSS/SCSS)

```bash
# === LINTING CSS ===
npx stylelint '**/*.{css,scss}'                        # Verificar CSS/SCSS
npx stylelint --fix '**/*.{css,scss}'                  # Corregir automáticamente
npx stylelint 'wp-content/themes/mi-tema/**/*.scss'    # Tema específico
```

#### Prettier (Formateo General)

```bash
# === FORMATEO GENERAL ===
npx prettier --write '**/*.{js,jsx,ts,tsx,css,scss}'   # Formatear assets
npx prettier --check '**/*.{js,jsx,ts,tsx,css,scss}'   # Verificar formato
```

### Comandos Específicos por Componente

El script genera comandos específicos basados en los componentes que selecciones:

#### Ejemplo: Plugin "mi-plugin-custom"

```bash
# Make commands (generados automáticamente)
make dev-mi-plugin-custom              # cd wp-content/plugins/mi-plugin-custom && npm run dev
make build-mi-plugin-custom            # cd wp-content/plugins/mi-plugin-custom && npm run build

# NPM commands (si el plugin tiene package.json)
cd wp-content/plugins/mi-plugin-custom
npm run dev                           # Desarrollo con hot reload
npm run build                         # Build de producción
npm run lint                          # Linting específico del plugin
```

#### Ejemplo: Tema "mi-tema-principal"

```bash
# Make commands (generados automáticamente)
make dev-mi-tema-principal            # cd wp-content/themes/mi-tema-principal && npm run dev
make build-mi-tema-principal          # cd wp-content/themes/mi-tema-principal && npm run build

# NPM commands (si el tema tiene package.json)
cd wp-content/themes/mi-tema-principal
npm run dev                          # Desarrollo con hot reload
npm run build                        # Build de producción
npm run lint                         # Linting específico del tema
```

### Verificación de Comandos Disponibles

Para ver qué comandos están disponibles en tu proyecto específico:

```bash
# Ver comandos Make generados
make help

# Ver scripts NPM disponibles
npm run

# Ver scripts Composer disponibles
composer run-script --list

# Verificar herramientas instaladas
which phpcs phpcbf phpstan eslint stylelint prettier
```

## 🔄 Flujo de Desarrollo y Build

### Flujo de Trabajo Típico

#### 1. Configuración Inicial

```bash
# Después de ejecutar el script de inicialización
npm install                    # Instalar dependencias JavaScript
composer install              # Instalar dependencias PHP

# Verificar que todo funciona
make lint                     # Debe pasar sin errores
make status                   # Verificar estado del proyecto
```

#### 2. Desarrollo Diario

```bash
# Iniciar desarrollo con hot reload
make dev                      # Todos los componentes
# o específico:
make dev-mi-plugin-custom     # Solo un plugin
make dev-mi-tema-principal    # Solo un tema

# En otra terminal, verificar código mientras desarrollas
make quick                    # Verificación rápida
make lint                     # Verificación completa
```

#### 3. Antes de Commit

```bash
# Formatear y verificar todo
make format                   # Formateo automático
make lint                     # Verificación completa
make quick                    # Verificación final

# O usar el comando integrado
make commit-ready             # Todo en uno
```

#### 4. Build de Producción

```bash
# Build completo optimizado
make build                    # Todos los componentes

# O builds específicos
make build-mi-plugin-custom   # Solo un plugin
make build-mi-tema-principal  # Solo un tema
```

### Comandos por Fase de Desarrollo

#### Fase de Configuración

```bash
# Verificar configuración inicial
make status                   # Estado del proyecto
make health                   # Salud de dependencias
npm run health:check          # Verificación completa (si disponible)

# Instalar dependencias faltantes
make install                  # Todo automático
npm install                   # Solo JavaScript
composer install              # Solo PHP
```

#### Fase de Desarrollo Activo

```bash
# Desarrollo con hot reload
make dev                      # Paralelo para todos los componentes
make dev-all                  # Alias de dev

# Desarrollo específico por componente
make dev-blocks               # Solo bloques Gutenberg
make dev-theme                # Solo tema principal
make dev-[nombre-componente]  # Componente específico

# Verificación durante desarrollo
make quick                    # Verificación rápida (JS + CSS)
npm run quick-check           # Equivalente NPM
```

#### Fase de Testing y QA

```bash
# Linting completo
make lint                     # PHP + JavaScript + CSS
npm run test:standards        # Equivalente NPM

# Análisis estático
npm run analyze:php           # PHPStan (si disponible)
composer run analyze          # Equivalente Composer

# Tests (si configurados)
make test-unit                # Tests unitarios
make test-e2e                 # Tests end-to-end
make test-a11y                # Tests de accesibilidad
make test-security            # Auditoría de seguridad
```

#### Fase de Build y Deploy

```bash
# Build de producción
make build                    # Build completo optimizado
npm run build:production      # Equivalente NPM (si disponible)

# Verificación pre-deploy
make commit-ready             # Verificación completa
npm run pre-commit:full       # Equivalente NPM (si disponible)

# Análisis de rendimiento
make performance-check        # Análisis completo (si disponible)
make lighthouse-local         # Lighthouse local
npm run analyze:bundle-size   # Tamaño de bundles (si disponible)
```

### Comandos de Mantenimiento

#### Limpieza y Cache

```bash
# Limpiar caches
make clean                    # Limpieza completa
make clear-cache              # Solo caches
npm run cache:clear           # Caches de linting (si disponible)

# Limpieza específica
npm run cache:clear:eslint    # Cache de ESLint (si disponible)
npm run cache:clear:stylelint # Cache de Stylelint (si disponible)
```

#### Actualización de Dependencias

```bash
# Verificar dependencias obsoletas
make check-deps               # Verificación completa (si disponible)
npm run health:check:outdated # NPM específico (si disponible)

# Actualizar dependencias (con precaución)
make update                   # Actualización completa (si disponible)
npm update                    # Solo JavaScript
composer update               # Solo PHP
```

#### Debugging y Diagnóstico

```bash
# Debug de componentes
make debug-theme              # Problemas del tema
make debug-blocks             # Problemas de bloques
make debug-assets             # Problemas de assets
make debug-performance        # Problemas de rendimiento

# Verificación de configuración
make status                   # Estado general
cat phpcs.xml.dist            # Configuración PHP
cat eslint.config.js          # Configuración JavaScript
cat wp.code-workspace         # Configuración VSCode
```

### Integración con Editor (VSCode)

#### Comandos desde VSCode

```bash
# Abrir workspace generado
code wp.code-workspace

# Comandos integrados (disponibles en Command Palette)
# - PHP Sniffer: Fix this file
# - ESLint: Fix all auto-fixable Problems
# - Format Document (Prettier)
# - Format Document With... (seleccionar formateador)
```

#### Configuración Automática

El script configura automáticamente:

- **Formateo al guardar**: PHP, JavaScript, CSS
- **Linting en tiempo real**: Errores visibles mientras escribes
- **Snippets de WordPress**: Autocompletado específico
- **Rutas de componentes**: Navegación rápida entre plugins/temas

### Comandos de CI/CD

#### Para Pipelines Automatizados

```bash
# Verificación en CI
npm run ci:test               # Tests para CI (si disponible)
make test-complete            # Suite completa de tests

# Build para CI
npm run ci:setup              # Configuración CI (si disponible)
npm run build:production      # Build optimizado
make build                    # Equivalente Make

# Deploy (requiere configuración adicional)
make deploy-staging           # Deploy a staging (si configurado)
make deploy-prod              # Deploy a producción (si configurado)
```

El archivo `bitbucket-pipelines.yml` generado incluye automáticamente los comandos de build específicos para tus componentes seleccionados.

## 🧩 Comandos Específicos por Componente

El script genera comandos dinámicos basados en los componentes que selecciones durante la configuración. Estos comandos se adaptan automáticamente a la estructura de tu proyecto.

### Comandos Generados Automáticamente

#### Para Plugins Personalizados

Cuando seleccionas plugins durante la configuración, el script genera:

```bash
# Ejemplo: Plugin "ecommerce-integration"
make dev-ecommerce-integration     # Desarrollo con hot reload
make build-ecommerce-integration   # Build de producción

# Comando real generado:
# @cd wordpress/wp-content/plugins/ecommerce-integration && npm run dev
# @cd wordpress/wp-content/plugins/ecommerce-integration && npm run build
```

#### Para Temas Personalizados

```bash
# Ejemplo: Tema "mi-tema-principal"
make dev-mi-tema-principal         # Desarrollo con hot reload
make build-mi-tema-principal       # Build de producción

# Comando real generado:
# @cd wordpress/wp-content/themes/mi-tema-principal && npm run dev
# @cd wordpress/wp-content/themes/mi-tema-principal && npm run build
```

#### Para MU-Plugins

```bash
# Ejemplo: MU-Plugin "core-functionality"
make dev-core-functionality        # Desarrollo (si tiene assets)
make build-core-functionality      # Build (si tiene assets)
```

### Ejemplos de Configuraciones Reales

#### Proyecto E-commerce Completo

Si seleccionas estos componentes:
- Plugin: `tienda-online-ecommerce`
- Plugin: `tienda-online-payments`
- Tema: `tienda-online-theme`

El Makefile generará:

```makefile
# Plugin targets
dev-tienda-online-ecommerce: ## 🧩 Development for tienda-online-ecommerce plugin
    @cd wordpress/wp-content/plugins/tienda-online-ecommerce && npm run dev

build-tienda-online-ecommerce: ## 📦 Build tienda-online-ecommerce plugin assets
    @cd wordpress/wp-content/plugins/tienda-online-ecommerce && npm run build

dev-tienda-online-payments: ## 🧩 Development for tienda-online-payments plugin
    @cd wordpress/wp-content/plugins/tienda-online-payments && npm run dev

build-tienda-online-payments: ## 📦 Build tienda-online-payments plugin assets
    @cd wordpress/wp-content/plugins/tienda-online-payments && npm run build

# Theme targets
dev-tienda-online-theme: ## 🎨 Development for tienda-online-theme theme
    @cd wordpress/wp-content/themes/tienda-online-theme && npm run dev

build-tienda-online-theme: ## 📦 Build tienda-online-theme theme assets
    @cd wordpress/wp-content/themes/tienda-online-theme && npm run build

# Combined targets
dev-all: dev-tienda-online-ecommerce dev-tienda-online-payments dev-tienda-online-theme ## 🚀 Start all development servers

build-all: build-tienda-online-ecommerce build-tienda-online-payments build-tienda-online-theme ## 📦 Build all component assets
```

#### Proyecto Blog/Corporativo

Si seleccionas estos componentes:
- Plugin: `blog-custom-blocks`
- Tema: `corporate-theme`
- MU-Plugin: `site-core`

El Makefile generará:

```makefile
# Plugin targets
dev-blog-custom-blocks: ## 🧩 Development for blog-custom-blocks plugin
    @cd wordpress/wp-content/plugins/blog-custom-blocks && npm run dev

# Theme targets
dev-corporate-theme: ## 🎨 Development for corporate-theme theme
    @cd wordpress/wp-content/themes/corporate-theme && npm run dev

# MU-Plugin targets (si tiene assets)
dev-site-core: ## 🔧 Development for site-core mu-plugin
    @cd wordpress/wp-content/mu-plugins/site-core && npm run dev

# Combined targets
dev-all: dev-blog-custom-blocks dev-corporate-theme dev-site-core ## 🚀 Start all development servers
```

### Comandos NPM Específicos por Componente

El script también genera comandos NPM específicos cuando tienes múltiples componentes:

#### package.json Generado (Ejemplo Multi-componente)

```json
{
  "scripts": {
    "// === LINTING POR COMPONENTE ===": "",
    "lint:js:plugin1": "cd wordpress/wp-content/plugins/mi-plugin && npx eslint 'src/**/*.{js,jsx,ts,tsx}' --cache",
    "lint:js:plugin2": "cd wordpress/wp-content/plugins/otro-plugin && npx eslint 'assets/**/*.{js,jsx,ts,tsx}' --cache",
    "lint:js:theme": "cd wordpress/wp-content/themes/mi-tema && npx eslint 'assets/src/**/*.{js,jsx,ts,tsx}' --cache",
    
    "// === DESARROLLO POR COMPONENTE ===": "",
    "dev:plugin1": "cd wordpress/wp-content/plugins/mi-plugin && npm run dev",
    "dev:plugin2": "cd wordpress/wp-content/plugins/otro-plugin && npm run dev", 
    "dev:theme": "cd wordpress/wp-content/themes/mi-tema && npm run dev",
    "dev:all": "npm-run-all --parallel dev:*",
    
    "// === BUILD POR COMPONENTE ===": "",
    "build:plugin1": "cd wordpress/wp-content/plugins/mi-plugin && npm run build",
    "build:plugin2": "cd wordpress/wp-content/plugins/otro-plugin && npm run build",
    "build:theme": "cd wordpress/wp-content/themes/mi-tema && npm run build",
    "build:all": "npm-run-all build:*"
  }
}
```

### Configuración de Linting por Componente

#### phpcs.xml.dist Generado

```xml
<?xml version="1.0"?>
<ruleset name="mi-proyecto">
    <!-- Archivos a verificar (solo componentes seleccionados) -->
    <file>wordpress/wp-content/plugins/mi-plugin-ecommerce</file>
    <file>wordpress/wp-content/plugins/mi-plugin-payments</file>
    <file>wordpress/wp-content/themes/mi-tema-principal</file>
    <file>wordpress/wp-content/mu-plugins/core-functionality</file>
    
    <!-- Prefixes específicos por componente -->
    <rule ref="WordPress.NamingConventions.PrefixAllGlobals">
        <properties>
            <property name="prefixes" type="array">
                <!-- Proyecto principal -->
                <element value="mi_proyecto_"/>
                <element value="MI_PROYECTO_"/>
                <!-- Plugin ecommerce -->
                <element value="mi_plugin_ecommerce_"/>
                <element value="MI_PLUGIN_ECOMMERCE_"/>
                <!-- Plugin payments -->
                <element value="mi_plugin_payments_"/>
                <element value="MI_PLUGIN_PAYMENTS_"/>
                <!-- Tema principal -->
                <element value="mi_tema_principal_"/>
                <element value="MI_TEMA_PRINCIPAL_"/>
            </property>
        </properties>
    </rule>
    
    <!-- Text domains por componente -->
    <rule ref="WordPress.WP.I18n">
        <properties>
            <property name="text_domain" type="array">
                <element value="mi-proyecto"/>
                <element value="mi-plugin-ecommerce"/>
                <element value="mi-plugin-payments"/>
                <element value="mi-tema-principal"/>
            </property>
        </properties>
    </rule>
</ruleset>
```

#### eslint.config.js Generado

```javascript
export default [
  {
    files: [
      // Solo componentes seleccionados
      'wordpress/wp-content/plugins/mi-plugin-ecommerce/**/*.{js,jsx,ts,tsx}',
      'wordpress/wp-content/plugins/mi-plugin-payments/**/*.{js,jsx,ts,tsx}',
      'wordpress/wp-content/themes/mi-tema-principal/**/*.{js,jsx,ts,tsx}',
      'wordpress/wp-content/mu-plugins/core-functionality/**/*.{js,jsx,ts,tsx}',
    ],
    // ... configuración WordPress
  }
];
```

### Workspace VSCode Generado

El archivo `wp.code-workspace` incluye solo los componentes seleccionados:

```json
{
  "folders": [
    {
      "name": "🏠 Proyecto Principal",
      "path": "."
    },
    {
      "name": "🧩 mi-plugin-ecommerce",
      "path": "wordpress/wp-content/plugins/mi-plugin-ecommerce"
    },
    {
      "name": "🧩 mi-plugin-payments", 
      "path": "wordpress/wp-content/plugins/mi-plugin-payments"
    },
    {
      "name": "🎨 mi-tema-principal",
      "path": "wordpress/wp-content/themes/mi-tema-principal"
    },
    {
      "name": "🔧 core-functionality",
      "path": "wordpress/wp-content/mu-plugins/core-functionality"
    }
  ],
  "settings": {
    "phpsab.snifferMode": "onType",
    "phpsab.standard": "./phpcs.xml.dist",
    "[php]": {
      "editor.formatOnSave": true,
      "editor.defaultFormatter": "valeryanm.vscode-phpsab"
    }
  }
}
```

### Comandos de Verificación por Componente

#### Verificar Componente Específico

```bash
# Verificar solo un plugin
./vendor/bin/phpcs --standard=phpcs.xml.dist wordpress/wp-content/plugins/mi-plugin/

# Verificar solo un tema
./vendor/bin/phpcs --standard=phpcs.xml.dist wordpress/wp-content/themes/mi-tema/

# Formatear solo un componente
./vendor/bin/phpcbf --standard=phpcs.xml.dist wordpress/wp-content/plugins/mi-plugin/

# ESLint para componente específico
npx eslint 'wordpress/wp-content/plugins/mi-plugin/**/*.{js,jsx,ts,tsx}' --fix
npx eslint 'wordpress/wp-content/themes/mi-tema/**/*.{js,jsx,ts,tsx}' --fix
```

#### Verificar por Tipo de Componente

```bash
# Solo plugins
./vendor/bin/phpcs --standard=phpcs.xml.dist wordpress/wp-content/plugins/

# Solo temas
./vendor/bin/phpcs --standard=phpcs.xml.dist wordpress/wp-content/themes/

# Solo mu-plugins
./vendor/bin/phpcs --standard=phpcs.xml.dist wordpress/wp-content/mu-plugins/
```

### Personalización de Comandos

#### Añadir Comandos Personalizados al Makefile

Puedes añadir tus propios comandos al Makefile generado:

```makefile
# Añadir al final del Makefile generado

# === COMANDOS PERSONALIZADOS ===

deploy-mi-plugin: ## 🚀 Deploy específico del plugin principal
    @echo "Deploying mi-plugin-ecommerce..."
    @cd wordpress/wp-content/plugins/mi-plugin-ecommerce
    @npm run build
    @rsync -av build/ user@server:/path/to/plugin/

test-mi-tema: ## 🧪 Tests específicos del tema
    @echo "Testing mi-tema-principal..."
    @cd wordpress/wp-content/themes/mi-tema-principal
    @npm run test:unit
    @npm run test:e2e

backup-components: ## 💾 Backup solo de componentes personalizados
	@mkdir -p backups/components
	@tar -czf backups/components/plugins-$(shell date +%Y%m%d).tar.gz wordpress/wp-content/plugins/mi-*
	@tar -czf backups/components/themes-$(shell date +%Y%m%d).tar.gz wordpress/wp-content/themes/mi-*
```

Esta configuración dinámica asegura que solo trabajas con los componentes que realmente necesitas, optimizando el rendimiento del linting y desarrollo.

## 📊 Diferencias entre Configuración Básica y Avanzada

### Configuración Básica (Generada por el Script)

Cuando ejecutas el script por primera vez, genera una configuración básica pero funcional:

#### package.json Básico

```json
{
  "name": "mi-proyecto",
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
  }
}
```

#### composer.json Básico

```json
{
  "name": "mi-proyecto/wordpress",
  "scripts": {
    "lint": "phpcs --standard=phpcs.xml.dist",
    "lint:fix": "phpcbf --standard=phpcs.xml.dist",
    "analyze": "phpstan analyze"
  },
  "require-dev": {
    "dealerdirect/phpcodesniffer-composer-installer": "^1.0",
    "phpcompatibility/php-compatibility": "^9.3",
    "phpstan/phpstan": "^1.11",
    "wp-coding-standards/wpcs": "^3.1"
  }
}
```

#### Makefile Básico

```makefile
# Comandos básicos generados
help: ## Show available commands
install: ## Install dependencies
dev: ## Start development
lint: ## Check code standards
format: ## Format code
build: ## Build for production
```

### Configuración Avanzada (Proyecto Maduro)

A medida que tu proyecto crece, puedes expandir la configuración:

#### package.json Avanzado

```json
{
  "scripts": {
    "// === LINTING POR COMPONENTE ===": "",
    "lint:js": "npm-run-all --parallel lint:js:*",
    "lint:js:plugin": "cd wordpress/wp-content/plugins/mi-plugin && npx eslint 'src/**/*.{js,jsx,ts,tsx}' --cache",
    "lint:js:theme": "cd wordpress/wp-content/themes/mi-tema && npx eslint 'assets/src/**/*.{js,jsx,ts,tsx}' --cache",
    
    "// === CSS LINTING ===": "",
    "lint:css": "npm-run-all --parallel lint:css:*",
    "lint:css:plugin": "cd wordpress/wp-content/plugins/mi-plugin && npx stylelint 'src/**/*.{css,scss}' --cache",
    
    "// === DESARROLLO PARALELO ===": "",
    "dev:all": "npm-run-all --parallel dev:*",
    "dev:plugin": "cd wordpress/wp-content/plugins/mi-plugin && npm run dev",
    "dev:theme": "cd wordpress/wp-content/themes/mi-tema && npm run dev",
    
    "// === BUILD OPTIMIZADO ===": "",
    "build:production": "npm-run-all format:all test:standards build:all",
    "build:all": "npm-run-all build:*",
    
    "// === ANÁLISIS Y TESTING ===": "",
    "analyze:php": "npm-run-all --parallel analyze:php:*",
    "analyze:security": "npm audit && composer audit",
    "analyze:bundle-size": "webpack-bundle-analyzer build/static/js/*.js",
    
    "// === WORKFLOWS OPTIMIZADOS ===": "",
    "pre-commit:full": "npm-run-all format:all verify:standards",
    "quick-check": "npm-run-all --parallel format:check test:standards:quick",
    "commit-ready": "npm-run-all format:all verify:standards"
  },
  "devDependencies": {
    "@commitlint/cli": "^19.8.1",
    "@wordpress/eslint-plugin": "^22.14.0",
    "@wordpress/stylelint-config": "^20.0.2",
    "husky": "^9.1.7",
    "lint-staged": "^15.3.0",
    "npm-run-all": "^4.1.5",
    "stylelint": "^14.16.1",
    "webpack-bundle-analyzer": "^4.10.2"
  }
}
```

#### Makefile Avanzado

```makefile
# === DESARROLLO AVANZADO ===
dev: ## 🚀 Start parallel development (all components with hot reload)
dev-blocks: ## 🧩 Development for Gutenberg blocks only
dev-theme: ## 🎨 Development for main theme
dev-watch: ## 🚀 Development with file watching and auto-reload

# === COMANDOS ESPECÍFICOS POR COMPONENTE ===
dev-mi-plugin-custom: ## 🧩 Development for mi-plugin-custom plugin
build-mi-plugin-custom: ## 📦 Build mi-plugin-custom plugin assets
dev-mi-tema-principal: ## 🎨 Development for mi-tema-principal theme
build-mi-tema-principal: ## 📦 Build mi-tema-principal theme assets

# === TESTING Y QA ===
test-unit: ## 🧪 Run unit tests
test-e2e: ## 🎭 Run end-to-end tests
test-a11y: ## ♿ Run accessibility tests
test-security: ## 🔒 Run security audit
test-complete: ## ✅ Run all tests

# === DEBUGGING ===
debug-theme: ## 🐛 Debug theme issues
debug-blocks: ## 🧩 Debug block registration issues
debug-assets: ## 📦 Debug asset loading issues
debug-performance: ## ⚡ Debug performance issues

# === LIGHTHOUSE Y PERFORMANCE ===
lighthouse-local: ## 🔍 Run Lighthouse on local
lighthouse-preprod: ## 🔍 Run Lighthouse on preprod
performance-check: ## 📊 Run performance analysis

# === CI/CD ===
deploy-staging: ## 🚀 Deploy to staging environment
deploy-prod: ## 🌟 Deploy to production environment
```

### Evolución de la Configuración

#### Fase 1: Configuración Inicial (Script Básico)

```bash
# Lo que genera el script inicialmente
./init-project.sh  # Modo 1

# Comandos disponibles inmediatamente:
make help          # ✅ Disponible
make install       # ✅ Disponible  
make dev           # ✅ Disponible
make lint          # ✅ Disponible
make format        # ✅ Disponible
npm run lint       # ✅ Disponible
npm run format     # ✅ Disponible
composer run lint  # ✅ Disponible
```

#### Fase 2: Expansión por Componentes

A medida que añades componentes específicos:

```bash
# Comandos que se generan automáticamente
make dev-mi-plugin-custom      # ✅ Auto-generado
make build-mi-plugin-custom    # ✅ Auto-generado
make dev-mi-tema-principal     # ✅ Auto-generado
make build-mi-tema-principal   # ✅ Auto-generado

# NPM scripts específicos por componente
npm run lint:js:plugin         # ✅ Auto-generado
npm run lint:js:theme          # ✅ Auto-generado
npm run dev:plugin             # ✅ Auto-generado
npm run dev:theme              # ✅ Auto-generado
```

#### Fase 3: Configuración Profesional

Para proyectos maduros, puedes añadir manualmente:

```bash
# Comandos avanzados (requieren configuración manual)
make test-unit                 # ⚙️ Requiere Jest
make test-e2e                  # ⚙️ Requiere Playwright
make test-a11y                 # ⚙️ Requiere Pa11y
make lighthouse-ci-run         # ⚙️ Requiere Lighthouse CI
make deploy-staging            # ⚙️ Requiere scripts de deploy

# NPM scripts avanzados
npm run analyze:bundle-size    # ⚙️ Requiere webpack-bundle-analyzer
npm run test:lighthouse-ci     # ⚙️ Requiere @lhci/cli
npm run analyze:security       # ⚙️ Configuración adicional
```

### Cómo Expandir tu Configuración

#### 1. Añadir Herramientas de Testing

```bash
# Instalar dependencias de testing
npm install --save-dev jest @wordpress/jest-preset-default
npm install --save-dev @playwright/test
npm install -g pa11y-ci

# Añadir scripts al package.json
"test:unit": "jest",
"test:e2e": "playwright test",
"test:a11y": "pa11y-ci --sitemap https://local.mi-proyecto.com/sitemap.xml"
```

#### 2. Añadir Análisis de Performance

```bash
# Instalar herramientas de análisis
npm install --save-dev webpack-bundle-analyzer
npm install -g @lhci/cli

# Añadir scripts de análisis
"analyze:bundle-size": "webpack-bundle-analyzer build/static/js/*.js",
"lighthouse:ci": "lhci autorun"
```

#### 3. Añadir Workflows de CI/CD

```bash
# Añadir scripts de deployment
"ci:setup": "npm run prepare && npm run build:all",
"ci:test": "npm-run-all --parallel test:*",
"deploy:staging": "echo 'Staging deployment via CI/CD pipeline'"
```

### Comandos de Migración

#### De Básico a Avanzado

```bash
# 1. Actualizar dependencias
npm install --save-dev @wordpress/stylelint-config stylelint npm-run-all husky lint-staged

# 2. Regenerar configuración con más componentes
./init-project.sh  # Modo 2 (solo configurar)

# 3. Añadir scripts avanzados manualmente al package.json
# 4. Expandir Makefile con comandos personalizados
# 5. Configurar herramientas adicionales (Jest, Playwright, etc.)
```

#### Verificar Nivel de Configuración

```bash
# Verificar qué comandos tienes disponibles
make help                    # Ver comandos Make
npm run                      # Ver scripts NPM
composer run-script --list   # Ver scripts Composer

# Verificar herramientas instaladas
which jest playwright pa11y-ci lighthouse
npm list --depth=0 | grep -E "(jest|playwright|stylelint|webpack)"
```

Esta progresión te permite empezar con una configuración básica funcional y expandirla gradualmente según las necesidades de tu proyecto.

## 📚 Requisitos del Sistema

### Herramientas Obligatorias

- **Node.js** >= 18.0.0 (LTS recomendado)
- **npm** >= 8.0.0 (incluido con Node.js)
- **Composer** >= 2.4.0 (gestión de dependencias PHP)
- **PHP** >= 8.1 (con extensiones: json, mbstring, zip)
- **Git** >= 2.30.0 (control de versiones)

### Herramientas Específicas por Modo

#### Para Modo 4 (Fusionar Configuración) - OBLIGATORIO

- **jq** >= 1.6 - Procesamiento de JSON para fusión de configuraciones

**Instalación de jq**:
```bash
# macOS (Homebrew)
brew install jq

# Ubuntu/Debian
sudo apt-get install jq

# CentOS/RHEL/Fedora
sudo yum install jq
# o
sudo dnf install jq

# Windows (Chocolatey)
choco install jq

# Verificar instalación
jq --version
```

### Estructura de Proyecto Requerida

El script requiere una estructura WordPress válida en una de estas configuraciones:

```bash
# Opción 1: WordPress en subdirectorio (recomendado)
mi-proyecto/
├── wordpress/
│   └── wp-content/
│       ├── plugins/
│       ├── themes/
│       └── mu-plugins/

# Opción 2: WordPress en raíz
mi-proyecto/
├── wp-content/
│   ├── plugins/
│   ├── themes/
│   └── mu-plugins/
```

### Herramientas Recomendadas

- **Make** - Para usar comandos del Makefile generado
- **WP-CLI** >= 2.8.0 - Gestión de WordPress desde línea de comandos
- **Docker** - Para entorno de desarrollo local consistente

### Extensiones VSCode Recomendadas

#### Esenciales para WordPress

- **PHP Intelephense** (`bmewburn.vscode-intelephense-client`) - Autocompletado y análisis PHP
- **PHPSAB** (`valeryanm.vscode-phpsab`) - Integración con PHPCS/PHPCBF
- **ESLint** (`dbaeumer.vscode-eslint`) - Linting JavaScript en tiempo real
- **WordPress Snippets** (`wordpresstoolbox.wordpress-toolbox`) - Snippets de WordPress

#### Formateo y Calidad de Código

- **Prettier** (`esbenp.prettier-vscode`) - Formateo automático de código
- **EditorConfig** (`editorconfig.editorconfig`) - Consistencia de formato
- **Stylelint** (`stylelint.vscode-stylelint`) - Linting CSS/SCSS
- **GitLens** (`eamodio.gitlens`) - Información avanzada de Git

#### Productividad

- **Auto Rename Tag** (`formulahendry.auto-rename-tag`) - Renombrado automático de etiquetas HTML
- **Bracket Pair Colorizer** (`coenraads.bracket-pair-colorizer-2`) - Colores para brackets
- **Path Intellisense** (`christian-kohler.path-intellisense`) - Autocompletado de rutas

## 🔧 Instalación y Configuración

### Verificación de Requisitos

Antes de comenzar, verifica que tienes todas las herramientas necesarias:

```bash
# Verificar versiones de herramientas
node --version    # Debe ser >= 18.0.0
npm --version     # Debe ser >= 8.0.0
composer --version # Debe ser >= 2.4.0
php --version     # Debe ser >= 8.1
git --version     # Debe ser >= 2.30.0

# Verificar jq (solo si planeas usar Modo 4)
jq --version      # Debe ser >= 1.6
```

### Configuración Inicial del Proyecto

#### Para Proyecto Nuevo

```bash
# 1. Clonar la plantilla
git clone https://github.com/tu-usuario/wp-init.git mi-proyecto-wordpress
cd mi-proyecto-wordpress

# 2. Verificar estructura WordPress
ls -la wordpress/wp-content/
# Debe mostrar: plugins/ themes/ mu-plugins/

# 3. Ejecutar configuración inicial
./init-project.sh
# Seleccionar: Modo 1 (Configurar y formatear proyecto)

# 4. Instalar dependencias generadas
npm install
composer install

# 5. Verificar instalación
make status
```

#### Para Proyecto Existente

```bash
# 1. Navegar a tu proyecto existente
cd /ruta/a/tu/proyecto-wordpress

# 2. Clonar plantilla en ubicación temporal
git clone https://github.com/tu-usuario/wp-init.git ~/temp/wp-standards

# 3. Ejecutar desde la plantilla
~/temp/wp-standards/init-project.sh
# Seleccionar: Modo 4 (Fusionar configuración) - Requiere jq

# 4. Instalar nuevas dependencias
npm install
composer install

# 5. Limpiar archivos temporales
rm -rf ~/temp/wp-standards
```

### Configuración de Entorno de Desarrollo

#### Variables de Entorno

Crea un archivo `.env.local` en la raíz del proyecto:

```bash
# Configuración de desarrollo local
WP_ENV=development
WP_DEBUG=true
WP_DEBUG_LOG=true
WP_DEBUG_DISPLAY=false

# Base de datos local
DB_NAME=mi_proyecto_wp
DB_USER=root
DB_PASSWORD=password
DB_HOST=localhost

# URLs del proyecto
WP_HOME=https://local.mi-proyecto.com
WP_SITEURL=https://local.mi-proyecto.com/wordpress
```

#### Configuración de VSCode

El script genera automáticamente:

- **wp.code-workspace** - Workspace con componentes seleccionados
- **.vscode/settings.json** - Configuración específica del proyecto
- **.vscode/extensions.json** - Extensiones recomendadas

Para aplicar la configuración:

```bash
# Abrir workspace generado
code wp.code-workspace

# O abrir proyecto directamente
code .
```

### Verificación de Instalación

#### Verificación Básica

```bash
# Verificar estado general del proyecto
make status

# Verificar salud de dependencias
make health

# Verificar que las herramientas de linting funcionan
make lint-check
```

#### Verificación Detallada

```bash
# Verificar PHPCS
./vendor/bin/phpcs --version
./vendor/bin/phpcs --standard=phpcs.xml.dist --dry-run

# Verificar PHPStan
./vendor/bin/phpstan --version
./vendor/bin/phpstan analyse --dry-run

# Verificar ESLint
npx eslint --version
npx eslint '**/*.{js,jsx,ts,tsx}' --max-warnings 0 --dry-run

# Verificar Prettier
npx prettier --version
npx prettier --check '**/*.{js,jsx,ts,tsx,css,scss,json,md}'
```

#### Verificación de Git Hooks

```bash
# Verificar que Husky está configurado
ls -la .husky/
cat .husky/pre-commit

# Probar pre-commit hook
git add .
git commit -m "test: verificar pre-commit hook"
```

### Solución de Problemas Comunes

#### Error: "jq: command not found" (Modo 4)

```bash
# El Modo 4 requiere jq para fusionar archivos JSON
# Instalar según tu sistema operativo:

# macOS
brew install jq

# Ubuntu/Debian
sudo apt-get update && sudo apt-get install jq

# Verificar instalación
jq --version
```

#### Error: "composer: command not found"

```bash
# Instalar Composer globalmente
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# Verificar instalación
composer --version
```

#### Error: "Node.js version too old"

```bash
# Instalar Node.js LTS usando nvm (recomendado)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc
nvm install --lts
nvm use --lts

# Verificar versión
node --version
```

#### Error: "WordPress structure not found"

```bash
# El script busca estas estructuras:
# - wordpress/wp-content/
# - wp-content/

# Verificar estructura actual
ls -la
ls -la wordpress/ 2>/dev/null || echo "No hay directorio wordpress/"
ls -la wp-content/ 2>/dev/null || echo "No hay directorio wp-content/"

# Si no tienes WordPress, descárgalo:
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
```

#### Error: "Permission denied" al ejecutar script

```bash
# Dar permisos de ejecución al script
chmod +x init-project.sh

# Verificar permisos
ls -la init-project.sh
```

#### Error: "PHPCS not found" después de instalación

```bash
# Verificar que Composer instaló las dependencias
ls -la vendor/bin/

# Si no existe vendor/, instalar dependencias
composer install

# Verificar instalación de PHPCS
./vendor/bin/phpcs --version
```

#### Problemas con ESLint y archivos JavaScript

```bash
# Verificar que npm instaló las dependencias
ls -la node_modules/.bin/

# Si no existe node_modules/, instalar dependencias
npm install

# Verificar configuración de ESLint
npx eslint --print-config test.js
```

### Actualización de Herramientas

#### Actualizar Dependencias PHP

```bash
# Verificar dependencias desactualizadas
composer outdated

# Actualizar dependencias
composer update

# Actualizar solo herramientas de desarrollo
composer update --dev
```

#### Actualizar Dependencias JavaScript

```bash
# Verificar dependencias desactualizadas
npm outdated

# Actualizar dependencias
npm update

# Actualizar dependencias globales
npm update -g
```

#### Actualizar Configuración de Estándares

```bash
# Para actualizar solo las reglas de linting sin cambiar código:
./init-project.sh
# Seleccionar: Modo 2 (Solo configurar)

# Para aplicar nuevas reglas a código existente:
./init-project.sh
# Seleccionar: Modo 3 (Solo formatear)
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

<div align="center">

### 🔧 **Guía Completa de Solución de Problemas**

*Encuentra la solución a los problemas más comunes rápidamente*

</div>

<table>
<tr>
<td align="center" width="20%">

### 🌐 **Flujo Externo**
Nuevas funcionalidades

</td>
<td align="center" width="20%">

### 🔍 **Validación**
Errores de estructura

</td>
<td align="center" width="20%">

### 📁 **Archivos**
Problemas de operaciones

</td>
<td align="center" width="20%">

### 🧩 **Componentes**
Selección y detección

</td>
<td align="center" width="20%">

### ⚙️ **Sistema**
Herramientas y permisos

</td>
</tr>
</table>

---

### 🌐 Problemas del Flujo Externo

#### ❌ Error: "Failed to configure WordPress path"

<div align="center">

**🔍 Problema**: El script no puede validar la ruta de WordPress proporcionada.

</div>

<details>
<summary><strong>🛠️ Solución paso a paso (click para expandir)</strong></summary>

```bash
# 1. Verificar que la ruta existe y es correcta
ls -la /ruta/a/tu/wordpress
# Debe mostrar wp-content/

# 2. Verificar estructura WordPress completa
ls -la /ruta/a/tu/wordpress/wp-content/
# Debe mostrar: plugins/, themes/, (mu-plugins/ opcional)

# 3. Si falta algún directorio, crearlo
mkdir -p /ruta/a/tu/wordpress/wp-content/{plugins,themes,mu-plugins}

# 4. Usar ruta absoluta en lugar de relativa
/tmp/wp-init/init-project.sh /Users/usuario/Sites/proyecto/wordpress 1

# 5. Verificar permisos de escritura
ls -ld /ruta/a/tu/proyecto
# Debe mostrar permisos de escritura (w)
```

</details>

**💡 Consejos adicionales:**
- Usa rutas absolutas para evitar confusión
- Verifica que el directorio padre (raíz del proyecto) sea escribible
- El directorio WordPress debe contener wp-content/ con subdirectorios

---

#### ❌ Error: "Project root directory is not writable"

**🔍 Problema**: El script no puede escribir en el directorio raíz del proyecto.

```bash
# 1. Verificar permisos actuales
ls -ld /ruta/a/tu/proyecto
# Ejemplo salida: drwxr-xr-x (sin permisos de escritura)

# 2. Cambiar permisos del directorio
chmod 755 /ruta/a/tu/proyecto

# 3. Verificar que el cambio funcionó
ls -ld /ruta/a/tu/proyecto
# Debe mostrar: drwxr-xr-x (con permisos de escritura)

# 4. Si sigues sin permisos, verificar propietario
ls -la /ruta/a/tu/proyecto
whoami

# 5. Si no eres el propietario, cambiar propietario (con cuidado)
sudo chown -R $(whoami):$(whoami) /ruta/a/tu/proyecto
```

---

#### ❌ Error: "Configuration rejected by user"

**🔍 Problema**: Rechazaste la configuración detectada automáticamente.

```bash
# El script detectó una configuración que no es correcta
# Opciones para solucionarlo:

# 1. Verificar que especificaste la ruta correcta
/tmp/wp-init/init-project.sh /ruta/correcta/a/wordpress 1

# 2. Si la estructura es diferente, usar --help para ver ejemplos
/tmp/wp-init/init-project.sh --help

# 3. Verificar estructura esperada vs actual
echo "Estructura esperada:"
echo "  /ruta/proyecto/wordpress/wp-content/"
echo ""
echo "Tu estructura actual:"
find /ruta/a/tu/proyecto -name "wp-content" -type d
```

---

#### ❌ Error: "Invalid WordPress path. Please try again."

**🔍 Problema**: La ruta proporcionada no contiene una instalación WordPress válida.

```bash
# 1. Verificar que apuntas al directorio correcto
# ✅ Correcto: /proyecto/wordpress (contiene wp-content/)
# ❌ Incorrecto: /proyecto/wordpress/wp-content (es el subdirectorio)

# 2. Verificar contenido del directorio
ls -la /ruta/especificada/
# Debe contener wp-content/ directamente

# 3. Si wp-content está en otro lugar, ajustar ruta
find /ruta/a/tu/proyecto -name "wp-content" -type d
# Usar el directorio padre de wp-content

# 4. Ejemplo de estructura correcta
/proyecto/
├── docker/
├── wordpress/          ← Usar esta ruta
│   └── wp-content/     ← No esta
└── README.md
```

---

#### 🔧 Uso de Parámetros CLI

**Sintaxis completa con ejemplos:**

```bash
# Ayuda completa
/tmp/wp-init/init-project.sh --help

# Versión del script
/tmp/wp-init/init-project.sh --version

# Modo no interactivo (automático)
/tmp/wp-init/init-project.sh /ruta/wordpress 1

# Diferentes modos
/tmp/wp-init/init-project.sh /ruta/wordpress 1  # Configurar y formatear
/tmp/wp-init/init-project.sh /ruta/wordpress 2  # Solo configurar
/tmp/wp-init/init-project.sh /ruta/wordpress 3  # Solo formatear
/tmp/wp-init/init-project.sh /ruta/wordpress 4  # Fusionar (requiere jq)

# Ejemplos con estructuras reales
/tmp/wp-init/init-project.sh /Users/dev/cliente/wordpress 1
/tmp/wp-init/init-project.sh ./mi-proyecto-wp 2
/tmp/wp-init/init-project.sh /var/www/sitio/wp 4
```

---

#### 🏗️ Compatibilidad con Estructuras Existentes

**El script preserva automáticamente:**

```bash
# ✅ Archivos que se preservan automáticamente
docker-compose.yml      # Configuración Docker
Jenkinsfile            # Pipeline Jenkins
.gitlab-ci.yml         # Pipeline GitLab
.github/               # GitHub Actions
Dockerfile             # Configuración Docker
.env                   # Variables de entorno
README.md              # Documentación existente
docs/                  # Documentación del proyecto

# ✅ Archivos que se fusionan inteligentemente (Modo 4)
package.json           # Dependencias NPM preservadas
composer.json          # Dependencias PHP preservadas

# ✅ Archivos que se crean/actualizan
phpcs.xml.dist         # Configuración PHP Standards
eslint.config.js       # Configuración JavaScript
wp.code-workspace      # Workspace VSCode
.vscode/settings.json  # Configuración VSCode
```

---

### 🔍 Errores de Validación

#### ❌ Error: "Selected plugin directory not found"

<div align="center">

**🔍 Problema**: El script no puede encontrar un plugin que seleccionaste.

</div>

<details>
<summary><strong>🛠️ Solución paso a paso (click para expandir)</strong></summary>

```bash
# 1. Verificar que el directorio existe
ls -la wordpress/wp-content/plugins/mi-plugin-custom

# 2. Si no existe, crear estructura básica
mkdir -p wordpress/wp-content/plugins/mi-plugin-custom
echo "<?php // Plugin principal" > wordpress/wp-content/plugins/mi-plugin-custom/init.php

# 3. Re-ejecutar el script
./init-project.sh
```

</details>

<div align="center">

✅ **Resultado**: Plugin detectado correctamente en la siguiente ejecución

</div>

---

#### Error: "Selected theme directory not found"

**Problema**: El script no puede encontrar un tema que seleccionaste.

```bash
# Verificar que el directorio existe
ls -la wordpress/wp-content/themes/mi-tema

# Si no existe, crear estructura básica
mkdir -p wordpress/wp-content/themes/mi-tema
echo "<?php // Tema principal" > wordpress/wp-content/themes/mi-tema/functions.php
echo "/* Theme Name: Mi Tema */" > wordpress/wp-content/themes/mi-tema/style.css

# Re-ejecutar el script
./init-project.sh
```

#### Error: "No components selected for processing"

**Problema**: No seleccionaste ningún componente para procesar.

```bash
# El script requiere al menos un componente
# Verificar que tienes plugins o temas personalizados:

ls -la wordpress/wp-content/plugins/
ls -la wordpress/wp-content/themes/

# Si no tienes componentes personalizados, crear uno:
mkdir -p wordpress/wp-content/plugins/mi-proyecto-plugin
echo "<?php
/*
Plugin Name: Mi Proyecto Plugin
Description: Plugin personalizado del proyecto
Version: 1.0.0
*/" > wordpress/wp-content/plugins/mi-proyecto-plugin/init.php
```

#### Error: "WordPress structure validation failed"

**Problema**: El script no puede detectar una estructura WordPress válida.

```bash
# El script busca estas estructuras:
# 1. wordpress/wp-content/ (estructura con subdirectorio)
# 2. wp-content/ (estructura directa)

# Verificar estructura actual
pwd
ls -la

# Opción 1: Crear estructura con subdirectorio wordpress/
mkdir -p wordpress/wp-content/{plugins,themes,mu-plugins}

# Opción 2: Crear estructura directa
mkdir -p wp-content/{plugins,themes,mu-plugins}

# Verificar que se creó correctamente
ls -la wordpress/wp-content/ || ls -la wp-content/
```

### Problemas de Operaciones de Archivos

#### Error: "Failed to create backup directory"

**Problema**: El script no puede crear el directorio de backup.

```bash
# Verificar permisos del directorio actual
ls -la .

# Dar permisos de escritura si es necesario
chmod 755 .

# Verificar espacio en disco
df -h .

# Si hay problemas de espacio, limpiar archivos temporales
rm -rf backup-* 2>/dev/null
rm -rf *.log 2>/dev/null

# Re-ejecutar el script
./init-project.sh
```

#### Error: "Template file not found"

**Problema**: Faltan archivos de plantilla necesarios.

```bash
# Verificar que existen los archivos de plantilla
ls -la .gitignore.template
ls -la bitbucket-pipelines.yml
ls -la commitlint.config.cjs

# Si faltan archivos, descargar desde el repositorio
curl -O https://raw.githubusercontent.com/tu-usuario/wp-init/main/.gitignore.template
curl -O https://raw.githubusercontent.com/tu-usuario/wp-init/main/bitbucket-pipelines.yml
curl -O https://raw.githubusercontent.com/tu-usuario/wp-init/main/commitlint.config.cjs

# O clonar el repositorio completo nuevamente
cd ..
git clone https://github.com/tu-usuario/wp-init.git wp-init-fresh
cd wp-init-fresh
```

#### Error: "Failed to copy template file"

**Problema**: Error al copiar archivos de plantilla.

```bash
# Verificar permisos de archivos de plantilla
ls -la *.template

# Verificar permisos del directorio destino
ls -la .

# Dar permisos de lectura a plantillas
chmod 644 *.template

# Dar permisos de escritura al directorio
chmod 755 .

# Verificar que no hay archivos bloqueados
lsof . 2>/dev/null | grep -E '\.(template|yml|js|json)$'

# Re-ejecutar el script
./init-project.sh
```

#### Error: "Backup restoration failed"

**Problema**: No se pueden restaurar los archivos de backup.

```bash
# Verificar que existe el directorio de backup
ls -la backup-*

# Restaurar manualmente si es necesario
BACKUP_DIR=$(ls -d backup-* | head -1)
echo "Restaurando desde: $BACKUP_DIR"

# Restaurar archivos específicos
cp "$BACKUP_DIR/phpcs.xml.dist" . 2>/dev/null
cp "$BACKUP_DIR/eslint.config.js" . 2>/dev/null
cp "$BACKUP_DIR/package.json" . 2>/dev/null
cp "$BACKUP_DIR/composer.json" . 2>/dev/null

echo "Archivos restaurados manualmente"
```

### Problemas de Selección de Componentes

#### Error: "Component detection failed"

**Problema**: El script no puede detectar componentes automáticamente.

```bash
# Verificar estructura de componentes
find wordpress/wp-content -name "*.php" -path "*/plugins/*" | head -5
find wordpress/wp-content -name "*.php" -path "*/themes/*" | head -5

# Si no hay archivos PHP, crear archivos básicos
for plugin in $(ls wordpress/wp-content/plugins/ 2>/dev/null); do
    if [ ! -f "wordpress/wp-content/plugins/$plugin/$plugin.php" ]; then
        echo "<?php // Plugin: $plugin" > "wordpress/wp-content/plugins/$plugin/$plugin.php"
    fi
done

for theme in $(ls wordpress/wp-content/themes/ 2>/dev/null); do
    if [ ! -f "wordpress/wp-content/themes/$theme/functions.php" ]; then
        echo "<?php // Theme: $theme" > "wordpress/wp-content/themes/$theme/functions.php"
    fi
done
```

#### Error: "Invalid component selection"

**Problema**: Seleccionaste un componente que no es válido.

```bash
# El script solo acepta componentes que:
# 1. Existen físicamente en el directorio
# 2. Contienen archivos PHP
# 3. No son temas/plugins de WordPress core

# Verificar componentes válidos manualmente
echo "=== Plugins válidos ==="
for dir in wordpress/wp-content/plugins/*/; do
    plugin=$(basename "$dir")
    if [ -f "$dir/$plugin.php" ] || [ -f "$dir/init.php" ] || [ -f "$dir/index.php" ]; then
        echo "✅ $plugin"
    else
        echo "❌ $plugin (sin archivo PHP principal)"
    fi
done

echo "=== Temas válidos ==="
for dir in wordpress/wp-content/themes/*/; do
    theme=$(basename "$dir")
    if [ -f "$dir/functions.php" ] || [ -f "$dir/index.php" ]; then
        echo "✅ $theme"
    else
        echo "❌ $theme (sin functions.php o index.php)"
    fi
done
```

#### Problema: "No se detectan componentes personalizados"

**Solución**: Verificar que tienes componentes no-core.

```bash
# El script ignora automáticamente estos componentes de WordPress core:
# Plugins: akismet, hello-dolly
# Temas: twentytwentyone, twentytwentytwo, twentytwentythree, twentytwentyfour

# Verificar qué componentes tienes
echo "=== Todos los plugins ==="
ls -la wordpress/wp-content/plugins/

echo "=== Todos los temas ==="
ls -la wordpress/wp-content/themes/

# Si solo tienes componentes core, crear uno personalizado
mkdir -p wordpress/wp-content/plugins/mi-proyecto-custom
echo "<?php
/*
Plugin Name: Mi Proyecto Custom
Description: Plugin personalizado para mi proyecto
Version: 1.0.0
*/" > wordpress/wp-content/plugins/mi-proyecto-custom/init.php

# Re-ejecutar el script
./init-project.sh
```

### Problemas de Generación de Workspace

#### Error: "Failed to generate VSCode workspace"

**Problema**: No se puede crear el archivo wp.code-workspace.

```bash
# Verificar permisos de escritura
touch wp.code-workspace.test && rm wp.code-workspace.test

# Si hay error de permisos
chmod 755 .

# Verificar que no hay conflictos con archivos existentes
ls -la wp.code-workspace*

# Si existe un archivo corrupto, eliminarlo
rm wp.code-workspace 2>/dev/null

# Crear workspace manualmente si es necesario
cat > wp.code-workspace << 'EOF'
{
  "folders": [
    {
      "path": "."
    }
  ],
  "settings": {
    "editor.rulers": [120]
  }
}
EOF

echo "Workspace básico creado manualmente"
```

#### Error: "VSCode settings directory creation failed"

**Problema**: No se puede crear el directorio .vscode/.

```bash
# Verificar si ya existe
ls -la .vscode/

# Si existe pero hay problemas, eliminarlo y recrear
rm -rf .vscode/
mkdir .vscode

# Crear configuración básica
cat > .vscode/settings.json << 'EOF'
{
  "editor.rulers": [120],
  "phpsab.snifferMode": "onType",
  "[php]": {
    "editor.formatOnSave": true,
    "editor.defaultFormatter": "valeryanm.vscode-phpsab"
  }
}
EOF

echo "Configuración VSCode creada manualmente"
```

#### Problema: "Workspace no incluye todos los componentes"

**Solución**: Verificar que los componentes seleccionados existen.

```bash
# El workspace solo incluye componentes que:
# 1. Fueron seleccionados durante la ejecución
# 2. Existen físicamente
# 3. Contienen archivos PHP

# Verificar contenido del workspace actual
cat wp.code-workspace | jq '.folders'

# Si falta algún componente, añadirlo manualmente
# Ejemplo para añadir un plugin:
jq '.folders += [{"path": "wordpress/wp-content/plugins/mi-nuevo-plugin"}]' wp.code-workspace > wp.code-workspace.tmp
mv wp.code-workspace.tmp wp.code-workspace

echo "Componente añadido al workspace"
```

### Problemas de Archivos de Plantilla

#### Error: "Template variable replacement failed"

**Problema**: Las variables en las plantillas no se reemplazan correctamente.

```bash
# Verificar que el nombre del proyecto se detectó correctamente
echo "Nombre del proyecto detectado:"
grep -r "PROJECT_NAME" . 2>/dev/null || echo "No se encontró PROJECT_NAME"

# Si hay problemas con variables, verificar plantillas
echo "=== Variables en plantillas ==="
grep -r "{{.*}}" *.template 2>/dev/null

# Ejecutar el script en modo debug (si está disponible)
DEBUG=1 ./init-project.sh

# O especificar el nombre manualmente cuando se solicite
./init-project.sh
# Cuando pida el nombre: mi-proyecto-especifico
```

#### Error: "Missing required template files"

**Problema**: Faltan archivos de plantilla esenciales.

```bash
# Lista de archivos de plantilla requeridos:
REQUIRED_TEMPLATES=(
    ".gitignore.template"
    "bitbucket-pipelines.yml"
    "commitlint.config.cjs"
    "lighthouserc.js"
    "Makefile"
    "verify-template.sh"
)

# Verificar cuáles faltan
echo "=== Verificando plantillas ==="
for template in "${REQUIRED_TEMPLATES[@]}"; do
    if [ -f "$template" ]; then
        echo "✅ $template"
    else
        echo "❌ $template (FALTA)"
    fi
done

# Descargar plantillas faltantes
BASE_URL="https://raw.githubusercontent.com/tu-usuario/wp-init/main"
for template in "${REQUIRED_TEMPLATES[@]}"; do
    if [ ! -f "$template" ]; then
        echo "Descargando $template..."
        curl -s "$BASE_URL/$template" -o "$template"
    fi
done
```

#### Problema: "Template adaptation produces invalid files"

**Solución**: Verificar sintaxis de archivos generados.

```bash
# Verificar sintaxis de archivos JSON generados
echo "=== Verificando JSON ==="
jq . package.json > /dev/null && echo "✅ package.json válido" || echo "❌ package.json inválido"
jq . composer.json > /dev/null && echo "✅ composer.json válido" || echo "❌ composer.json inválido"

# Verificar sintaxis de archivos YAML
echo "=== Verificando YAML ==="
python -c "import yaml; yaml.safe_load(open('bitbucket-pipelines.yml'))" 2>/dev/null && echo "✅ bitbucket-pipelines.yml válido" || echo "❌ bitbucket-pipelines.yml inválido"

# Verificar sintaxis de archivos JavaScript
echo "=== Verificando JavaScript ==="
node -c eslint.config.js 2>/dev/null && echo "✅ eslint.config.js válido" || echo "❌ eslint.config.js inválido"
node -c lighthouserc.js 2>/dev/null && echo "✅ lighthouserc.js válido" || echo "❌ lighthouserc.js inválido"

# Si hay archivos inválidos, restaurar desde backup
if [ -d "backup-$(date +%Y%m%d)*" ]; then
    BACKUP_DIR=$(ls -d backup-* | tail -1)
    echo "Restaurando archivos desde $BACKUP_DIR"
    cp "$BACKUP_DIR"/* . 2>/dev/null
fi
```

### Problemas de Permisos y Backups

#### Error: "Permission denied creating backup"

**Problema**: No hay permisos para crear backups.

```bash
# Verificar permisos del directorio actual
ls -ld .

# Verificar espacio disponible
df -h .

# Dar permisos de escritura
chmod 755 .

# Si el problema persiste, usar directorio temporal
BACKUP_DIR="/tmp/wp-init-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"
echo "Usando directorio de backup temporal: $BACKUP_DIR"

# Crear backup manual
cp phpcs.xml.dist "$BACKUP_DIR/" 2>/dev/null
cp eslint.config.js "$BACKUP_DIR/" 2>/dev/null
cp package.json "$BACKUP_DIR/" 2>/dev/null
cp composer.json "$BACKUP_DIR/" 2>/dev/null

echo "Backup manual creado en: $BACKUP_DIR"
```

#### Error: "Cannot write to configuration files"

**Problema**: Los archivos de configuración están protegidos contra escritura.

```bash
# Verificar permisos de archivos de configuración
ls -la phpcs.xml.dist eslint.config.js package.json composer.json

# Dar permisos de escritura
chmod 644 phpcs.xml.dist eslint.config.js package.json composer.json

# Verificar que no están siendo usados por otros procesos
lsof phpcs.xml.dist eslint.config.js package.json composer.json 2>/dev/null

# Si hay procesos usando los archivos, terminarlos
# (Solo si es seguro hacerlo)
# pkill -f "phpcs\|eslint\|composer\|npm"

# Re-ejecutar el script
./init-project.sh
```

#### Error: "Backup directory already exists"

**Problema**: Ya existe un directorio de backup con el mismo timestamp.

```bash
# Verificar backups existentes
ls -la backup-*

# Limpiar backups antiguos (más de 7 días)
find . -name "backup-*" -type d -mtime +7 -exec rm -rf {} \; 2>/dev/null

# O renombrar backup existente
EXISTING_BACKUP=$(ls -d backup-* | head -1)
if [ -n "$EXISTING_BACKUP" ]; then
    mv "$EXISTING_BACKUP" "${EXISTING_BACKUP}-old"
    echo "Backup existente renombrado a: ${EXISTING_BACKUP}-old"
fi

# Re-ejecutar el script
./init-project.sh
```

#### Problema: "Cannot restore from backup"

**Solución**: Restauración manual de archivos.

```bash
# Listar backups disponibles
echo "=== Backups disponibles ==="
ls -la backup-*/

# Seleccionar el backup más reciente
LATEST_BACKUP=$(ls -d backup-* | tail -1)
echo "Usando backup: $LATEST_BACKUP"

# Restaurar archivos uno por uno
echo "=== Restaurando archivos ==="
for file in "$LATEST_BACKUP"/*; do
    filename=$(basename "$file")
    if [ -f "$file" ]; then
        cp "$file" "./$filename"
        echo "✅ Restaurado: $filename"
    fi
done

# Verificar que los archivos se restauraron correctamente
echo "=== Verificando archivos restaurados ==="
ls -la phpcs.xml.dist eslint.config.js package.json composer.json
```

### Problemas Comunes del Sistema

#### Error: "jq: command not found" (Modo 4)

**Problema**: El Modo 4 requiere jq para fusionar archivos JSON.

```bash
# Instalar según tu sistema operativo:

# macOS
brew install jq

# Ubuntu/Debian
sudo apt-get update && sudo apt-get install jq

# CentOS/RHEL
sudo yum install jq

# Arch Linux
sudo pacman -S jq

# Verificar instalación
jq --version
```

#### Error: "composer: command not found"

**Problema**: Composer no está instalado.

```bash
# Instalar Composer globalmente
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# O usando Homebrew (macOS)
brew install composer

# Verificar instalación
composer --version
```

#### Error: "Node.js version too old"

**Problema**: Se requiere Node.js 18 o superior.

```bash
# Verificar versión actual
node --version

# Instalar Node.js LTS usando nvm (recomendado)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc
nvm install --lts
nvm use --lts

# O usando Homebrew (macOS)
brew install node

# Verificar nueva versión
node --version
```

#### Error: "Permission denied" al ejecutar script

**Problema**: El script no tiene permisos de ejecución.

```bash
# Dar permisos de ejecución al script
chmod +x init-project.sh
chmod +x verify-template.sh

# Verificar permisos
ls -la init-project.sh verify-template.sh

# Si el problema persiste, ejecutar con bash explícitamente
bash init-project.sh
```

### Verificación y Diagnóstico

#### Verificar Estado del Proyecto

```bash
# Verificar plantilla
./verify-template.sh

# Verificar que todas las herramientas están instaladas
echo "=== Verificando herramientas ==="
command -v composer >/dev/null && echo "✅ Composer" || echo "❌ Composer"
command -v node >/dev/null && echo "✅ Node.js" || echo "❌ Node.js"
command -v npm >/dev/null && echo "✅ NPM" || echo "❌ NPM"
command -v jq >/dev/null && echo "✅ jq" || echo "❌ jq"

# Verificar dependencias PHP
if [ -f "composer.json" ]; then
    composer validate
    composer check-platform-reqs
fi

# Verificar dependencias JavaScript
if [ -f "package.json" ]; then
    npm doctor
fi
```

#### Diagnóstico Completo

```bash
# Script de diagnóstico completo
cat > diagnose.sh << 'EOF'
#!/bin/bash
echo "=== Diagnóstico del Proyecto WordPress ==="
echo "Fecha: $(date)"
echo "Directorio: $(pwd)"
echo

echo "=== Estructura WordPress ==="
ls -la wordpress/wp-content/ 2>/dev/null || ls -la wp-content/ 2>/dev/null || echo "❌ No se encontró estructura WordPress"
echo

echo "=== Componentes Detectados ==="
echo "Plugins:"
ls -la wordpress/wp-content/plugins/ 2>/dev/null || ls -la wp-content/plugins/ 2>/dev/null
echo "Temas:"
ls -la wordpress/wp-content/themes/ 2>/dev/null || ls -la wp-content/themes/ 2>/dev/null
echo

echo "=== Archivos de Configuración ==="
ls -la phpcs.xml.dist eslint.config.js package.json composer.json wp.code-workspace 2>/dev/null
echo

echo "=== Archivos de Plantilla ==="
ls -la *.template 2>/dev/null
echo

echo "=== Backups ==="
ls -la backup-* 2>/dev/null || echo "No hay backups"
echo

echo "=== Herramientas del Sistema ==="
command -v composer >/dev/null && echo "✅ Composer $(composer --version)" || echo "❌ Composer no instalado"
command -v node >/dev/null && echo "✅ Node.js $(node --version)" || echo "❌ Node.js no instalado"
command -v npm >/dev/null && echo "✅ NPM $(npm --version)" || echo "❌ NPM no instalado"
command -v jq >/dev/null && echo "✅ jq $(jq --version)" || echo "❌ jq no instalado"
echo

echo "=== Permisos ==="
ls -la init-project.sh verify-template.sh 2>/dev/null
echo

echo "=== Espacio en Disco ==="
df -h .
echo

echo "=== Procesos Relacionados ==="
ps aux | grep -E "(composer|npm|node|phpcs|eslint)" | grep -v grep || echo "No hay procesos relacionados"
EOF

chmod +x diagnose.sh
./diagnose.sh
```

### Limpiar y Reinstalar

#### Limpieza Completa

```bash
# Limpiar todo (¡CUIDADO! Esto eliminará configuración)
echo "⚠️  ADVERTENCIA: Esto eliminará toda la configuración generada"
read -p "¿Continuar? (y/N): " confirm
if [ "$confirm" = "y" ]; then
    # Crear backup antes de limpiar
    CLEANUP_BACKUP="cleanup-backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$CLEANUP_BACKUP"
    cp phpcs.xml.dist eslint.config.js package.json composer.json wp.code-workspace "$CLEANUP_BACKUP/" 2>/dev/null
    
    # Limpiar archivos generados
    rm -f phpcs.xml.dist eslint.config.js phpstan.neon.dist
    rm -f package.json composer.json wp.code-workspace
    rm -rf .vscode/ node_modules/ vendor/
    rm -rf wordpress/wp-content/*/node_modules/
    rm -rf wordpress/wp-content/*/vendor/
    rm -rf backup-*
    rm -f *.log
    
    echo "✅ Limpieza completa realizada"
    echo "📁 Backup guardado en: $CLEANUP_BACKUP"
    echo "🔄 Ejecuta ./init-project.sh para reconfigurar"
fi
```

#### Reinstalación Completa

```bash
# Reinstalar dependencias
echo "=== Reinstalando dependencias ==="

# Si existe composer.json, instalar dependencias PHP
if [ -f "composer.json" ]; then
    echo "Instalando dependencias PHP..."
    composer install --no-dev --optimize-autoloader
fi

# Si existe package.json, instalar dependencias JavaScript
if [ -f "package.json" ]; then
    echo "Instalando dependencias JavaScript..."
    npm ci
fi

# Verificar instalación
echo "=== Verificando instalación ==="
if [ -f "vendor/bin/phpcs" ]; then
    echo "✅ PHPCS: $(./vendor/bin/phpcs --version)"
else
    echo "❌ PHPCS no instalado"
fi

if [ -f "node_modules/.bin/eslint" ]; then
    echo "✅ ESLint: $(npx eslint --version)"
else
    echo "❌ ESLint no instalado"
fi

echo "✅ Reinstalación completa"
```

## 📚 Documentación Adicional

<div align="center">

### 📖 **Recursos y Referencias**

</div>

<table>
<tr>
<td align="center" width="33%">

### 📋 **Archivos de Configuración**

- **[Makefile](Makefile)** - Todos los comandos disponibles
- **[package.json](package.json)** - Scripts NPM
- **[composer.json](composer.json)** - Scripts Composer

</td>
<td align="center" width="33%">

### 🔗 **Enlaces Útiles**

- [WordPress Coding Standards](https://developer.wordpress.org/coding-standards/)
- [PHP_CodeSniffer](https://github.com/squizlabs/PHP_CodeSniffer)
- [PHPStan](https://phpstan.org/)
- [ESLint](https://eslint.org/)

</td>
<td align="center" width="33%">

### 🛠️ **Herramientas**

- [Stylelint](https://stylelint.io/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Husky](https://typicode.github.io/husky/)
- [Lighthouse CI](https://github.com/GoogleChrome/lighthouse-ci)

</td>
</tr>
</table>

---

<div align="center">

### 🎯 **¿Te ha sido útil este proyecto?**

<a href="https://github.com/tu-usuario/wp-init/stargazers">
  <img src="https://img.shields.io/github/stars/tu-usuario/wp-init?style=social" alt="GitHub stars">
</a>
<a href="https://github.com/tu-usuario/wp-init/network/members">
  <img src="https://img.shields.io/github/forks/tu-usuario/wp-init?style=social" alt="GitHub forks">
</a>
<a href="https://github.com/tu-usuario/wp-init/issues">
  <img src="https://img.shields.io/github/issues/tu-usuario/wp-init" alt="GitHub issues">
</a>

**⭐ Dale una estrella si te ha ayudado** | **🐛 Reporta bugs** | **💡 Sugiere mejoras**

---

**Desarrollado con ❤️ para proyectos WordPress profesionales**

*© 2024 - Licencia GPL-2.0-or-later*

</div>
