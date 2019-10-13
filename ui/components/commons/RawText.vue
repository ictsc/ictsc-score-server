<template>
  <v-textarea
    :value="content"
    auto-grow
    solo
    flat
    hide-details
    readonly
    dense
    class="pa-0 ma-0 shrink-side-slot shrink-top"
  />
</template>
<script>
export default {
  name: 'RawText',
  props: {
    content: {
      type: String,
      required: true
    }
  }
}
</script>
<style scoped lang="sass">
// v-textareaの余分な余白を消す
.shrink-side-slot
  ::v-deep
    div
      .v-input__slot
        padding: 0 0 !important

.shrink-top
  ::v-deep
    textarea
      padding-top: 0 !important
      margin-top: 0 !important
</style>
