<template>
  <v-text-field
    v-bind="$attrs"
    height="1em"
    flat
    hide-details
    class="pt-1 candidate-field"
    v-on="$listeners"
  />
</template>
<script>
export default {
  name: 'NewCandidatesNarrowTextField',
}
</script>
<style scoped lang="sass">
.candidate-field
  width: none
  max-width: 30em
</style>
