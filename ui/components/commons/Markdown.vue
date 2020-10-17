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
      default: 'transparent',
    },
    content: {
      type: String,
      required: true,
    },
    dense: {
      type: Boolean,
      default: false,
    },
  },
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
    ul
      margin-bottom: 0.4em

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

    // `hoge` や ```hoge```
    code
      color: #000
      background-color: #e6e8ea
      word-break: break-word
      padding: 0.3em 0.3em 0em 0.3em
      vertical-align: middle
    pre
      padding: 0 0.6em
      background-color: #e6e8ea
      line-height: 1em
      code
        vertical-align: bottom
        background-color: unset
        white-space: pre-wrap
        // Firefox用
        word-break: break-word
        // なぜかコードの先頭に文字が入る問題の緩和
        &:before, &:after
          content: "\A"
          line-height: 0em

    img
      max-width: 100%
      height: auto

    // > 引用
    blockquote
      margin: 0.8em 0
      padding-left: 0.8em
      border-left: 0.4em solid #eee
      color: #444

    h1, h2
      margin-top: 0.8em
      margin-bottom: 0.6em
      line-height: 1.25
      border-bottom: 1px solid #eaecef
    h3, h4, h5, h6
      margin-top: 0.8em
      margin-bottom: 0.4em
</style>
