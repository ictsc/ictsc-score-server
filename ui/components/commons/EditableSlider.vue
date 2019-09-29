<!--
数値スライダーと編集可能なテキストフィールド
意図した挙動をするように動的にstepとmaxを変更する
-->
<template>
  <v-row no-gutters>
    <number-text-field
      :value="value"
      :readonly="readonly"
      :rules="rules"
      :label="label"
      :suffix="suffix"
      @focus="stepEnable = false"
      @input="$emit('input', $event)"
    />

    <v-layout column class="ma-0">
      <v-slider
        :value="value"
        :step="stepEnable ? step : undefined"
        :readonly="readonly"
        track-color="grey lighten-2"
        :min="sliderMin"
        :max="sliderMax"
        hide-details
        class="ml-4"
        @input="updateBySlider"
      />
      <slot name="bottom" />
    </v-layout>
  </v-row>
</template>
<script>
import NumberTextField from '~/components/commons/NumberTextField'

export default {
  name: 'EditableSlider',
  components: {
    NumberTextField
  },
  props: {
    // v-model
    value: {
      type: Number,
      required: true
    },
    readonly: {
      type: Boolean,
      default: false
    },
    label: {
      type: String,
      default: undefined
    },
    suffix: {
      type: String,
      default: undefined
    },
    rules: {
      type: Array,
      default: undefined
    },
    step: {
      type: Number,
      required: true
    },
    max: {
      type: Number,
      required: true
    },
    min: {
      type: Number,
      default: 0
    }
  },
  data() {
    return {
      stepEnable: false
    }
  },
  computed: {
    sliderMax() {
      if (Number.isNaN(this.value) || this.value <= this.max) {
        return this.max
      }

      return this.stepEnable ? this.max : this.value
    },
    sliderMin() {
      if (Number.isNaN(this.value) || this.min <= this.value) {
        return this.min
      }

      return this.stepEnable ? this.min : this.value
    }
  },
  watch: {
    value(value) {
      if (value % this.step !== 0) {
        // 外部の入力でvalueを変更する場合、無効にする必要がある
        this.stepEnable = false
      }
    }
  },
  methods: {
    updateBySlider(value) {
      this.stepEnable = true
      this.$emit('input', Math.floor(value / this.step) * this.step)
    }
  }
}
</script>
<style scoped lang="sass">
::v-deep
  .v-slider--horizontal
    margin-top: 6px
</style>
