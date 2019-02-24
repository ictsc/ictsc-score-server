module.exports = {
  root: true,
  parser: 'vue-eslint-parser',
  parserOptions: {
    sourceType: 'module'
  },
  // https://github.com/feross/standard/blob/master/RULES.md#javascript-standard-style
  extends: [
    'eslint:recommended',
    'plugin:vue/recommended'
  ],
  // add your custom rules here
  rules: {
    'quotes': ['error', 'single'],
    'no-console': 'off',
    'no-unused-vars': ['error', { 'argsIgnorePattern': '^_' }],
    'no-irregular-whitespace': 'off',
    'vue/order-in-components': 'off',
    'vue/require-default-prop': 'off',
    'vue/no-parsing-error': 'off'
  },
  env: {
    browser: true,
  },
  globals: {
    'EventSource': false
  },
}
