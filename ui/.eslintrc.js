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
    'quotes': ['error', 'single']
  },
  env: {
    browser: true,
  },
  globals: {
    'EventSource': 'off'
  },
}
