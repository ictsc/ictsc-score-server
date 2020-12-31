<template>
  <v-alert
    v-model="visible"
    :type="type"
    elevation="6"
    dismissible
    dense
    class="text-left pl-2 mb-2"
    @mouseenter="onMouse = true"
    @mouseleave="onMouse = false"
  >
    <div class="notification-message">{{ message }}</div>

    <v-menu
      v-if="!!details"
      top
      left
      offset-y
      open-delay="400"
      open-on-hover
      content-class="pa-0 elevation-12"
    >
      <v-card :color="type" dense class="lighten-1">
        <v-card-text class="white--text">
          {{ details }}
        </v-card-text>
      </v-card>

      <template v-slot:activator="{ on }">
        <v-row justify="end" no-gutters class="details-area">
          <v-card
            :color="type"
            :ripple="false"
            outlined
            tile
            dense
            class="lighten-1"
            v-on="on"
          >
            <v-card-text class="px-1 py-0 white--text">
              <v-icon dense>mdi-cursor-pointer</v-icon>
              詳細
            </v-card-text>
          </v-card>
        </v-row>
      </template>
    </v-menu>

    <v-progress-linear
      v-show="onMouse === false"
      :active="timeout !== 0"
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
      required: true,
    },
    timeout: {
      type: Number,
      required: true,
    },
    type: {
      type: String,
      required: true,
    },
    message: {
      type: String,
      required: true,
    },
    details: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      visible: true,
      startAtMsec: 0,
      progressElapsedTime: 0,
      activeTimeout: -1,
      onMouse: false,
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
          return 'error'
        default:
          throw new Error('unhandled notification type')
      }
    },
    progressValue() {
      return (100 * (this.currentTimeMsec - this.startAtMsec)) / this.timeout
    },
  },
  watch: {
    visible(value) {
      if (value === false) {
        this.removeNotification(this.uid)
      }
    },
    onMouse(value) {
      if (value) {
        this.stopTimeout()
      } else {
        this.startTimeout()
      }
    },
  },
  created() {
    this.startTimeout()
  },
  beforeDestroy() {
    this.stopTimeout()
  },
  methods: {
    ...mapMutations('notification', ['removeNotification']),

    resetTimeout() {
      this.stopTimeout()
      this.startTimeout()
    },
    startTimeout() {
      if (this.timeout !== 0) {
        this.startAtMsec = Date.now()

        this.activeTimeout = setTimeout(() => {
          this.visible = false
        }, this.timeout)
      }
    },
    stopTimeout() {
      clearTimeout(this.activeTimeout)
      this.activeTimeout = -1
    },
  },
}
</script>
<style scoped lang="sass">
.notification-message
  white-space: pre-wrap
  word-wrap: break-word
  // NotificationAreaのwidthに合わせて調整する
  width: 30em

.details-area
  bottom: -4px
  position: relative
</style>
