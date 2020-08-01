<template>
  <v-icon v-if="opened" left>mdi-chevron-up</v-icon>
  <v-icon v-else left>mdi-chevron-down</v-icon>
</template>
<script>
export default {
  name: 'UpDownArrow',
  props: {
    opened: {
      type: Boolean,
      required: true,
    },
  },
}
</script>
