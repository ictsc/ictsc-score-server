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
  css: ['~/assets/css/_buefy.sass'],
  styleResources: {
    sass: ['~/assets/css/_buefy.sass']
  },
  /*
   ** Plugins to load before mounting the App
   */
  plugins: [
    '~/plugins/elvis',
    '~/plugins/session-utils',
    '~/plugins/vue-underscore',
    '~/plugins/vuex-orm'
  ],
  /*
   ** Nuxt.js modules
   */
  modules: [
    // Doc: https://buefy.github.io/#/documentation
    ['nuxt-buefy', { css: false }],
    // 各コンポーネントでSASSの変数を手軽に共有する
    '@nuxtjs/style-resources',
    // GrphQLクライアント
    '@nuxtjs/apollo',
    // Doc: https://axios.nuxtjs.org/usage
    '@nuxtjs/axios',
    // TODO: lint通らないと動作確認すらできない
    // '@nuxtjs/eslint-module',
    '@nuxtjs/proxy'
  ],
  apollo: {
    errorHandler: '~/plugins/apollo-error-handler.js',
    clientConfigs: {
      default: {
        // required
        // TODO:
        httpEndpoint: 'http://localhost:8901/api/graphql',
        // optional
        // See https://www.apollographql.com/docs/link/links/http.html#options
        // TODO:
        httpLinkOptions: {
          credentials: 'same-origin'
        },
        // Enable Automatic Query persisting with Apollo Engine
        persisting: false
      }
    }
  },
  /*
   ** Axios module configuration
   ** See https://axios.nuxtjs.org/options
   */
  axios: {
    proxy: true
  },
  proxy: {
    '/api': {
      // TODO:
      target: 'http://api:3000'
    }
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
  }
}
