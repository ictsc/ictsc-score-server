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
      required: true
    }
  },
  data() {
    return {
      rules: [v => !!v || '必須']
    }
  }
}
</script>
