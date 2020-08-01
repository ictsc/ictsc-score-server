<template>
  <v-text-field
    v-bind="$attrs"
    :rules="rules"
    :readonly="readonly"
    label="名前"
    v-on="$listeners"
  />
</template>
<script>
export default {
  name: 'ApplyModalTitleTextField',
  props: {
    readonly: {
      type: Boolean,
      required: true,
    },
    allowEmpty: {
      type: Boolean,
      default: false,
    },
  },
  data() {
    return {
      rules: [(v) => this.allowEmpty || !this.isBlank(v) || '必須'],
    }
  },
}
</script>
