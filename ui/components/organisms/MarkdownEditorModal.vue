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
      :value="open"
      :persistent="sending"
      max-width="70em"
      scrollable
      @input="close"
    >
      <v-card style="">
        <v-card-title>
          <span>{{ title }}</span>
        </v-card-title>

        <slot name="prepend" />

        <v-divider></v-divider>
        <v-card-text class="">
          <markdown-text-area
            v-model="text"
            :error.sync="error"
            :readonly="confirming"
            placeholder="Markdownで記述できます"
            preview-width="70em"
          />
        </v-card-text>

        <slot name="append" />

        <v-divider></v-divider>
        <v-card-actions>
          <v-spacer />
          <v-btn
            left
            :disabled="error || confirming"
            color="success"
            @click.stop="confirming = true"
          >
            確認
          </v-btn>
          <v-btn left :disabled="confirming" @click="close">
            キャンセル
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <!-- 確認モーダル -->
    <v-dialog
      v-model="confirming"
      :persistent="sending"
      max-width="70em"
      scrollable
    >
      <v-card style="overflow-wrap: break-word">
        <v-card-title>
          <span>内容確認</span>
        </v-card-title>

        <v-divider></v-divider>
        <v-card-text class="pa-1">
          <markdown :content="text" />
        </v-card-text>

        <template v-if="!!supplement">
          <v-divider></v-divider>
          <span class="warning pa-1 text-right">
            {{ supplement }}
          </span>
        </template>

        <v-divider></v-divider>
        <v-card-actions>
          <v-spacer />
          <v-btn
            left
            :disabled="error || !confirming"
            :loading="sending"
            color="success"
            @click="$emit('submit', text)"
          >
            {{ submitLabel }}
          </v-btn>
          <v-btn left :disabled="sending" @click="confirming = false">
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
    // モーダルのopen/close
    // :open.sync で同期が必要
    open: {
      type: Boolean,
      required: true
    },
    // 値が falseからtrueになるとローカルストレージをクリアしてダイアログを閉じる
    // :succeeded.sync で同期が必要
    succeeded: {
      type: Boolean,
      required: true
    },
    // 親コンポーネントから送信ボタンのloadingを制御
    sending: {
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
    submitLabel: {
      type: String,
      required: true
    },
    // 送信モーダルで補足メッセージを表示可能
    supplement: {
      type: String,
      default: ''
    }
  },
  data() {
    return {
      error: true,
      confirming: false,
      text: this.$storage.getLocalStorage(this.storageKey)
    }
  },
  watch: {
    // 親要素からtextをクリアしてモーダルを閉じる
    succeeded(newValue, oldValue) {
      if (oldValue === false && newValue === true) {
        // reset data
        this.text = ''
        this.$emit('update:succeeded', false)

        // close dialogs
        this.confirming = false
        this.close()
      }
    },
    text(value) {
      this.$storage.setLocalStorage(this.storageKey, value)
    }
  },
  methods: {
    close() {
      this.$emit('update:open', false)
    }
  }
}
</script>
