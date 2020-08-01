<template>
  <v-col align="center">
    <v-btn fixed bottom icon class="white bottom-up" @click="scroll(0)">
      <v-icon large>mdi-arrow-up-circle-outline</v-icon>
    </v-btn>

    <v-btn fixed bottom icon class="white" @click="scroll(-1)">
      <v-icon large>mdi-arrow-down-circle-outline</v-icon>
    </v-btn>
  </v-col>
</template>
<script>
export default {
  name: 'ScrollButtons',
  methods: {
    scroll(number) {
      if (number === -1) {
        number = window.document.body.scrollHeight
      }

      this.$vuetify.goTo(number, { duration: 150 })
    },
  },
}
</script>
<style scoped lang="sass">
.bottom-up
  bottom: 52px
</style>
