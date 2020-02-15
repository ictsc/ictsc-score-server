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
            <date-time-picker v-model="configValue" :readonly="sending" />
          </template>
          <template v-else>未実装 "{{ config.valueType }}"</template>
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
import DateTimePicker from '~/components/commons/DateTimePicker'

export default {
  name: 'ConfigModal',
  components: {
    DateTimePicker,
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

    return {
      showModal: this.value,
      valid: false,
      sending: false,

      storageKey,
      configValue,
      integerRules: [
        v => (!['', null, undefined].includes(v) && !Number.isNaN(v)) || '必須'
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
    }
  },
  methods: {
    ...mapActions('contestInfo', ['fetchContestInfo']),

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

      await orm.Mutations.updateConfig({
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
