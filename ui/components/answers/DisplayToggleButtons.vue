<template>
  <v-btn-toggle v-model="internalValue" multiple>
    <v-btn
      value="onlyHasNotPoint"
      :class="onlyHasNotPointClass"
      active-class="error white--text elevation-4"
    >
      未採点のみ
    </v-btn>

    <v-btn
      v-if="isStaff"
      value="onlyConfirming"
      :class="onlyConfirmingClass"
      active-class="info white--text elevation-4"
    >
      対応中のみ
    </v-btn>
  </v-btn-toggle>
</template>
<script>
export default {
  name: 'DisplayToggleButtons',
  model: {
    prop: 'value',
    event: 'change'
  },
  props: {
    value: {
      type: Array,
      required: true
    }
  },
  data() {
    return {
      internalValue: this.value
    }
  },
  computed: {
    onlyHasNotPointClass() {
      return this.internalValue.includes('onlyHasNotPoint') ? '' : 'error--text'
    },
    onlyConfirmingClass() {
      return this.internalValue.includes('onlyConfirming') ? '' : 'info--text'
    }
  },
  watch: {
    value(value) {
      this.internalValue = value
    },
    internalValue(value) {
      this.$emit('change', value)
    }
  }
}
</script>
