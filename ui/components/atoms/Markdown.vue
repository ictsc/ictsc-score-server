<template>
  <!-- eslint-disable-next-line vue/no-v-html -->
  <div class="bottom-less" v-html="$md.render(content)"></div>
</template>
<script>
export default {
  name: 'Markdown',
  props: {
    content: {
      type: String,
      required: true
    }
  }
}
</script>
<style scoped lang="sass">
// 小要素にスタイルを適用するためdeep-selectを使っている
.bottom-less
  ::v-deep
    p
      margin-bottom: 0
</style>
