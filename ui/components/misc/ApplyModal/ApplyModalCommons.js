// Apply系Modalにmixinする
// Modalの共通機能を抜き出した

export default {
  props: {
    // v-model
    value: {
      type: Boolean,
      required: true
    }
  },
  data() {
    return {
      internalValue: this.value,
      valid: false,
      sending: false
    }
  },
  watch: {
    internalValue() {
      this.$emit('input', this.internalValue)
    },
    value(value) {
      this.internalValue = value
      if (value === true) {
        this.$nextTick(() => this.validate())
      }
    }
  },
  methods: {
    open() {
      this.internalValue = true
    },
    close() {
      this.internalValue = false
    },
    validate() {
      this.$refs.form.validate()
    }
  }
}
