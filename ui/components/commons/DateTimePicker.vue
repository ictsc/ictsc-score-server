<template>
  <div>
    <v-row justify="center">
      <v-date-picker
        :value="date"
        :readonly="readonly"
        reactive
        show-current
        scrollable
        locale="ja-jp"
        @input="updateDate({ date: $event })"
      />

      <v-time-picker
        :value="time"
        :readonly="readonly"
        format="24hr"
        scrollable
        color="primary"
        class="ml-2"
        @input="updateDate({ time: $event })"
      />
    </v-row>

    <v-text-field
      :value="text"
      :readonly="readonly"
      :rules="rules"
      @input="updateDate({ text: $event })"
    >
      <template v-slot:prepend>
        <v-btn small @click="setNow">Now!</v-btn>
      </template>
    </v-text-field>
  </div>
</template>
<script>
export default {
  name: 'DateTimePicker',
  props: {
    // v-model
    value: {
      type: String,
      required: true
    },
    readonly: {
      type: Boolean,
      default: false
    }
  },
  data() {
    return {
      date: '',
      time: '',
      text: '',
      rules: [v => this.isValidDateTime(v) || '不正なフォーマット(ISO 8601)']
    }
  },
  watch: {
    value: {
      immediate: true,
      handler(newValue) {
        this.valueToDate(newValue)
      }
    }
  },
  methods: {
    // 上流からの変更を反映する
    valueToDate(newValue) {
      this.text = this.formatDateTime(newValue)
      this.date = this.$moment(newValue).format('YYYY-MM-DD')
      this.time = this.$moment(newValue).format('HH:mm')
    },

    // 各inputからの変更を統合して管理・反映する
    updateDate({ date, time, text }) {
      // 2112-09-03T03:22:00+09:00 iso8601
      if (date) {
        this.text = this.formatDateTime(`${date}T${this.time}`)
      } else if (time) {
        this.text = this.formatDateTime(`${this.date}T${time}`)
      } else if (text) {
        // invalidならpickerに反映せず、emitもしない
        if (!this.isValidDateTime(text)) {
          return
        }
        this.valueToDate(text)
      }

      this.$emit('input', this.text)
    },

    setNow() {
      const now = this.$moment()
      now.second(0)
      now.minutes(0)

      this.updateDate({ text: now })
    }
  }
}
</script>
