<template>
  <form @submit.prevent="login">
    <div class="modal-card" style="width: auto">
      <header class="modal-card-head">
        <p class="modal-card-title">Login</p>
      </header>

      <section class="modal-card-body">
        <b-field label="Team name">
          <b-input
            type="name"
            v-model="name"
            placeholder="Your team name"
            required
          >
          </b-input>
        </b-field>

        <b-field label="Password">
          <b-input
            type="password"
            v-model="password"
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
export default {
  name: 'LoginModal',
  data() {
    return {
      name: '',
      password: ''
    }
  },
  methods: {
    login() {
      console.log(`login with ${this.name}:${this.password}`);
      return true
    }
  }
}
</script>
<style scoped></style>
