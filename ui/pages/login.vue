<template>
  <div>
    <form @submit.prevent="try_login">
      <p>Login</p>

      <!-- TODO: 自動でフォーカスさせる -->
      <b-field label="Team name">
        <b-input
          v-model="name"
          type="name"
          placeholder="Your team name"
          required
        >
        </b-input>
      </b-field>

      <b-field label="Password">
        <b-input
          v-model="password"
          type="password"
          password-reveal
          placeholder="Your password"
          required
        >
        </b-input>
      </b-field>

      <button class="button is-primary">Login</button>
    </form>
  </div>
</template>

<script>
import { mapActions } from 'vuex'

export default {
  name: 'LoginPage',
  data() {
    return {
      name: '',
      password: ''
    }
  },
  methods: {
    ...mapActions('session', ['login']),
    async try_login() {
      if (await this.login({ name: this.name, password: this.password })) {
        this.$router.push('/')
      } else {
        // TODO: いい感じにエラー 表示する
      }
    }
  }
}
</script>
<style scoped lang="sass"></style>
