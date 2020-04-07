<template>
  <v-text-field
    v-bind="$attrs"
    :rules="rules"
    :readonly="readonly"
    :disabled="!isNew"
    label="コード"
    :append-icon="isNew ? undefined : 'mdi-lock'"
    v-on="$listeners"
  />
</template>
<script>
export default {
  name: 'ApplyModalCodeTextField',
  props: {
    readonly: {
      type: Boolean,
      required: true,
    },
    isNew: {
      type: Boolean,
      required: true,
    },
    items: {
      type: Array,
      required: true,
    },
  },
  data() {
    return {
      rules: [(v) => !!v || '必須', (v) => this.codeUniqueRule(v) || '既存'],
    }
  },
  methods: {
    codeUniqueRule(code) {
      if (!this.isNew) {
        return true
      }

      return !this.items.some((o) => o.code === code)
    },
  },
}
</script>
