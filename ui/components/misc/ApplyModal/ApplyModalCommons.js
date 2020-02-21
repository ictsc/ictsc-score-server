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
      openedAtFristCalled: false
    }
  },
  watch: {
    internalValue: {
      immediate: true,
      handler(value) {
        this.$emit('input', value)
        if (value && !this.openedAtFristCalled && this.openedAtFirst) {
          this.openedAtFristCalled = true
          this.openedAtFirst()
        }
      }
    },
    value: {
      immediate: true,
      handler(value) {
        this.internalValue = value
        if (value === true) {
          this.validate()
        }
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
      // タイミングによってはエラーになるので遅延させる
      this.$nextTick(() => this.$refs.form.validate())
    }
  }
}
