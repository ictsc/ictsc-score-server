<template>
  <v-layout column>
    <v-flex pa-0>
      <v-textarea
        v-model="internalValue"
        :autofocus="autofocus"
        :placeholder="placeholder"
        :readonly="readonly"
        solo
        flat
        auto-grow
        hide-details
        class="shrink-side-slot"
      >
      </v-textarea>
    </v-flex>
    <v-flex py-0>
      <v-layout row align-center justify-end>
        <v-flex shrink py-0>
          <span class="caption" :class="textCounterColor">
            {{ textCounter }}
          </span>
        </v-flex>

        <v-flex shrink py-0>
          <!-- ESCキーや範囲外クリックでも閉じれる -->
          <v-dialog v-model="preview" :max-width="previewWidth" scrollable>
            <template v-slot:activator="{ on }">
              <v-btn
                :disabled="previewDisabled"
                fab
                icon
                x-small
                color="primary"
                v-on="on"
              >
                <v-icon>mdi-eye</v-icon>
              </v-btn>
            </template>

            <v-card style="overflow-wrap: break-word">
              <v-card-title>
                <span>プレビュー</span>
              </v-card-title>

              <v-divider></v-divider>
              <v-card-text class="pa-1">
                <markdown :content="internalValue" />
              </v-card-text>

              <v-divider></v-divider>
              <v-card-actions>
                <v-spacer />
                <v-btn left @click="preview = false">閉じる</v-btn>
              </v-card-actions>
            </v-card>
          </v-dialog>
        </v-flex>
      </v-layout>
    </v-flex>
  </v-layout>
</template>
<script>
import { mapGetters } from 'vuex'
import Markdown from '~/components/atoms/Markdown'

// TODO: auto-growの自動スクロールにもうちょい余裕を持たせる

export default {
  name: 'MarkdownTextArea',
  components: {
    Markdown
  },
  props: {
    // v-modelでvalueを受け取るには明示が必要
    // 一応null,undefinedも可
    value: {
      type: String,
      default: ''
    },
    // v-bind:error.sync
    error: {
      type: Boolean,
      required: true
    },
    autofocus: {
      type: Boolean,
      default: false
    },
    readonly: {
      type: Boolean,
      required: true
    },
    placeholder: {
      type: String,
      default: ''
    },
    previewWidth: {
      type: String,
      default: null
    }
  },
  data() {
    return {
      preview: false,
      // 文字列は初期状態をnullにしないと、''が来た時にwatchが発火しない
      internalValue: this.value
    }
  },
  computed: {
    ...mapGetters('contestInfo', ['textSizeLimit']),
    textCount() {
      return (this.internalValue || '').toString().length
    },
    textCounter() {
      return this.textSizeLimit - this.textCount
    },
    textCounterColor() {
      if (this.textCounter < 0) {
        return 'error--text'
      } else if (this.textCounter <= 50) {
        return 'warning--text'
      } else {
        return 'grey--text text--ligthen-5'
      }
    },
    checkError() {
      return !(this.textCount > 0 && this.textCount <= this.textSizeLimit)
    },
    previewDisabled() {
      return this.textCount <= 0
    }
  },
  watch: {
    internalValue() {
      this.$emit('input', this.internalValue)
      this.$emit('update:error', this.checkError)
    },
    value() {
      this.internalValue = this.value
    }
  },
  created() {
    // バリデーションの初期状態を同期する
    this.$emit('update:error', this.checkError)
  }
}
</script>
<style scoped lang="sass">
// v-textareaの余分な余白を消す(特に左サイド)
.shrink-side-slot
  ::v-deep
    div
      .v-input__slot
        padding: 0 0 !important
    textarea
      padding: 0 0 0 0
</style>
