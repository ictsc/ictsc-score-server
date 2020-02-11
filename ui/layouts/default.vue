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
import { mapActions, mapGetters } from 'vuex'
import orm from '~/orm'
import Navigation from '~/components/misc/Navigation'
import NotificationArea from '~/components/misc/NotificationArea'

export default {
  components: {
    Navigation,
    NotificationArea
  },
  computed: {
    ...mapGetters('session', ['subscribeChannels'])
  },
  watch: {
    subscribeChannels(events) {
      this.$eventSource.subscribe(events, this.eventSourceOnMessage)
    }
  },
  created() {
    this.startInterval()
    this.$nextTick(async () => {
      // this.$nuxt.$loading.start()
      // setTimeout(() => this.$nuxt.$loading.finish(), 500)

      if (await this.fetchCurrentSession()) {
        await this.fetchContestInfo()
        // this.$nuxt.$loading.finish()
      } else {
        this.$router.push('/login')
      }
    })

    // 既にブロックされてたら尋ねない
    this.$push.Permission.request()
  },
  beforeDestroy() {
    this.stopInterval()
  },
  methods: {
    ...mapActions('time', ['startInterval', 'stopInterval']),
    ...mapActions('session', ['fetchCurrentSession']),
    ...mapActions('contestInfo', ['fetchContestInfo']),

    eventSourceOnMessage(data) {
      const timeout = 12000

      // URL判定して必要ならリロード
      orm.Queries.reloadRecords(this.$route.path, data.mutation, data.problemId)

      if (data.title) {
        if (this.$push.Permission.has()) {
          // TODO: linkはserviceWorker.jsがないとダメっぽい?
          //       focusはonClickでやればできる

          // tagは知通表示中なら重複を防げる
          this.$push.create(data.title, {
            body: data.body,
            tag: data.uuid,
            icon: '/favicon.png',
            timeout
          })
        } else {
          const message = data.title + '\n' + data.body
          this.notifyInfo({ message, timeout })
        }
      }
    }
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
