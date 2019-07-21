<template>
  <nav class="navbar is-primary" role="navigation" aria-label="">
    <div class="navbar-brand">
      <nuxt-link to="/" class="navbar-item">
        <img src="~assets/img/ictsc-logo-white.svg" alt="ICTSC" />
      </nuxt-link>

      <!-- TODO: 未実装 -->
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

    <div id="navMenu" class="navbar-menu primary">
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

          <nuxt-link
            v-if="isNoLogin"
            to="/login"
            active-class="active"
            class="navbar-item"
          >
            ログイン
          </nuxt-link>
          <a v-else class="navbar-item" @click="try_logout">
            ログアウト
          </a>
        </div>
      </div>
    </div>
  </nav>
</template>

<style scoped lang="sass">
.navbar
  .navbar-brand
    img
      height: 2rem
.navbar-item
  color: #fff
</style>

<script>
import { mapActions } from 'vuex'

export default {
  name: 'Navigation',
  fetch: {},
  mounted() {
    this.$nextTick(async () => {
      this.$nuxt.$loading.start()

      setTimeout(() => this.$nuxt.$loading.finish(), 500)

      if (await this.fetch_current_session()) {
        this.$nuxt.$loading.start()
      } else {
        this.$router.push('/login')
      }
    })
  },

  methods: {
    ...mapActions('session', ['logout', 'fetch_current_session']),

    async try_logout() {
      if (await this.logout()) {
        this.$router.push('/login')
      } else {
        // そもそもログインしてない場合にここに来る
        this.notifyError({ message: 'ログインしていません' })
        this.$router.push('/login')
      }
    }
  }
}
</script>
