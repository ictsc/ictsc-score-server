<!--
  ページタイトルを表示して、タブのタイトルも設定する
-->
<template>
  <div class="mb-4">
    <span class="headline">{{ title }}</span>
    <slot />
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
