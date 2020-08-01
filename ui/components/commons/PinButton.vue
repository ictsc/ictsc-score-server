<template>
  <v-btn icon v-bind="$attrs" v-on="$listeners">
    <v-icon v-if="value">mdi-pin</v-icon>
    <v-icon v-else>mdi-pin-outline</v-icon>
  </v-btn>
</template>
<script>
export default {
  name: 'LockButton',
  props: {
    value: {
      type: Boolean,
      required: true,
    },
  },
}
</script>
