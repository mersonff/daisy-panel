import js from '@eslint/js'
import pluginVue from 'eslint-plugin-vue'

export default [
  js.configs.recommended,
  ...pluginVue.configs['flat/recommended'],
  {
    languageOptions: {
      ecmaVersion: 'latest',
      sourceType: 'module',
      globals: {
        window: 'readonly',
        document: 'readonly',
        console: 'readonly',
        fetch: 'readonly',
        FormData: 'readonly',
        setTimeout: 'readonly',
        clearTimeout: 'readonly',
        setInterval: 'readonly',
        clearInterval: 'readonly',
        Tempfile: 'readonly'
      }
    },
    rules: {
      'vue/html-self-closing': ['error', {
        html: {
          void: 'never',
          normal: 'always',
          component: 'always'
        },
        svg: 'always',
        math: 'always'
      }],
      'vue/max-attributes-per-line': ['error', {
        singleline: {
          max: 3
        },
        multiline: {
          max: 1
        }
      }],
      'vue/component-name-in-template-casing': ['error', 'PascalCase'],
      'vue/no-unused-vars': 'error',
      'no-console': 'warn',
      'no-unused-vars': 'error',
      'no-undef': 'error',
      'prefer-const': 'error',
      'no-var': 'error',
      'eqeqeq': 'error',
      'curly': 'error',
      'brace-style': ['error', '1tbs'],
      'comma-dangle': ['error', 'never'],
      'quotes': ['error', 'single'],
      'semi': ['error', 'never'],
      'indent': ['error', 2],
      'no-trailing-spaces': 'error',
      'eol-last': 'error'
    },
    files: [
      'app/frontend/**/*.js',
      'app/frontend/**/*.vue'
    ]
  },
  {
    ignores: [
      'node_modules/**',
      'public/**',
      'tmp/**',
      'log/**',
      'coverage/**'
    ]
  }
]