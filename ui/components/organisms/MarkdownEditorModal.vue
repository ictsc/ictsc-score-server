<!--
Markdownを書いて送信するモーダルのベースコンポーネント

機能
* 編集モーダルと確認モーダルがある
* Markdownプレビュー
* 送信前強制プレビュー
* LocalStorageで編集中のテキストを保護
* 補足メッセージを表示可能
* v-slot prepend, appendでMarkdownEditorの上下に要素を表示可能
-->
<template>
  <div>
    <!-- 編集モーダル -->
    <v-dialog
      :value="value"
      :persistent="sending"
      :max-width="maxWidth"
      scrollable
      @input="close"
    >
      <v-card>
        <v-card-title>
          <span>{{ title }}</span>
        </v-card-title>

        <v-divider />

        <v-card-text class="pt-0 pb-3">
          <v-form ref="form" v-model="valid">
            <slot name="prepend" />

            <markdown-text-area
              v-model="text"
              :readonly="confirming"
              :label="label"
              :autofocus="autofocus"
              :preview-width="maxWidth"
              placeholder="Markdownで記述できます"
              @submit="confirm"
            />
          </v-form>

          <slot name="append" />
        </v-card-text>

        <v-divider />
        <v-card-actions>
          <v-btn
            :disabled="confirming || !resetable"
            color="warning"
            @click="reset"
          >
            リセット
          </v-btn>

          <v-spacer />
          <v-btn
            :disabled="!valid || confirming"
            color="success"
            @click.stop="confirm"
          >
            確認
          </v-btn>
          <v-btn :disabled="confirming" @click="close">
            キャンセル
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <!-- 確認モーダル -->
    <v-dialog
      v-model="confirming"
      :persistent="sending"
      :max-width="maxWidth"
      scrollable
    >
      <v-card style="overflow-wrap: break-word">
        <v-card-title>
          <span>内容確認</span>
        </v-card-title>

        <v-divider />
        <v-card-text class="pa-1">
          <markdown :content="text" />
        </v-card-text>

        <template v-if="!!supplement">
          <v-divider />
          <span class="warning pa-1 text-right">
            {{ supplement }}
          </span>
        </template>

        <v-divider />
        <v-card-actions>
          <v-spacer />
          <v-btn
            :disabled="!valid || !confirming"
            :loading="sending"
            color="success"
            @click="submit"
          >
            {{ submitLabel }}
          </v-btn>
          <v-btn :disabled="sending" @click="confirming = false">
            戻る
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </div>
</template>
<script>
import Markdown from '~/components/atoms/Markdown'
import MarkdownTextArea from '~/components/molecules/MarkdownTextArea'

export default {
  name: 'MarkdownEditorModal',
  components: {
    Markdown,
    MarkdownTextArea
  },
  props: {
    // v-model
    // モーダルのopen/close
    value: {
      type: Boolean,
      required: true
    },
    // LocalStroageのkey
    storageKey: {
      type: String,
      required: true
    },
    title: {
      type: String,
      required: true
    },
    label: {
      type: String,
      default: undefined
    },
    submitLabel: {
      type: String,
      required: true
    },
    autofocus: {
      type: Boolean,
      default: false
    },
    // 送信モーダルで補足メッセージを表示可能
    supplement: {
      type: String,
      default: ''
    },
    maxWidth: {
      type: String,
      default: '50em'
    },
    // prependやappendの要素が編集されたかどうか
    // trueならリセットボタンが有効になる
    edited: {
      type: Boolean,
      default: false
    }
  },
  data() {
    return {
      valid: false,
      confirming: false,
      sending: false,
      text: this.$jsonStorage.get(this.storageKey)
    }
  },
  computed: {
    resetable() {
      return this.edited || this.text !== ''
    }
  },
  watch: {
    text(value) {
      this.$jsonStorage.set(this.storageKey, value)
    }
  },
  methods: {
    confirm() {
      this.confirming = true
    },
    close() {
      // 主にsumitが成功して閉じる時に必要
      // closeする場合でこれらがfalseでないケースは無いはず
      this.confirming = false
      this.sending = false

      this.$emit('input', false)
    },
    reset() {
      this.text = ''
      this.$emit('reset')
      this.$refs.form.resetValidation()
    },
    submit() {
      this.sending = true
      this.$emit('submit', this.text)
    },
    // 親コンポーネントから呼び出す
    succeeded() {
      this.reset()
      this.close()
    }
  }
}
</script>
