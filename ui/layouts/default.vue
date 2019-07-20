<template>
  <v-app>
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
