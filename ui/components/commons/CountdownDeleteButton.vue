<template>
  <v-dialog
    v-model="dialog"
    :persistent="sending"
    max-width="20em"
    scrollable
    @click:outside="close"
  >
    <template v-slot:activator="{}">
      <v-tooltip
        v-model="tooltip"
        right
        color="white"
        content-class="pa-0 elevation-8 opacity-1"
      >
        <!-- ゴミ箱ボタン -->
        <template v-slot:activator="{}">
          <v-btn
            x-small
            fab
            color="transparent"
            elevation="0"
            :class="btnClass"
            @click="countdown"
          >
            <v-icon dense color="grey">mdi-delete</v-icon>
          </v-btn>
        </template>

        <v-card class="py-1 px-3 subtitle">
          {{ count }} &nbsp;&nbsp; {{ messages[count] }}
        </v-card>
      </v-tooltip>
    </template>

    <!-- 最終確認ダイアログ -->
    <v-card>
      <v-card-title>
        <div>本当に削除しますか?</div>
      </v-card-title>

      <template v-if="!!$slots.default">
        <v-divider />

        <v-card-text class="pa-1">
          <slot :item="item" />
        </v-card-text>

        <v-divider />
      </template>

      <v-card-actions>
        <v-btn left :loading="sending" color="error" @click="callSubmit">
          削除
        </v-btn>
        <v-spacer />
        <v-btn left :disabled="sending" @click="close">
          キャンセル
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>
<script>
export default {
  name: 'CountdownDeleteButton',
  props: {
    item: {
      type: Object,
      required: true
    },
    submit: {
      type: Function,
      required: true
    },
    btnClass: {
      type: String,
      default: ''
    }
  },
  data() {
    return {
      tooltip: false,
      dialog: false,
      sending: false,
      count: 5,
      resetTimer: -1,
      messages: [
        'やめて! 私のライフはもう0よ!',
        '死にたくないー',
        '助けてー',
        'やめてー',
        'きゃー'
      ]
    }
  },
  methods: {
    countdown() {
      if (this.count === 0) {
        this.tooltip = false
        this.dialog = true
        this.resetTimeout()
      } else {
        this.tooltip = true
        this.count -= 1
        this.resetTimeout()
        this.resetTimer = setTimeout(() => this.close(), 3000)
      }
    },
    resetTimeout() {
      clearTimeout(this.resetTimer)
      this.resetTimer = -1
    },
    async callSubmit() {
      this.sending = true
      await this.submit(this.item)
      this.close()
    },
    close() {
      this.tooltip = false
      this.dialog = false
      this.sending = false
      this.$nextTick(() => (this.count = 5))
      this.resetTimeout()
    }
  }
}
</script>
