<template>
  <v-text-field
    v-model="internalValue"
    v-bind="$attrs"
    :type="type"
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
    }
  },
  data() {
    return {
      internalValue: this.value
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
  width: 4em
  ::v-deep
    input
      text-align: right
</style>
