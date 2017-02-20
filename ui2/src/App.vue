<template>
  <div id="app">
    <custom-header></custom-header>

    <div class="view">
      <div class="container-fluid">
        <!--<transition name="fade" mode="out-in">-->
          <router-view></router-view>
        <!--</transition>-->
      </div>
    </div>

    <message-box v-model="visibleAuthError">
      <span slot="title">エラー</span>
      <div slot="body">
        <p>
          セッション情報の取得に失敗しました。
          再度ログインをお願いします
        </p>
      </div>
      <template slot="buttons" scope="props">
        <a class="btn btn-secondary btn-lg">TODO ログイン画面へ</a>
      </template>
    </message-box>
    <notif></notif>

  </div>
</template>

<script>
import CustomHeader from './components/Header'
import MessageBox from './components/MessageBox'
import Notif from './components/Notif'
import { Subscribe, AUTH_ERROR } from './utils/EventBus'

export default {
  name: 'app',
  components: {
    CustomHeader,
    MessageBox,
    Notif,
  },
  watch: {
  },
  data () {
    return {
      authError: Subscribe(AUTH_ERROR, e => this.authErrorHandler(e)),
      visibleAuthError: false,
    }
  },
  mounted () {
  },
  beforeDestroy () {
    this.authError.off();
  },
  computed: {
  },
  methods: {
    authErrorHandler (e) {
      this.visibleAuthError = true;
    },
  }
}
</script>

<style scoped>
.fade-enter-active, .fade-leave-active {
  transition: opacity 300ms ease;
}
.fade-enter, .fade-leave-to {
  opacity: 0;
}
</style>

<style>
/* Global Styles */

html {
  font-size: 14px;
}
body {
  color: #47475D;
  min-width: 900px;
}
body, button, input, optgroup, select, textarea, svg text {
  font-family: 游ゴシック Medium, YuGothic, YuGothic M,
    メイリオ, meiryo,
    Helvetica Neue, Helvetica, Arial, sans-serif;
}

.view {
  padding-top: 60px;
}
.view > div > .sites-hidden {
  padding: 30px 30px 90px 30px;
  padding-left: 100px;
}
.view > div > div {
  padding: 30px 0px 90px 350px;
  overflow: hidden;
}
</style>
