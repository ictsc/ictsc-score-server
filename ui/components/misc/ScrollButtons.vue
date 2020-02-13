<template>
  <v-col align="center" class="floating-area-100 bottom pb-1">
    <div>
      <v-btn icon @click="scroll(0)">
        <v-icon large>mdi-arrow-up-circle-outline</v-icon>
      </v-btn>
    </div>

    <div>
      <v-btn icon @click="scroll(-1)">
        <v-icon large>mdi-arrow-down-circle-outline</v-icon>
      </v-btn>
    </div>
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
    }
  }
}
</script>
<style scoped lang="sass">
.bottom
  bottom: 0
</style>
