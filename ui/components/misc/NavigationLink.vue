<template>
  <v-btn
    :to="to"
    :disabled="isNotLoggedIn && !always"
    nuxt
    text
    height="100%"
    class="white--text"
    @click="$emit('click')"
  >
    <slot />
  </v-btn>
</template>
<script>
export default {
  name: 'NavigationLink',
  props: {
    to: {
      type: String,
      required: true
    },
    always: {
      type: Boolean,
      default: false
    }
  }
}
</script>
