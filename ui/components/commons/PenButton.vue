<template>
  <v-btn v-bind="$attrs" x-small fab :color="color" v-on="$listeners">
    <v-icon size="2.2em">mdi-pen</v-icon>
  </v-btn>
</template>
<script>
export default {
  name: 'PenButton',
  props: {
    color: {
      type: String,
      default: 'white',
    },
  },
}
</script>
