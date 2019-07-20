<template>
  <v-alert
    v-model="visible"
    :type="type"
    dismissible
    class="mb-2"
    elevation="6"
  >
    <slot />

    <v-progress-linear
      active
      :value="progressValue"
      :color="progressColor"
      background-opacity="0"
      absolute
      bottom
      rounded
    >
    </v-progress-linear>
  </v-alert>
</template>
<script>
import { mapMutations } from 'vuex'

// 時間経過、閉じるボタン、ストアからの削除で要素が消える
export default {
  name: 'Notification',
  props: {
    // idだと被る
    uid: {
      type: Number,
      required: true
    },
    timeout: {
      type: Number,
      required: true
    },
    type: {
      type: String,
      required: true
    }
  },
  data() {
    return {
      visible: true,
      progressElapsedTime: 0,
      activeTimeout: -1,
      progressInterval: -1
    }
  },
  computed: {
    progressColor() {
      switch (this.type) {
        case 'success':
          return 'light-green accent-4'
        case 'info':
          return 'light-blue accent-2'
        case 'warning':
          return 'amber accent-4'
        case 'error':
          return 'red accent-1'
        default:
          throw new Error('unhandled notification type')
      }
    },
    progressValue() {
      return (100 * this.progressElapsedTime) / this.timeout
    }
  },
  watch: {
    visible(value) {
      if (value === false) {
        this.removeSelf()
      }
    }
  },
  mounted() {
    if (this.timeout !== 0) {
      this.activeTimeout = window.setTimeout(() => {
        this.removeSelf()
      }, this.timeout)

      const intervalTime = 500
      this.progressInterval = window.setInterval(() => {
        this.progressElapsedTime += intervalTime
      }, intervalTime)
    }
  },
  beforeDestroy() {
    window.clearTimeout(this.activeTimeout)
    window.clearInterval(this.progressInterval)
  },
  methods: {
    ...mapMutations('notification', ['removeNotification']),
    removeSelf() {
      this.removeNotification(this.uid)
    }
  }
}
</script>
