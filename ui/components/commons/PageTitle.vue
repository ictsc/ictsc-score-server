<!--
  ページタイトルを表示して、タブのタイトルも設定する
-->
<template>
  <div>
    <span class="headline">{{ title }}</span>
    <v-spacer class="mb-4" />
  </div>
</template>
<script>
export default {
  name: 'PageTitle',
  props: {
    title: {
      type: String,
      required: true
    }
  },
  head() {
    return {
      title: this.title
    }
  }
}
</script>
