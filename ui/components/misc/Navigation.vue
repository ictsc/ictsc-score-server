<template>
  <v-app-bar app dense color="primary">
    <navigation-link to="/" active-class="">
      <v-img
        :src="require('~/assets/img/ictsc-logo-white.svg')"
        width="8em"
        alt="ICTSC"
      />
    </navigation-link>

    <v-spacer />

    <template v-for="nav in navigations">
      <navigation-link
        v-if="nav.if !== undefined ? nav.if : true"
        :key="nav.text || nav.icon"
        :to="nav.to"
        :always="nav.always !== undefined ? nav.always : false"
        @click="nav.click ? nav.click() : () => {}"
      >
        {{ nav.text }}
        <v-icon v-if="nav.icon">{{ nav.icon }}</v-icon>
      </navigation-link>
    </template>
  </v-app-bar>
</template>
<script>
import { mapActions } from 'vuex'
import NavigationLink from '~/components/misc/NavigationLink'

export default {
  name: 'Navigation',
  components: {
    NavigationLink
  },
  computed: {
    navigations() {
      return [
        { to: '/', text: 'トップ' },
        { to: '/guide', text: 'ガイド' },
        { to: '/teams', text: 'チーム' },
        { to: '/problems', text: '問題' },
        { to: '/issues', text: '質問' },
        { to: '/answers', text: '解答', if: this.isNotPlayer },
        { to: '/summary', text: '状況', if: false },
        { to: '/settings', icon: 'mdi-settings-outline', if: this.isStaff },
        {
          to: '/login',
          text: 'ログイン',
          if: this.isNotLoggedIn,
          always: true
        },
        {
          to: '/login',
          icon: 'mdi-exit-run',
          if: this.isLoggedIn,
          click: this.tryLogout
        }
      ]
    }
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
::v-deep
  .v-toolbar__content
    padding: 0px
</style>
