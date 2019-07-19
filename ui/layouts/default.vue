<template>
  <v-app>
    <Navigation />
    <nuxt />
  </v-app>
</template>

<script>
import Navigation from '~/components/organisms/Navigation'
export default {
  components: {
    Navigation
  }
}
</script>
