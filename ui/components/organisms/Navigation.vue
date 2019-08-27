<template>
  <v-app-bar app dense color="primary">
    <navigation-link to="/">
      <img class="logo" src="~assets/img/ictsc-logo-white.svg" alt="ICTSC" />
    </navigation-link>

    <!-- TODO: 未実装なため隠す
    <navigation-link to="/teams">
      チーム
    </navigation-link>
    -->

    <v-spacer />

    <navigation-link to="/">
      お知らせ
    </navigation-link>

    <navigation-link to="/guide">
      ガイド
    </navigation-link>

    <navigation-link to="/problems">
      問題
    </navigation-link>

    <navigation-link to="/issues">
      質問
    </navigation-link>

    <template v-if="isStaff || isAudience">
      <navigation-link to="/answers">
        解答
      </navigation-link>
      <navigation-link to="/summary">
        状況
      </navigation-link>
    </template>

    <navigation-link v-if="isStaff" to="/settings">
      <v-icon>mdi-settings-outline</v-icon>
    </navigation-link>

    <navigation-link v-if="isNoLogin" to="/login">
      ログイン
    </navigation-link>
    <navigation-link v-else to="/login" @click="tryLogout">
      <v-icon>mdi-exit-run</v-icon>
    </navigation-link>
  </v-app-bar>
</template>
<script>
import { mapActions } from 'vuex'
import NavigationLink from '~/components/atoms/NavigationLink'

export default {
  name: 'Navigation',
  components: {
    NavigationLink
  },
  methods: {
    ...mapActions('session', ['logout']),

    async tryLogout() {
      if (await this.logout()) {
        this.notifySuccess({ message: 'ログアウトしました' })
      } else {
        this.notifyWarning({ message: 'ログインしていません' })
      }
    }
  }
}
</script>
<style scoped lang="sass">
.logo
  height: 2rem

::v-deep
  .v-toolbar__content
    padding: 0px
</style>
