<template>
  <v-icon v-if="opened" left>mdi-chevron-down</v-icon>
  <v-icon v-else left>mdi-chevron-up</v-icon>
</template>
<script>
export default {
  name: 'UpDownChevron',
  props: {
    opened: {
      type: Boolean,
      required: true
    }
  }
}
</script>
