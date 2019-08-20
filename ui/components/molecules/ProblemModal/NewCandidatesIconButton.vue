<template>
  <v-btn v-bind="$attrs" icon x-small class="mt-1" v-on="$listeners">
    <v-icon>{{ icon }}</v-icon>
  </v-btn>
</template>
<script>
export default {
  name: 'NewCandidatesIconButton',
  props: {
    icon: {
      type: String,
      required: true
    }
  }
}
</script>
