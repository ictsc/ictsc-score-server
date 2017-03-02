<template>
  <div id="app">
    <custom-header></custom-header>

    <div class="view">
      <div class="container">
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
        <button v-on:click="jumpLogin()" class="btn btn-secondary btn-lg">ログイン画面へ</button>
      </template>
    </message-box>
    <notif></notif>

  </div>
</template>

<script>
import CustomHeader from './components/Header'
import MessageBox from './components/MessageBox'
import Notif from './components/Notif'
import { Emit, Subscribe, AUTH_ERROR } from './utils/EventBus'
import { API } from './utils/Api'
import { SET_SESSION } from './store/'


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
    this.reloadSession();
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
    jumpLogin () {
      this.visibleAuthError = false;
      this.$router.push({ name: 'login' })
    },
    reloadSession () {
      console.log('reload session', SET_SESSION);
      API.getSession()
        .then(res => {
          this.$store.commit(SET_SESSION, res);

          // 未ログインかの判定
          if (res.status === 'logged_in') {
            setTimeout(() => this.reloadSession(), 1000 * 60);
          } else {
            Emit(AUTH_ERROR);
          }
        })
        .catch(err => {
          console.warn('session reload error', err);
        })
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
body, button, input, optgroup, select, textarea, svg text, .markdown-body > * {
  font-family: 游ゴシック Medium, YuGothic, YuGothic M,
    メイリオ, meiryo,
    Helvetica Neue, Helvetica, Arial, sans-serif;
}

h1, .h1, h2, .h2, h3, .h3, h4, .h4, h5, .h5, h6, .h6 {
  font-weight: bold;
}
h1, .h1 {
  font-size: 2.25rem;
  text-align: center;
}
h2, .h2 {
  font-size: 1.75rem;
}
h3, .h3 {
  font-size: 1.5rem;
}
h4, .h4 {
  font-size: 1.25rem;
}
h5, .h5 {
  font-size: 1rem;
}
h6, .h6 {
  font-size: .8rem;
}

.el-loading-mask {
    z-index: 1;
}

.form-group label {
    font-weight: bold;
    margin-bottom: 0.2rem;
}

.view {
  padding-top: 60px;
}
.view > div > div {
  padding: 30px 0px 90px 0px;
  overflow: hidden;
}
</style>
