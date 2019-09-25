<!--
マークダウンを書くためのtextarea

機能
* ctrl-enterでsubmitイベントを発火(@submit)
* previewボタンでプレビュー可能
-->
<template>
  <div>
    <div
      :class="classes"
      @drop.prevent="insertFileLink($event.dataTransfer.files)"
      @dragover.prevent="dragging = true"
      @dragleave.prevent="dragging = false"
    >
      <div v-show="dragging" class="display-2 white--text overlay-text">
        {{ uploading ? 'アップロード中' : 'ドロップ' }}
      </div>

      <v-textarea
        ref="textarea"
        v-model="internalValue"
        v-bind="$attrs"
        :rules="rules"
        flat
        auto-grow
        class="shrink-side-slot pt-1"
        :class="hideLabelArea ? 'shrink-top' : 'label-margin'"
        v-on="$listeners"
        @keyup.ctrl.enter.prevent="valid && $emit('submit')"
      />

      <v-row
        align="center"
        justify="end"
        :class="{
          'show-in-details': showInDetails,
          'mr-1': showInDetails
        }"
      >
        <span class="caption" :class="textCounterColor">
          {{ textCounter }}
        </span>

        <v-btn
          :disabled="previewDisabled"
          fab
          icon
          x-small
          color="primary"
          @click="preview = true"
        >
          <v-icon>mdi-eye</v-icon>
        </v-btn>
      </v-row>
    </div>

    <v-dialog v-model="preview" :max-width="previewWidth" scrollable>
      <v-card>
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
  </div>
</template>
<script>
import { mapGetters } from 'vuex'
import Markdown from '~/components/commons/Markdown'

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
    allowEmpty: {
      type: Boolean,
      default: false
    },
    previewWidth: {
      type: String,
      default: null
    }
  },
  data() {
    return {
      preview: false,
      rules: [v => this.errorRule(v)],
      // 文字列は初期状態をnullにしないと、''が来た時にwatchが発火しない
      internalValue: this.value,
      dragging: false,
      uploading: false
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
    valid() {
      if (this.value === undefined || this.value === null) {
        return false
      }

      if (this.allowEmpty && this.value === '') {
        return true
      }

      return this.textCount > 0 && this.textCount <= this.textSizeLimit
    },
    showInDetails() {
      return !['', true].includes(this.$attrs['hide-details'])
    },
    previewDisabled() {
      return this.textCount <= 0
    },
    hideLabelArea() {
      return !this.$attrs.label
    },
    classes() {
      return this.dragging ? 'grey lighten-1' : ''
    }
  },
  watch: {
    internalValue() {
      this.$emit('input', this.internalValue)
    },
    value() {
      this.internalValue = this.value
    }
  },
  methods: {
    errorRule(v) {
      if (v === undefined || v === null) {
        return '必須'
      }

      if (v === '') {
        return this.allowEmpty ? true : '必須'
      }

      return this.valid || '文字数オーバー'
    },
    async insertFileLink(files) {
      this.uploading = true

      const link = await this.upload(files[0])

      if (link) {
        const cursorPos = this.$refs.textarea.$refs.input.selectionEnd

        this.internalValue = this.insertString(
          this.internalValue,
          cursorPos,
          `\n![file](${link})\n`
        )
      }

      this.dragging = false
      this.uploading = false
    },
    insertString(str, index, insert) {
      if (!str) {
        return insert
      }

      return str.slice(0, index) + insert + str.slice(index, str.length)
    },
    async upload(file) {
      const params = new FormData()
      params.append('file', file)

      try {
        const res = await this.$axios.post('attachments', params, {
          headers: { 'content-type': 'multipart/form-data' }
        })

        switch (res.status) {
          case 200:
            this.notifySuccess({ message: `アップロードしました` })
            return res.data
          case 400:
          case 401:
            this.notifyWarning({ message: `アップロードに失敗しました` })
            break
          default:
            console.error(res)
            this.notifyError({
              message: `想定外のエラーによりアップロードに失敗しました`
            })
        }
      } catch (e) {
        console.error(e)
        this.notifyError({
          message: `想定外のエラーによりアップロードに失敗しました`
        })
      }

      return null
    }
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

.shrink-top
  ::v-deep
    textarea
      padding-top: 0

.label-margin
  ::v-deep
    textarea
      margin-top: 2px

.show-in-details
  position: relative
  top: -1.7em
  height: 0

.overlay-text
  position: absolute
  left: 50%
  transform: translateX(-50%)
</style>
