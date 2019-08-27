<template>
  <v-text-field
    v-bind="$attrs"
    flat
    maxlength="4"
    height="1em"
    :type="type"
    class="number-text-field"
    v-on="$listeners"
  />
</template>
<script>
export default {
  name: 'NumberTextField',
  props: {
    type: {
      type: String,
      default: 'number'
    }
  }
}
</script>
<style scoped lang="sass">
.number-text-field
  width: 4em
  ::v-deep
    input
      text-align: right
</style>
