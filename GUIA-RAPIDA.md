# 🚀 Guía Rápida de Uso

## ¿Qué archivos necesito?

**TODO el repositorio `wp-init/`**

El script necesita leer los archivos de configuración para copiarlos a tu proyecto.

```bash
# Clona TODO el repositorio
git clone https://github.com/tu-usuario/wp-init.git
```

## ¿Qué modo usar?

### 🆕 Caso 1: Proyecto Nuevo

**Tienes**: Nada, vas a empezar desde cero

**Usa**: Modo 1️⃣

```bash
cd wp-init/
./init-project.sh
# Selecciona: 1
```

---

### 🔄 Caso 2: Cambiar Referencias

**Tienes**: Proyecto de "cliente-a", quieres adaptarlo para "cliente-b"

**Usa**: Modo 2️⃣

```bash
cd /tu/proyecto-cliente-a
/ruta/a/wp-init/init-project.sh
# Selecciona: 2
```

---

### 🔧 Caso 3: Actualizar Reglas

**Tienes**: Proyecto configurado, solo quieres actualizar reglas de linting

**Usa**: Modo 3️⃣

```bash
cd /tu/proyecto
/ruta/a/wp-init/init-project.sh
# Selecciona: 3
```

---

### ⭐ Caso 4: Añadir Estándares (MÁS COMÚN)

**Tienes**: Proyecto WordPress con `package.json` y `composer.json` propios

**Quieres**: Añadir linting WordPress SIN perder tu configuración

**Usa**: Modo 4️⃣

```bash
# 1. Instalar jq (IMPORTANTE)
brew install jq

# 2. Ejecutar desde tu proyecto
cd /tu/proyecto-wordpress
/ruta/a/wp-init/init-project.sh
# Selecciona: 4

# 3. Instalar nuevas dependencias
npm install
composer install

# 4. Listo!
npm run lint:js
npm run lint:php
```

## 📦 Resumen de Archivos

### Lo que está en `wp-init/` (plantilla)

```
wp-init/
├── init-project.sh          ← Script principal
├── package.json             ← Template de referencia
├── composer.json            ← Template de referencia
├── phpcs.xml.dist           ← Config WordPress PHP
├── eslint.config.js         ← Config WordPress JS
├── phpstan.neon.dist        ← Config análisis PHP
└── commitlint.config.cjs    ← Config commits
```

### Lo que se copia a tu proyecto

**Modo 1, 2, 3**:
- ✅ Todos los archivos de configuración
- ✅ package.json actualizado
- ✅ composer.json actualizado

**Modo 4 (con jq)**:
- ✅ Archivos de configuración (phpcs, eslint, etc.)
- ✅ package.json **fusionado** (tus scripts + scripts de linting)
- ✅ composer.json **fusionado** (tus deps + deps de linting)
- ✅ Backups: `package.json.backup`, `composer.json.backup`

**Modo 4 (sin jq)**:
- ✅ Archivos de configuración copiados
- 📄 `package.json.additions` - Lo que debes copiar manualmente
- 📄 `composer.json.additions` - Lo que debes copiar manualmente

## ⚡ Flujo Recomendado

### Para Proyecto Existente (Caso 4)

```bash
# PASO 1: Clona la plantilla (una sola vez)
cd ~/plantillas
git clone https://github.com/tu-usuario/wp-init.git

# PASO 2: Instala jq (una sola vez)
brew install jq

# PASO 3: Ve a tu proyecto
cd /Users/tu-usuario/Sites/tu-proyecto-wordpress

# PASO 4: Ejecuta el script
~/plantillas/wp-init/init-project.sh

# PASO 5: Selecciona modo 4
# Presiona: 4

# PASO 6: El script hará todo automáticamente
# - Copia archivos de config
# - Fusiona package.json (backup automático)
# - Fusiona composer.json (backup automático)
# - Añade scripts de linting

# PASO 7: Instala dependencias
npm install
composer install

# PASO 8: Configura hooks
npm run prepare

# PASO 9: ¡Listo! Prueba los comandos
npm run lint:js
npm run lint:php
npm run format:all
```

## ✅ Verificación

Después de ejecutar el script, deberías tener:

```bash
# Archivos nuevos
ls -la
# phpcs.xml.dist ✅
# eslint.config.js ✅
# phpstan.neon.dist ✅
# commitlint.config.cjs ✅

# Backups (Modo 4)
# package.json.backup ✅
# composer.json.backup ✅

# Comandos disponibles
npm run lint:js       # ✅
npm run lint:php      # ✅
npm run format:all    # ✅
```

## 🆘 Troubleshooting

### "jq: command not found"

```bash
brew install jq  # macOS
apt-get install jq  # Linux
```

### "Script not found"

Usa la ruta completa al script:

```bash
/Users/tu-usuario/plantillas/wp-init/init-project.sh
```

### "Mis scripts desaparecieron"

Si usaste Modo 4, están en el backup:

```bash
cp package.json.backup package.json
```

### "No se instalaron las dependencias"

```bash
npm install
composer install
```

## 💡 Tips

1. **Siempre usa Modo 4** si ya tienes un proyecto en marcha
2. **Instala jq** para merge automático
3. **Revisa los backups** antes de commitear
4. **Ejecuta `npm run lint:js`** para probar que funciona
5. **Guarda la plantilla** en `~/plantillas/` para reusar

## 📞 Soporte

Ver documentación completa: [README.md](README.md)
