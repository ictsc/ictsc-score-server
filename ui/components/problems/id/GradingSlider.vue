<template>
  <v-slider
    :value="slider"
    :step="stepEnable ? 5 : undefined"
    :readonly="sending"
    track-color="grey lighten-2"
    min="-5"
    max="100"
    hide-details
    @input="changedSlider($event)"
    @mousedown="stepEnable = true"
  >
    <template v-slot:prepend>
      <!-- なぜか:valueだと意図した動作をしない -->
      <number-text-field
        v-model="text"
        :readonly="sending"
        suffix="%"
        hide-details
        type="string"
        single-line
        @input="changedText($event)"
        @focus="stepEnable = false"
      />

      <slot name="prepend" />
    </template>

    <template v-slot:append>
      <slot name="append" />
    </template>
  </v-slider>
</template>
<script>
import NumberTextField from '~/components/commons/NumberTextField'

export default {
  name: 'GradingSlider',
  components: {
    NumberTextField
  },
  props: {
    // v-model
    value: {
      required: true,
      validator: prop => typeof prop === 'number' || prop === null
    },
    sending: {
      type: Boolean,
      required: true
    }
  },
  data() {
    return {
      stepEnable: false,
      slider: null,
      text: null
    }
  },
  watch: {
    value: {
      immediate: true,
      handler(newValue) {
        this.downstream(newValue)
      }
    }
  },
  methods: {
    downstream(newValue) {
      this.slider = newValue === null ? -5 : newValue
      this.text = newValue === null ? 'null' : `${newValue}`
    },
    changedSlider(num) {
      this.$emit('input', num === -5 ? null : num)
    },
    changedText(str) {
      const num = parseInt(str)

      if (isNaN(Number(str)) || isNaN(num)) {
        this.$nextTick(() => (this.text = 'null'))
        this.$emit('input', null)
      } else if (num < 0) {
        this.$nextTick(() => (this.text = '0'))
        this.$emit('input', 0)
      } else if (num > 100) {
        this.$nextTick(() => (this.text = '100'))
        this.$emit('input', 100)
      } else {
        this.$emit('input', num)
      }
    }
  }
}
</script>
