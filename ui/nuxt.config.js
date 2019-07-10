export default {
  mode: 'spa',
  server: {
    host: '0.0.0.0'
  },
  /*
   ** Headers of the page
   */
  head: {
    title: process.env.npm_package_name || '',
    meta: [
      { charset: 'utf-8' },
      { name: 'viewport', content: 'width=device-width, initial-scale=1' },
      {
        hid: 'description',
        name: 'description',
        content: process.env.npm_package_description || ''
      }
    ],
    link: [{ rel: 'icon', type: 'image/x-icon', href: '/favicon.ico' }]
  },
  /*
   ** Customize the progress-bar color
   */
  loading: { color: '#fff' },
  /*
   ** Global CSS
   */
  css: [],
  styleResources: {
    sass: ['~/assets/css/variables.sass']
  },
  /*
   ** Plugins to load before mounting the App
   */
  plugins: [
    '~/plugins/axios',
    '~/plugins/elvis',
    '~/plugins/session-utils',
    '~/plugins/vue-underscore',
    '~/plugins/vuex-orm'
  ],
  /*
   ** Nuxt.js modules
   */
  modules: [
    '@nuxtjs/vuetify',
    // 各コンポーネントでSASSの変数を手軽に共有する
    '@nuxtjs/style-resources',
    // Doc: https://axios.nuxtjs.org/usage
    '@nuxtjs/axios',
    // TODO: lint通らないと動作確認すらできない
    // '@nuxtjs/eslint-module',
    '@nuxtjs/proxy'
  ],
  /*
   ** Axios module configuration
   ** See https://axios.nuxtjs.org/options
   */
  axios: {
    prefix: '/api',
    proxy: true
  },
  proxy: {
    // TODO:
    '/api': 'http://api:3000'
  },
  /*
   ** Build configuration
   */
  build: {
    /*
     ** You can extend webpack config here
     */
    extend(config, { isDev, isClient }) {
      // TODO: Vue dev toolが使えなくなる
      // config.devtool = 'eval-source-map'
    }
  },
  vuetify: {
    // TODO: 未調整
    customVariables: ['~/assets/css/variables.sass']
  }
}
