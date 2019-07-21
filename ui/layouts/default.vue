<template>
  <v-app class="root-v-app">
    <navigation />
    <nuxt />
    <notification-area />
  </v-app>
</template>

<script>
import Navigation from '~/components/organisms/Navigation'
import NotificationArea from '~/components/organisms/NotificationArea'

export default {
  components: {
    Navigation,
    NotificationArea
  }
}
</script>
<style scoped lang="sass">
.root-v-app
  background: white
</style>
