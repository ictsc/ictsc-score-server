<template>
  <v-sheet :color="color" class="ma-0" :class="{ 'pa-2': !dense }">
    <!-- eslint-disable-next-line vue/no-v-html -->
    <div class="markdown" v-html="$md.render(content)" />
  </v-sheet>
</template>
<script>
export default {
  name: 'Markdown',
  props: {
    color: {
      type: String,
      default: 'transparent'
    },
    content: {
      type: String,
      required: true
    },
    dense: {
      type: Boolean,
      default: false
    }
  }
}
</script>
<style scoped lang="sass">
// 小要素にスタイルを適用するためdeep-selectを使っている
.markdown
  ::v-deep
    *
      max-width: 100%
    a
      // URLは記号以外でも折り返すようにする
      word-wrap: break-word
    p
      // 最後に余白ができるのを抑制
      &:last-child
        margin-bottom: 0

    // テーブル表示をGitHub風にする
    table
      border-collapse: collapse
      *
        word-break: break-word
      th, td
        border: 1px solid #dfe2e5
        padding: 6px
      tr
        &:nth-child(2n)
          background-color: #f6f8fa
    ul
      margin-bottom: 0.4em

    code
      color: #e04040
      font-weight: 600
      // なぜかコードの先頭に文字が入る
      &:before, &:after
        content: ""
    // `` でのみ影を消す
    &:not(pre)
      code
        padding: 0 0.3em 0 0.3em
        box-shadow: none
    pre
      code
        color: #000
        margin-top: 0.4em
        margin-bottom: 0.4em
        padding: 0.4em

    img
      max-width: 100%
      height: auto

    blockquote
      margin: 0.8em 0
      padding-left: 0.8em
      border-left: 0.4em solid #eee
      color: #777

    h1, h2
      margin-top: 0.8em
      margin-bottom: 0.6em
      line-height: 1.25
      border-bottom: 1px solid #eaecef
    h3, h4, h5, h6
      margin-top: 0.8em
      margin-bottom: 0.4em
</style>
