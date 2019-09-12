<template>
  <v-btn icon v-bind="$attrs" v-on="$listeners" @click="$emit('input', !value)">
    <v-icon v-if="value">mdi-lock</v-icon>
    <v-icon v-else>mdi-lock-open</v-icon>
  </v-btn>
</template>
<script>
export default {
  name: 'LockButton',
  props: {
    value: {
      type: Boolean,
      required: true
    }
  }
}
</script>
