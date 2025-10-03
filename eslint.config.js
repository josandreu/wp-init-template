/**
 * ESLint configuration for WordPress project
 * Follows WordPress JavaScript Coding Standards
 *
 * @see https://eslint.org/docs/latest/use/configure/configuration-files
 * @see https://developer.wordpress.org/coding-standards/wordpress-coding-standards/javascript/
 */
import js from '@eslint/js';
import globals from 'globals';

export default [
  // Global ignores (applies to all configurations)
  {
    ignores: [
      'build/',
      'assets/build/',
      'node_modules/',
      'vendor/',
      'coverage/',
      'test-results/',
      'playwright-report/',
      'wordpress/wp-admin/',
      'wordpress/wp-includes/',
      'wordpress/wp-content/themes/!(flat101-starter-theme|my-project-theme)/',
      'wordpress/wp-content/plugins/!(my-project-custom-blocks|custom-cpt)/',
      'wordpress/wp-content/mu-plugins/!(flat101-base)/',
      '**/*.min.js',
      '**/*.min.css',
    ],
  },

  // Base configuration with WordPress rules
  {
    ...js.configs.recommended,

    languageOptions: {
      ecmaVersion: 2022,
      sourceType: 'module',
      parserOptions: {
        ecmaFeatures: {
          jsx: true,
        },
      },
      globals: {
        ...globals.browser,
        ...globals.node,
        ...globals.es2022,
        // WordPress globals
        wp: 'readonly',
        jQuery: 'readonly',
        $: 'readonly',
        // WordPress admin globals
        ajaxurl: 'readonly',
        pagenow: 'readonly',
        typenow: 'readonly',
        adminpage: 'readonly',
        // WordPress i18n functions
        __: 'readonly',
        _x: 'readonly',
        _n: 'readonly',
        _nx: 'readonly',
        _n_noop: 'readonly',
        _nx_noop: 'readonly',
        sprintf: 'readonly',
        // WordPress utility functions
        esc_attr: 'readonly',
        esc_html: 'readonly',
        esc_js: 'readonly',
        esc_url: 'readonly',
        // Block editor globals (if using Gutenberg)
        lodash: 'readonly',
        moment: 'readonly',
        React: 'readonly',
        ReactDOM: 'readonly',
      },
    },

    // Files to lint
    files: [
      'wordpress/wp-content/plugins/my-project-custom-blocks/src/**/*.{js,jsx,ts,tsx}',
      'wordpress/wp-content/themes/flat101-starter-theme/assets/src/**/*.{js,jsx,ts,tsx}',
      'wordpress/wp-content/themes/my-project-theme/assets/src/**/*.{js,jsx,ts,tsx}',
      '*.js',
      '*.jsx',
    ],

    rules: {
      // WordPress JavaScript Coding Standards - Critical Spacing Rules
      // These rules enforce the specific spacing requirements from WordPress docs:
      // https://developer.wordpress.org/coding-standards/wordpress-coding-standards/javascript/

      // CRITICAL: Spaces inside brackets: array = [ a, b ];
      'array-bracket-spacing': ['error', 'always'],

      // CRITICAL: Spaces inside parentheses: foo( arg );
      'space-in-parens': ['error', 'always'],

      // CRITICAL: Spaces inside object literal braces: { key: value }
      'object-curly-spacing': ['error', 'always'],

      // CRITICAL: Spaces around computed properties: object[ property ]
      'computed-property-spacing': ['error', 'always'],

      // Spaces around operators: a + b, a === b
      'space-infix-ops': 'error',

      // Spaces around keywords: if ( condition ) { ... }
      'keyword-spacing': ['error', { before: true, after: true }],

      // Spaces around function parameters: function foo( a, b ) { ... }
      'space-before-function-paren': [
        'error',
        {
          anonymous: 'always',
          named: 'never',
          asyncArrow: 'always',
        },
      ],

      // Spaces around blocks: if ( condition ) { ... }
      'space-before-blocks': 'error',

      // Spaces around colons in object properties: { key: value }
      'key-spacing': ['error', { beforeColon: false, afterColon: true }],

      // Spaces around commas: [ a, b, c ]
      'comma-spacing': ['error', { before: false, after: true }],

      // Spaces around semicolons: for ( i = 0; i < 10; i++ )
      'semi-spacing': ['error', { before: false, after: true }],

      // Spaces around unary operators: typeof value, ! condition
      'space-unary-ops': [
        'error',
        {
          words: true,
          nonwords: false,
          overrides: {
            '!': true,
            '++': false,
            '--': false,
          },
        },
      ],

      // WordPress naming conventions
      camelcase: ['error', { properties: 'never' }],

      // WordPress indentation (tabs, not spaces)
      indent: ['error', 'tab', { SwitchCase: 1 }],

      // WordPress quotes (single quotes)
      quotes: ['error', 'single', { avoidEscape: true }],

      // WordPress semicolons (always required)
      semi: ['error', 'always'],

      // WordPress trailing commas (ES5 compatible)
      'comma-dangle': ['error', 'always-multiline'],

      // Whitespace consistency
      'no-mixed-spaces-and-tabs': 'error',
      'no-trailing-spaces': 'error',
      'eol-last': 'error',

      // Code quality rules
      'no-console': ['warn', { allow: ['warn', 'error'] }],
      'no-unused-vars': ['error', { argsIgnorePattern: '^_', varsIgnorePattern: '^_' }],
      'prefer-const': 'error',
      'no-var': 'error',
      'no-undef': 'error',
      eqeqeq: ['error', 'always'],
      curly: ['error', 'all'],
      'no-eval': 'error',
      'no-implied-eval': 'error',
      'no-new-func': 'error',
      'no-alert': 'warn',
      'no-debugger': 'error',
      'no-duplicate-imports': 'error',
      'prefer-template': 'error',
    },
  },

  // Test files configuration
  {
    files: [
      '**/tests/**/*.{js,jsx,ts,tsx}',
      '**/*.test.{js,jsx,ts,tsx}',
      '**/*.spec.{js,jsx,ts,tsx}',
      '**/playwright.config.ts',
    ],
    languageOptions: {
      globals: {
        ...globals.jest,
        ...globals.node,
        // Test framework globals
        describe: 'readonly',
        it: 'readonly',
        test: 'readonly',
        expect: 'readonly',
        beforeEach: 'readonly',
        afterEach: 'readonly',
        beforeAll: 'readonly',
        afterAll: 'readonly',
        jest: 'readonly',
        __setNow: 'readonly',
      },
    },
    rules: {
      'no-console': 'off',
      'no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
    },
  },
];
