<template>
  <!-- eslint-disable-next-line vue/no-v-html -->
  <div class="markdown" v-html="$md.render(content)"></div>
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
.markdown
  ::v-deep
    // 余分な余白を消す
    p
      margin-bottom: 0
    // テーブル表示をGitHub風にする
    table
      border-collapse: collapse
      th, td
        border: 1px solid #dfe2e5
        padding: 6px
      tr
        &:nth-child(2n)
          background-color: #f6f8fa
    // `` でのみ影を消す
    &:not(pre)
      code
        box-shadow: none
    pre
      code
        // なぜかコードの先頭に文字が入る
        &:before
          content: ""
</style>
