<template>
  <span class="warning lighten-2 px-4 py-1">
    編集箇所が別セッションで変更されました<br />
    {{ conflictFields.join(', ') }} <br />
    最新版更新時刻 {{ latestUpdatedAt }}
  </span>
</template>
<script>
export default {
  name: 'ConflictWarning',
  props: {
    latestUpdatedAt: {
      type: String,
      required: true,
    },
    conflictFields: {
      type: Array,
      required: true,
    },
  },
}
</script>
