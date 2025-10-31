# WordPress Init Project - Templates

Este directorio contiene las plantillas (templates) que utiliza el script `init-project.sh` para generar los archivos de configuración del proyecto.

## 📋 Archivos de Template Disponibles

### Configuración de Linting y Análisis

- **`phpcs.xml.dist.template`** - Configuración de PHP CodeSniffer
- **`phpstan.neon.dist.template`** - Configuración de PHPStan
- **`eslint.config.js.template`** - Configuración de ESLint

### Gestión de Dependencias

- **`package.json.template`** - Dependencias y scripts de Node.js/npm
- **`composer.json.template`** - Dependencias y scripts de PHP/Composer

### Configuración de VSCode

- **`vscode-settings.json.template`** - Configuración del editor VSCode
- **`vscode-extensions.json.template`** - Extensiones recomendadas para VSCode
- **`wp.code-workspace.template`** - Workspace multi-carpeta de VSCode

## 🔧 Variables de Reemplazo

Las templates utilizan marcadores que el script reemplaza automáticamente con valores específicos del proyecto:

### Variables Estáticas

| Variable | Descripción | Ejemplo |
|----------|-------------|---------|
| `{{PROJECT_NAME}}` | Nombre del proyecto (capitalizado) | "Mi Proyecto" |
| `{{PROJECT_SLUG}}` | Slug del proyecto (kebab-case) | "mi-proyecto" |
| `{{PROJECT_CONSTANT}}` | Constante del proyecto (UPPER_SNAKE_CASE) | "MI_PROYECTO" |
| `{{WP_CONTENT_DIR}}` | Ruta al directorio wp-content | "wordpress/wp-content" |
| `{{WP_CONTENT_DIR_PARENT}}` | Ruta al directorio padre de wp-content | "wordpress" |

### Variables Dinámicas (generadas por el script)

Estas variables se construyen dinámicamente según los plugins, temas y mu-plugins seleccionados:

| Variable | Descripción | Ejemplo |
|----------|-------------|---------|
| `{{PREFIXES}}` | Lista de prefijos para PHP CodeSniffer | Lista de elementos XML |
| `{{TEXT_DOMAINS}}` | Dominios de texto para i18n | Lista de elementos XML |
| `{{FILES}}` | Rutas de archivos a analizar | Lista de elementos XML `<file>` |
| `{{PATHS}}` | Rutas para PHPStan | Lista YAML de rutas |
| `{{EXCLUDES}}` | Rutas a excluir en PHPStan | Lista YAML de exclusiones |
| `{{ESLINT_FILES}}` | Archivos JavaScript para ESLint | Lista de globs JS |
| `{{WORKSPACE_FOLDERS}}` | Carpetas del workspace de VSCode | Objetos JSON de folders |

## ✏️ Cómo Modificar las Templates

### 1. Editar una Template Existente

Simplemente edita el archivo template que quieras modificar. Por ejemplo, para cambiar el nivel de análisis de PHPStan:

```yaml
# templates/phpstan.neon.dist.template
parameters:
  level: 8  # Cambiado de 5 a 8 para análisis más estricto
  ...
```

### 2. Añadir Nuevas Reglas de Linting

Para añadir una nueva regla de ESLint:

```javascript
// templates/eslint.config.js.template
rules: {
  // ... reglas existentes ...
  'no-console': ['error', { allow: ['warn', 'error', 'info'] }],  // Nueva regla
}
```

### 3. Modificar Dependencias

Para actualizar una versión de dependencia:

```json
// templates/package.json.template
"devDependencies": {
  "@eslint/js": "^10.0.0",  // Actualizado de ^9.9.0
  ...
}
```

### 4. Personalizar Configuración de VSCode

Para añadir nuevas configuraciones del editor:

```json
// templates/vscode-settings.json.template
{
  "editor.rulers": [120],
  "editor.minimap.enabled": false,  // Nueva configuración
  ...
}
```

## 🔄 Aplicar los Cambios

Una vez modificadas las templates, los cambios se aplicarán automáticamente la próxima vez que ejecutes el script:

```bash
./init-project.sh /path/to/wordpress 1
```

**Nota**: Las templates se usan en los modos 1, 2 y 4 del script.

## 📂 Estructura de Variables por Template

### phpcs.xml.dist.template
- `{{PREFIXES}}` - Se genera a partir de los nombres de plugins/temas
- `{{TEXT_DOMAINS}}` - Se genera a partir de los nombres de plugins/temas
- `{{FILES}}` - Se genera con las rutas de plugins/temas/mu-plugins seleccionados
- `{{WP_CONTENT_DIR_PARENT}}` - Directorio padre de wp-content

### phpstan.neon.dist.template
- `{{PATHS}}` - Rutas de los componentes seleccionados
- `{{EXCLUDES}}` - Directorios a excluir (build, vendor, node_modules)
- `{{WP_CONTENT_DIR_PARENT}}` - Directorio padre de wp-content

### eslint.config.js.template
- `{{ESLINT_FILES}}` - Globs de archivos JS/TS en los componentes seleccionados

### package.json.template
- `{{PROJECT_SLUG}}` - Nombre del paquete npm

### composer.json.template
- `{{PROJECT_SLUG}}` - Nombre del paquete composer

### wp.code-workspace.template
- `{{WORKSPACE_FOLDERS}}` - Folders de los componentes seleccionados

### vscode-settings.json.template y vscode-extensions.json.template
- No usan variables, se copian directamente

## 🛠️ Ventajas de Usar Templates

1. **Actualización Fácil**: Modifica una vez, aplica a todos los proyectos futuros
2. **Versionado**: Los cambios en templates se rastrean en Git
3. **Consistencia**: Todos los proyectos usan la misma configuración base
4. **Mantenibilidad**: El código del script es más limpio y corto
5. **Documentación**: Las templates son auto-documentables

## ⚠️ Consideraciones Importantes

- **Sintaxis**: Mantén la sintaxis correcta del formato de cada archivo (XML, YAML, JSON, JS)
- **Variables**: No elimines las variables `{{...}}` a menos que sepas lo que haces
- **Formato**: Respeta la indentación y formato de cada tipo de archivo
- **Pruebas**: Después de modificar una template, prueba el script en un proyecto de prueba

## 🔍 Resolución de Problemas

### La template no se encuentra
- Verifica que el archivo existe en `templates/`
- Verifica que el nombre coincide exactamente (incluyendo extensión)

### Variables no se reemplazan
- Verifica que usas la sintaxis correcta: `{{VARIABLE}}`
- Comprueba que la variable existe en el script

### Errores de sintaxis en el archivo generado
- Revisa el formato de la template
- Verifica que no hayas roto la estructura al editar

## 📚 Recursos Adicionales

- [PHP CodeSniffer Documentation](https://github.com/squizlabs/PHP_CodeSniffer/wiki)
- [PHPStan Documentation](https://phpstan.org/user-guide/getting-started)
- [ESLint Documentation](https://eslint.org/docs/latest/)
- [VSCode Settings Reference](https://code.visualstudio.com/docs/getstarted/settings)

## 🤝 Contribuir

Si mejoras alguna template o creas una nueva, considera:
1. Documentar los cambios en este README
2. Probar en múltiples proyectos
3. Crear un commit descriptivo
