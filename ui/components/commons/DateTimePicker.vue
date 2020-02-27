<template>
  <div>
    <label v-if="label" class="caption">{{ label }}</label>
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
      default: null
    },
    readonly: {
      type: Boolean,
      default: false
    },
    label: {
      type: String,
      default: ''
    }
  },
  data() {
    return {
      date: null,
      time: null,
      text: null,
      rules: [v => this.isValidDateTime(v) || '不正なフォーマット(ISO 8601)']
    }
  },
  watch: {
    value: {
      immediate: true,
      handler(newValue) {
        // 上流から流れてきたデータはフォーマットしない
        this.valueToDate(newValue)
      }
    }
  },
  methods: {
    // 上流からの変更を反映する
    valueToDate(newValue) {
      this.text = newValue
      if (this.isValidDateString(newValue)) {
        this.date = this.$moment(newValue).format('YYYY-MM-DD')
      }
      this.time = this.$moment(newValue).format('HH:mm')
    },

    // 各inputからの変更を統合して管理・反映する
    updateDate({ date, time, text }) {
      // 2112-09-03T03:22:00+09:00 iso8601
      if (date !== undefined) {
        this.text = this.formatDateTime(`${date}T${this.time}`)
      } else if (time !== undefined) {
        this.text = this.formatDateTime(`${this.date}T${time}`)
      } else if (text !== undefined) {
        if (this.isValidDateTime(text)) {
          this.valueToDate(this.formatDateTime(text))
        } else {
          // 無効な値でも上流に伝播させたい(ProblemModal)
          this.text = text
        }
      }

      this.$emit('input', this.text)
    },

    setNow() {
      const now = this.$moment()
      now.second(0)
      now.minutes(0)

      this.updateDate({ text: now })
    },

    // vuetifyのDatePickerの年は4桁まで
    isValidDateString(string) {
      const year = this.$moment(string).format('YYYY')
      return year && year.length <= 4
    }
  }
}
</script>
