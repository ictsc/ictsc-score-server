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
    this.timeStartInterval()
  },
  beforeDestroy() {
    this.timeStopInterval()
  },
  methods: {
    ...mapActions('time', {
      timeStartInterval: 'startInterval',
      timeStopInterval: 'stopInterval'
    })
  }
}
</script>
<style scoped lang="sass">
.root-v-app
  background: white
</style>
