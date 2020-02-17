export default {
  // ---- Nuxt標準の設定 ----
  mode: 'spa',
  server: {
    host: '0.0.0.0'
  },
  head: {
    title: 'スコアサーバー',
    titleTemplate: '%s | ICTSC',
    meta: [
      { charset: 'utf-8' },
      { name: 'viewport', content: 'width=device-width, initial-scale=1' },
      {
        hid: 'description',
        name: 'description',
        content: 'ICTSC スコアサーバー'
      }
    ],
    link: [{ rel: 'icon', type: 'image/png', href: '/favicon.png' }]
  },
  css: ['~/assets/css/commons.sass'],
  build: {
    // Extend webpack config
    extend(config, { isDev, isClient }) {
      // Vue dev toolが使えなくなる
      // config.devtool = 'eval-source-map'
    }
  },
  loading: false,
  plugins: [
    '~/plugins/axios',
    '~/plugins/elvis',
    '~/plugins/eventsource',
    '~/plugins/json-storage',
    '~/plugins/mixins',
    '~/plugins/moment-update-locale',
    '~/plugins/push',
    '~/plugins/vue-clipboard',
    '~/plugins/vue-underscore',
    '~/plugins/vuex-orm'
  ],
  modules: ['@nuxtjs/axios', '@nuxtjs/markdownit', '@nuxtjs/proxy'],
  buildModules: ['@nuxtjs/moment', '@nuxtjs/vuetify'],

  // ---- Nuxtモジュールの設定 ----
  axios: {
    // Docs: https://axios.nuxtjs.org/options
    prefix: '/api',
    proxy: true
  },
  markdownit: {
    // Docs: https://github.com/markdown-it/markdown-it
    preset: 'default',
    linkify: true,
    // スペース2つだけでなく、通常の改行でも開業するようになる
    breaks: true,
    // $mdを使えるようにする
    injected: true,
    use: [
      // マウスオーバーで正式名称を表示
      'markdown-it-abbr',
      // 絵文字:thinking_face:
      'markdown-it-emoji',
      // 補足を最下部に生成
      'markdown-it-footnote',
      // サニタイズ
      'markdown-it-sanitizer'
    ]
  },
  moment: {
    locales: ['es-us', 'ja']
  },
  proxy: {
    // 開発時のyarn run devなど、jsでリクエストを受けている場合に使う
    // 本番環境では前段のLBでリクエストを振り分ける
    '/api': 'http://api:3000',
    '/push': 'http://push:8080'
  },
  vuetify: {
    // customVariables: ['~/assets/css/variables.sass'],
    theme: {
      themes: {
        light: {
          primary: '#e40046'
        }
      }
    }
  }
}
