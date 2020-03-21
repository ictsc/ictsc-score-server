<template>
  <v-btn v-bind="$attrs" x-small fab :color="color" v-on="$listeners">
    <v-icon size="2.2em">mdi-plus</v-icon>
  </v-btn>
</template>
<script>
export default {
  name: 'PlusButton',
  props: {
    color: {
      type: String,
      default: 'white'
    }
  }
}
</script>
