<template>
  <span class="warning pa-1">
    別セッションで値が変更されています<br />
    変更を破棄し最新の値から編集し直すなら 変更破棄 を押してください<br />
    更新時刻 {{ updatedAt }}
  </span>
</template>
<script>
export default {
  name: 'OriginDataChangedWarning',
  props: {
    updatedAt: {
      type: String,
      required: true
    }
  }
}
</script>
