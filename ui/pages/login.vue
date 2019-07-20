<template>
  <v-container fluid column align-center justify-center fill-height>
    <v-form @submit.prevent="try_login">
      <v-text-field v-model="name" label="チーム名" required autofocus>
      </v-text-field>

      <v-text-field
        v-model="password"
        label="パスワード"
        required
        :type="passwordVisible ? 'text' : 'password'"
        :append-icon="passwordVisible ? 'mdi-eye' : 'mdi-eye-off'"
        @click:append="passwordVisible = !passwordVisible"
      >
      </v-text-field>

      <v-btn
        :disabled="!name || !password"
        :loading="loading"
        type="submit"
        color="success"
        block
      >
        ログイン
      </v-btn>
    </v-form>
  </v-container>
</template>

<script>
import { mapActions } from 'vuex'

export default {
  name: 'LoginPage',
  data() {
    return {
      name: '',
      password: '',
      passwordVisible: false,
      loading: false
    }
  },
  methods: {
    ...mapActions('session', ['login']),
    async try_login() {
      this.loading = true

      if (await this.login({ name: this.name, password: this.password })) {
        this.$router.push('/')
      } else {
        this.notifyError({ message: 'ログインに失敗しました' })
      }

      this.loading = false
    }
  }
}
</script>
<style scoped lang="sass"></style>
