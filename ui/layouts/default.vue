<template>
  <v-app>
    <navigation />
    <v-content>
      <!-- 最低幅を保証する -->
      <nuxt style="min-width: 500px" />
    </v-content>
    <notification-area />
  </v-app>
</template>
<script>
import { mapActions } from 'vuex'
import Navigation from '~/components/organisms/Navigation'
import NotificationArea from '~/components/organisms/NotificationArea'

export default {
  components: {
    Navigation,
    NotificationArea
  },
  created() {
    this.startInterval()
    this.$nextTick(async () => {
      // this.$nuxt.$loading.start()
      // setTimeout(() => this.$nuxt.$loading.finish(), 500)

      if (await this.fetchCurrentSession()) {
        // TODO: エラーハンドリング
        await this.fetchContestInfo()
        // this.$nuxt.$loading.finish()
      } else {
        this.$router.push('/login')
      }
    })
  },
  beforeDestroy() {
    this.stopInterval()
  },
  methods: {
    ...mapActions('time', ['startInterval', 'stopInterval']),
    ...mapActions('session', ['fetchCurrentSession']),
    ...mapActions('contestInfo', ['fetchContestInfo'])
  }
}
</script>
<style scoped lang="sass">
// アプリケーションの背景色を白にする
.v-application
  background: white !important
</style>
<style lang="sass">
html
  // 横スクロールを有効にする
  overflow-x: auto
  // 縦スクロールを必要に応じて表示する
  // overflow-y: auto
</style>
