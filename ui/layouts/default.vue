<template>
  <v-app class="root-v-app">
    <navigation />
    <nuxt />
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
      this.$nuxt.$loading.start()
      // setTimeout(() => this.$nuxt.$loading.finish(), 500)

      if (await this.fetchCurrentSession()) {
        // TODO: エラーハンドリング
        await this.fetchContestInfo()
        this.$nuxt.$loading.finish()
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
.root-v-app
  background: white
</style>
