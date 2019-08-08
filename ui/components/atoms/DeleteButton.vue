<template>
  <v-btn
    v-if="show"
    :disabled="disabled"
    :color="color"
    x-small
    fab
    elevation="0"
    @click="$emit('click')"
  >
    <v-progress-circular
      v-if="expirable"
      :value="progressValue"
      background-opacity="0"
      color="white"
      rotate="270"
    />
    <v-icon dense color="white" style="position: absolute">mdi-delete</v-icon>
  </v-btn>
</template>
<script>
import { mapGetters } from 'vuex'

export default {
  name: 'DeleteButton',
  props: {
    color: {
      type: String,
      required: true
    },
    disabled: {
      type: Boolean,
      default: false
    },

    // 指定されると自動でボタンが非表示になる
    startAtMsec: {
      type: Number,
      default: null
    }
  },
  data() {
    return {
      expirable: this.startAtMsec
    }
  },
  computed: {
    ...mapGetters('time', ['currentTimeMsec']),
    ...mapGetters('contestInfo', ['deleteTimeLimitMsec']),

    show() {
      return this.progressValue > 0
    },
    progressValue() {
      const diff = this.currentTimeMsec - this.startAtMsec
      const value = 100 - Math.floor((100 * diff) / this.deleteTimeLimitMsec)
      return value >= 0 ? value : 0
    }
  }
}
</script>
