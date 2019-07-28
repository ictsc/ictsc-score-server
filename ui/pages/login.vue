<template>
  <v-container fluid column align-center justify-center fill-height>
    <v-form v-model="valid" @submit.prevent="submit">
      <v-text-field
        v-model="name"
        :rules="nameRules"
        label="チーム名"
        required
        autofocus
      >
      </v-text-field>

      <v-text-field
        v-model="password"
        label="パスワード"
        required
        :rules="passwordRules"
        :type="passwordVisible ? 'text' : 'password'"
        :append-icon="passwordVisible ? 'mdi-eye' : 'mdi-eye-off'"
        @click:append="passwordVisible = !passwordVisible"
      >
      </v-text-field>

      <v-btn
        :disabled="!valid"
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
      valid: false,
      name: '',
      password: '',
      passwordVisible: false,
      loading: false,
      nameRules: [v => !!v || 'チーム名を入力してください'],
      passwordRules: [v => !!v || 'パスワードを入力してください']
    }
  },
  methods: {
    ...mapActions('session', ['login']),
    async submit() {
      this.loading = true

      if (await this.login({ name: this.name, password: this.password })) {
        this.notifySuccess({ message: 'ログインしました' })
        this.$router.push('/')
      } else {
        this.notifyWarning({
          message: 'チーム名かパスワードが正しくありません'
        })
      }

      this.loading = false
    }
  }
}
</script>
<style scoped lang="sass"></style>
