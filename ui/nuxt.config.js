export default {
  // ---- Nuxt標準の設定 ----
  mode: 'spa',
  server: {
    host: '0.0.0.0'
  },
  head: {
    title: 'ICTSC スコアサーバー',
    meta: [
      { charset: 'utf-8' },
      { name: 'viewport', content: 'width=device-width, initial-scale=1' },
      {
        hid: 'description',
        name: 'description',
        content: 'ICTSC スコアサーバー'
      }
    ],
    link: [{ rel: 'icon', type: 'image/x-icon', href: '/favicon.ico' }]
  },
  build: {
    // Extend webpack config
    extend(config, { isDev, isClient }) {
      // Vue dev toolが使えなくなる
      // config.devtool = 'eval-source-map'
    }
  },
  // Customize the progress-bar color
  // TODO: 必要? Vuetifyのプログレスバーとかに任せれば良い気がする
  loading: { color: '#fff' },
  plugins: [
    '~/plugins/axios',
    '~/plugins/elvis',
    '~/plugins/mixins',
    '~/plugins/vue-underscore',
    '~/plugins/vuex-orm'
  ],
  modules: [
    '@nuxtjs/vuetify',
    // 各コンポーネントでSASSの変数を手軽に共有する
    '@nuxtjs/style-resources',
    '@nuxtjs/axios',
    '@nuxtjs/proxy'
    // TODO: lint通らないと動作確認すらできない
    // '@nuxtjs/eslint-module',
  ],

  // ---- Nuxtモジュールの設定 ----
  axios: {
    // Docs: https://axios.nuxtjs.org/options
    prefix: '/api',
    proxy: true
  },
  proxy: {
    // TODO: 環境変数から取れるようにする?(本番構成決めてから)
    '/api': 'http://api:3000'
  },
  styleResources: {
    sass: ['~/assets/css/variables.sass']
  },
  vuetify: {
    customVariables: ['~/assets/css/variables.sass']
  }
}
