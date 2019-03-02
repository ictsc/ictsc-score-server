<template>
  <div>
    <div class="row justify-content-center">
      <div class="col-4">
        <h1>サインアップ</h1>
        <div class="form-group">
          <label for="input-name">氏名</label>
          <input
            id="input-name"
            v-model="name"
            type="text"
            class="form-control form-control-lg"
          >
        </div>
        <div class="form-group">
          <label for="input-register-code">登録コード</label>
          <input
            id="input-register-code"
            v-model="registration_code"
            type="text"
            class="form-control form-control-lg"
          >
        </div>
        <div class="form-group">
          <label for="input-org">所属とチーム</label>
          <input
            id="input-org"
            :value="teamName"
            type="text"
            class="form-control form-control-lg"
            readonly
          >
        </div>
        <div class="form-group">
          <label for="input-member-id">メンバーID</label>
          <input
            id="input-member-id"
            v-model="login"
            type="text"
            class="form-control form-control-lg"
          >
        </div>
        <div class="form-group">
          <label for="input-password">パスワード</label>
          <input
            id="input-password"
            v-model="password"
            type="password"
            class="form-control form-control-lg"
          >
        </div>
        <div class="form-group">
          <button
            v-on:click="submit()"
            type="button"
            class="btn btn-success btn-lg btn-block"
          >
            サインアップ
          </button>
        </div>
        <p class="text-center">
          <router-link :to="{ name: 'login' }">
            ログインはこちら
          </router-link>
        </p>
      </div>
    </div>
  </div>
</template>

<style>

</style>

<script>
import { SET_TITLE } from '../store/'
import { API } from '../utils/Api'
import { Emit, PUSH_NOTIF, REMOVE_NOTIF } from '../utils/EventBus'
import sha1 from 'sha1'

export default {
  name: 'Empty',
  data () {
    return {
      login: '',
      name: '',
      password: '',
      registration_code: '',
    }
  },
  computed: {
    teamName () {
      var team = this.teams.find(t => t.hashed_registration_code === sha1(this.registration_code));
      if (team) return team.name;
      else return '-----';
    },
  },
  watch: {
  },
  asyncData: {
    teamsDefault: [],
    teams () {
      return API.getTeams();
    },
  },
  mounted () {
    this.$store.dispatch(SET_TITLE, 'サイト一覧');
  },
  destroyed () {
  },
  methods: {
    async submit () {
      Emit(REMOVE_NOTIF, msg => msg.key === 'login');
      try {
        await API.postMembers(this.login, this.name, this.password, this.registration_code);
        Emit(PUSH_NOTIF, {
          type: 'success',
          title: 'アカウントを作成しました',
          detail: '',
          key: 'login',
        });
        this.$router.push({ name: 'login' })
      } catch (err) {
        console.error(err);
        Emit(PUSH_NOTIF, {
          type: 'error',
          title: 'アカウント作成に失敗しました',
          detail: '',
          key: 'login',
        });
      }
    }
  },
}
</script>

