// Apply系Modalにmixinする
// Modalの共通機能を抜き出した

export default {
  props: {
    // v-model
    value: {
      type: Boolean,
      default: false
    }
  },
  data() {
    return {
      internalValue: this.value,
      valid: false,
      sending: false,
      opendAtFristCalled: false
    }
  },
  watch: {
    internalValue(value) {
      this.$emit('input', value)

      if (value && !this.opendAtFristCalled && this.opendAtFirst) {
        this.opendAtFristCalled = true
        this.opendAtFirst()
      }
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
