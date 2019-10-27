<template>
  <div class="mt-2">
    <div class="subtitle-1">{{ title }}</div>
    <div class="caption">{{ body }}</div>
  </div>
</template>
<script>
export default {
  name: 'FlowItem',
  props: {
    title: {
      type: String,
      required: true
    },
    body: {
      type: String,
      required: true
    }
  }
}
</script>
