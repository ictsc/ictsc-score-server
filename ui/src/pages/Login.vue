<template>
  <div v-loading="asyncLoading">
    <div class="row justify-content-center">
      <div class="col-4">
        <h1>サインイン</h1>
        <form v-on:submit.prevent="submit()">
          <div class="form-group">
            <label for="input-member-id">メンバーID</label>
            <input v-model="login" type="text" class="form-control form-control-lg" id="input-member-id">
            <p class="form-text text-muted">We'll never share your email with anyone else.</p>
          </div>
          <div class="form-group">
            <label for="input-password">パスワード</label>
            <input v-model="pass" type="password" class="form-control form-control-lg" id="input-password">
          </div>
          <div class="form-group">
            <input type="submit" class="btn btn-success btn-lg btn-block" value="サインイン">
          </div>
          <p class="text-center"><router-link :to="{ name: 'signup' }">サインアップはこちら</router-link></p>
        </form>
      </div>
    </div>
  </div>
</template>

<style scoped>

</style>

<script>
import {
  SET_SESSION,
  SET_TITLE,
} from '../store/'
import { API } from '../utils/Api'
import {
  Emit,
  PUSH_NOTIF,
  REMOVE_NOTIF,
} from '../utils/EventBus'


export default {
  name: 'login',
  data () {
    return {
      login: '',
      pass: '',
    }
  },
  asyncData: {
    session () {
      return API.getSession()
    },
  },
  computed: {
  },
  watch: {
    session (val) {
      if (val.status === 'logged_in') {
        this.$router.push({ name: 'dashboard' })
      }
    },
  },
  mounted () {
    this.$store.dispatch(SET_TITLE, 'ログイン');
  },
  destroyed () {
  },
  methods: {
    async submit () {
      try {
        Emit(REMOVE_NOTIF, msg => msg.key === 'login');

        var res = await API.login(this.login, this.pass)
        console.log('login', res);
        if (res.status === 'failed') throw res;
        this.$router.push({ name: 'dashboard' })
        this.$store.commit(SET_SESSION, res);
        Emit(PUSH_NOTIF, {
          type: 'success',
          title: 'ログインしました',
          detail: '',
          key: 'login',
        });
      } catch (err) {
        console.log(err)
        Emit(PUSH_NOTIF, {
          type: 'error',
          title: 'ログインに失敗しました',
          detail: '',
          key: 'login',
        });
      }
    },
  },
}
</script>

