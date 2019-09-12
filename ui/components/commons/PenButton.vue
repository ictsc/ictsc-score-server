<template>
  <v-btn
    v-bind="$attrs"
    x-small
    fab
    color="white"
    elevation="2"
    v-on="$listeners"
  >
    <v-icon>mdi-pen</v-icon>
  </v-btn>
</template>
<script>
export default {
  name: 'PenButton'
}
</script>
