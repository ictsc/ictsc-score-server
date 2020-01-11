<template>
  <v-dialog
    v-model="showModal"
    :persistent="sending"
    :max-width="maxWidth"
    scrollable
    @input="!$event && close()"
  >
    <template v-slot:activator="{}">
      <slot name="activator" :on="open" />
    </template>

    <v-card>
      <v-card-title>{{ config.key }}</v-card-title>
      <v-card-text class="px-4 pb-0">
        <v-form ref="form" v-model="valid">
          <template v-if="config.valueTypeIsBoolean">
            <v-switch v-model="configValue" :readonly="sending" inset />
          </template>
          <template v-else-if="config.valueTypeIsInteger">
            <number-text-field
              v-model="configValue"
              :readonly="sending"
              :rules="integerRules"
            />
          </template>
          <template v-else-if="config.valueTypeIsString">
            <markdown-text-area
              v-model="configValue"
              :readonly="sending"
              allow-empty
              placeholder="Markdownで記述できます"
            />
          </template>
          <template v-else-if="config.valueTypeIsDate">
            <v-row justify="center">
              <v-date-picker
                v-model="datePicker"
                :readonly="sending"
                reactive
                show-current
                scrollable
                locale="ja-jp"
              />

              <v-time-picker
                v-model="timePicker"
                :readonly="sending"
                format="24hr"
                scrollable
                color="primary"
                class="ml-2"
              />
            </v-row>

            <v-text-field
              v-model="configValue"
              :readonly="sending"
              :rules="dateRules"
            >
              <template v-slot:prepend>
                <v-btn small @click="setNow">now</v-btn>
              </template>
            </v-text-field>
          </template>
          <template v-else>
            未実装
          </template>
        </v-form>
      </v-card-text>

      <v-card-actions>
        <v-btn :disabled="sending || !resetable" color="warning" @click="reset">
          リセット
        </v-btn>

        <v-spacer />

        <v-btn :disabled="!valid || !changed" color="success" @click="submit">
          更新
        </v-btn>
        <v-btn :disabled="sending" @click="close">
          キャンセル
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>
<script>
import { mapActions } from 'vuex'
import orm from '~/orm'
import MarkdownTextArea from '~/components/commons/MarkdownTextArea'
import NumberTextField from '~/components/commons/NumberTextField'

export default {
  name: 'ConfigModal',
  components: {
    MarkdownTextArea,
    NumberTextField
  },
  props: {
    // v-model
    // モーダルのopen/close
    value: {
      type: Boolean,
      default: false
    },
    config: {
      type: Object,
      required: true
    }
  },
  data() {
    const storageKey = `config-${this.config.key}`
    const configValue = this.$jsonStorage.get(
      storageKey,
      this.config.parsedValue
    )
    let datePicker = null
    let timePicker = null

    if (this.config.valueTypeIsDate) {
      datePicker = this.$moment(configValue).format('YYYY-MM-DD')
      timePicker = this.$moment(configValue).format('HH:mm:ss')
    }

    return {
      showModal: this.value,
      valid: false,
      sending: false,

      storageKey,
      configValue,
      datePicker,
      timePicker,
      integerRules: [
        v => (!['', null, undefined].includes(v) && !Number.isNaN(v)) || '必須',
        v => parseInt(v) >= 0 || '0以上'
      ],
      dateRules: [
        v => this.isValidDateTime(v) || '不正なフォーマット(ISO 8601)'
      ]
    }
  },
  computed: {
    maxWidth() {
      return this.config.valueTypeIsBoolean || this.config.valueTypeIsInteger
        ? '22em'
        : '40em'
    },
    resetable() {
      return this.configValue !== this.config.parsedValue
    },
    changed() {
      if (this.config.valueTypeIsDate) {
        return (
          this.formatDateTime(this.configValue) !==
          this.formatDateTime(this.config.parsedValue)
        )
      } else {
        return this.configValue !== this.config.parsedValue
      }
    }
  },
  watch: {
    value(value) {
      this.showModal = value
    },
    showModal(value) {
      this.$emit('input', value)
    },

    configValue(value) {
      this.$jsonStorage.set(this.storageKey, value)

      if (this.config.valueTypeIsDate) {
        this.updateDateTimeToPicker(value)
      }
    },
    datePicker(value) {
      this.updateDateTimeFromPicker()
    },
    timePicker(value) {
      this.updateDateTimeFromPicker()
    }
  },
  methods: {
    ...mapActions('contestInfo', ['fetchContestInfo']),

    updateDateTimeFromPicker() {
      // 2112-09-03T03:22:00+09:00 iso8601
      this.configValue = this.formatDateTime(
        `${this.datePicker}T${this.timePicker}`
      )
    },
    updateDateTimeToPicker(value) {
      if (!this.isValidDateTime(value)) {
        return
      }

      this.datePicker = this.$moment(value).format('YYYY-MM-DD')
      this.timePicker = this.$moment(value).format('HH:mm')
    },
    setNow() {
      const now = this.$moment()
      now.second(0)
      now.minutes(0)
      this.configValue = now.format()
    },

    open() {
      this.showModal = true
    },
    close() {
      this.showModal = false
    },
    reset() {
      this.configValue = this.config.parsedValue
      this.$refs.form.resetValidation()
    },
    async submit() {
      this.sending = true

      await orm.Mutation.updateConfig({
        action: '設定変更',
        resolve: () => {
          this.fetchContestInfo()
          this.close()
        },
        params: {
          key: this.config.key,
          value: JSON.stringify(this.configValue)
        }
      })

      this.sending = false
    }
  }
}
</script>
