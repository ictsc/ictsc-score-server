<template>
  <nav class="navbar is-primary" role="navigation" aria-label="main navigation">
    <div class="navbar-brand">
      <nuxt-link to="/" class="navbar-item">
        <img src="~assets/img/ictsc-logo-white.svg" alt="ICTSC" />
      </nuxt-link>

      <a
        role="button"
        class="navbar-burger burger"
        aria-label="menu"
        aria-expanded="false"
        data-target="navMenu"
      >
        <span aria-hidden="true"></span>
        <span aria-hidden="true"></span>
        <span aria-hidden="true"></span>
      </a>
    </div>

    <div id="navMenu" class="navbar-menu">
      <div class="navbar-start">
        <div class="navbar-item has-dropdown is-hoverable">
          <nuxt-link to="/guide" active-class="active" class="navbar-item">
            ガイド
          </nuxt-link>

          <nuxt-link to="/teams" active-class="active" class="navbar-item">
            チーム
          </nuxt-link>
        </div>
      </div>

      <div class="navbar-end">
        <div class="navbar-item has-dropdown is-hoverable is-expanded">
          <nuxt-link to="/" class="navbar-item">
            トップ
          </nuxt-link>
          <nuxt-link to="/problems" active-class="active" class="navbar-item">
            問題
          </nuxt-link>
          <nuxt-link to="/issues" active-class="active" class="navbar-item">
            質問
          </nuxt-link>

          <template v-if="isStaff || isAudience">
            <nuxt-link to="/answers" active-class="active" class="navbar-item">
              解答
            </nuxt-link>
            <nuxt-link to="/summary" active-class="active" class="navbar-item">
              状況
            </nuxt-link>
          </template>

          <a class="navbar-item" @click="logout">
            ログアウト
          </a>
        </div>
      </div>

      <b-modal :active.sync="isNoLogin" :can-cancel="false" has-modal-card>
        <login-modal />
      </b-modal>
    </div>
  </nav>
</template>

<style scoped lang="sass">
.navbar
  .navbar-brand
    img
      height: 2rem
.navbar-item
  color: #fff;
</style>

<script>
import { mapActions } from 'vuex'
import LoginModal from '~/components/molecules/LoginModal'

export default {
  name: 'Navigation',
  components: { LoginModal },
  methods: {
    ...mapActions('session', ['logout'])
  }
}
</script>
