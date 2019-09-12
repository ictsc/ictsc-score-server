<template>
  <v-alert
    v-model="visible"
    :type="type"
    dismissible
    class="mb-2"
    elevation="6"
  >
    <span class="notification-message">{{ message }}</span>

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
import { mapGetters, mapMutations } from 'vuex'

// 時間経過、閉じるボタン、ストアからの削除で要素が消える
export default {
  name: 'NotificationCard',
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
    },
    message: {
      type: String,
      required: true
    }
  },
  data() {
    return {
      visible: true,
      startAtMsec: Date.now(),
      progressElapsedTime: 0,
      activeTimeout: -1
    }
  },
  computed: {
    ...mapGetters('time', ['currentTimeMsec']),
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
      return (100 * (this.currentTimeMsec - this.startAtMsec)) / this.timeout
    }
  },
  watch: {
    visible(value) {
      if (value === false) {
        this.removeNotification(this.uid)
      }
    }
  },
  created() {
    if (this.timeout !== 0) {
      this.activeTimeout = setTimeout(() => {
        this.visible = false
      }, this.timeout)
    }
  },
  beforeDestroy() {
    clearTimeout(this.activeTimeout)
  },
  methods: {
    ...mapMutations('notification', ['removeNotification'])
  }
}
</script>
<style scoped lang="sass">
.notification-message
  white-space: pre-wrap
  word-wrap: break-word
</style>
