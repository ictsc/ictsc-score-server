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
    // 各コンポーネントでSASSの変数を手軽に共有する TODO: 廃止予定
    '@nuxtjs/style-resources',
    '@nuxtjs/axios',
    '@nuxtjs/markdownit',
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
  markdownit: {
    // Docs: https://github.com/markdown-it/markdown-it
    preset: 'default',
    linkify: true,
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
      'markdown-it-sanitizer',
      // TeX
      '@iktakahiro/markdown-it-katex'
    ]
  },
  proxy: {
    // TODO: 環境変数から取れるようにする?(本番構成決めてから)
    '/api': 'http://api:3000'
  },
  // TODO: 廃止予定
  styleResources: {
    sass: ['~/assets/css/variables.sass']
  },
  vuetify: {
    customVariables: ['~/assets/css/variables.sass'],
    theme: {
      themes: {
        light: {
          primary: '#ed1848'
        }
      }
    }
  }
}
