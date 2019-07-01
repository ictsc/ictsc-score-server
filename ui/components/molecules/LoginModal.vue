<template>
  <form @submit.prevent="submit">
    <div class="modal-card" style="width: auto">
      <header class="modal-card-head">
        <p class="modal-card-title">Login</p>
      </header>

      <!-- TODO: 自動でフォーカスさせる -->
      <section class="modal-card-body">
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
      </section>

      <footer class="modal-card-foot">
        <button class="button is-primary">Login</button>
      </footer>
    </div>
  </form>
</template>

<script>
import { mapActions } from 'vuex'

export default {
  name: 'LoginModal',
  data() {
    return {
      name: '',
      password: ''
    }
  },
  methods: {
    ...mapActions('session', ['login']),
    submit() {
      this.login({ name: this.name, password: this.password })
    }
  }
}
</script>
<style scoped></style>
