<template>
  <div
    style="width: min-content;"
    @mouseenter="onMouse = true"
    @mouseleave="onMouse = false"
  >
    <v-alert
      v-model="visible"
      :type="type"
      dismissible
      elevation="6"
      class="ma-0 text-left"
      width="30em"
    >
      <div class="notification-message">{{ message }}</div>

      <v-menu
        v-if="!!details"
        max-width="26em"
        top
        left
        offset-y
        open-delay="400"
        open-on-hover
        content-class="pa-0 opacity-1 elevation-12"
      >
        <v-card :color="type">
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
              class="pr-2 lighten-1"
              v-on="on"
            >
              <v-icon dense>mdi-cursor-pointer</v-icon>
              詳細
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
  </div>
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
  overflow-wrap: break-word
  width: 380px

.details-area
  bottom: -10px
  position: relative
</style>
