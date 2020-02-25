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
    show() {
      return !this.expirable || this.progressValue > 0
    },
    progressValue() {
      return 100
    }
  }
}
</script>
