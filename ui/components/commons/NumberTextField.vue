<template>
  <v-text-field
    v-model="internalValue"
    v-bind="$attrs"
    :type="type"
    :rules="buildRules"
    flat
    maxlength="4"
    height="1em"
    class="number-text-field"
    @focus="$emit('focus')"
  />
</template>
<script>
export default {
  name: 'NumberTextField',
  props: {
    // v-model
    value: {
      type: [Number, String],
      default: 0
    },
    type: {
      type: String,
      default: 'number'
    },
    onlyInteger: {
      type: Boolean,
      default: false
    },
    rules: {
      type: Array,
      default: () => []
    }
  },
  data() {
    return {
      internalValue: this.value,
      integerRules: [
        v => !this.isBlank(v) || '必須',
        v => !Number.isNaN(parseInt(v)) || '整数'
      ]
    }
  },
  computed: {
    buildRules() {
      const tmpRules = this.onlyInteger ? this.integerRules : []
      return [...tmpRules, ...this.rules]
    }
  },
  watch: {
    internalValue(value) {
      if (this.type === 'number') {
        if (Number.isNaN(parseInt(value))) {
          this.$emit('input', 0)
        } else {
          this.$emit('input', parseInt(value))
        }
      } else {
        this.$emit('input', value)
      }
    },
    value(value) {
      this.internalValue = value
    }
  }
}
</script>
<style scoped lang="sass">
.number-text-field
  max-width: 4em
  min-width: 4em
  ::v-deep
    input
      text-align: right
</style>
