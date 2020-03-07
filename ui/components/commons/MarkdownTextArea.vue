<!--
マークダウンを書くためのtextarea

機能
* ctrl-enterでsubmitイベントを発火(@submit)
* previewボタンでプレビュー可能
* D&Dでファイルアップロード
-->
<template>
  <div
    :class="classes"
    @drop.prevent="uploadFiles($event.dataTransfer.files)"
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
      dense
      class="pt-1 pb-0"
      v-on="$listeners"
      @keyup.ctrl.enter.prevent="valid && $emit('submit')"
    />

    <v-row
      align="center"
      justify="end"
      :class="{
        'show-details': showDetails,
        'mr-1': showDetails
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

    <!-- 確認モーダル -->
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
      default: '70em'
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
    showDetails() {
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
    async uploadFiles(files) {
      this.uploading = true

      for (const file of files) {
        const { url, type } = await this.upload(file)

        console.log(type)
        if (url) {
          this.insertFileLink(url, type)
        }
      }

      this.dragging = false
      this.uploading = false
    },
    insertFileLink(url, type) {
      const cursorPos = this.$refs.textarea.$refs.input.selectionEnd
      const fileMode = this.isImage(type) ? '![image]' : '[file]'

      this.internalValue = this.insertString(
        this.internalValue,
        cursorPos,
        `\n${fileMode}(${url})\n`
      )
    },
    insertString(str, index, insert) {
      if (!str) {
        return insert
      }

      return str.slice(0, index) + insert + str.slice(index, str.length)
    },
    isImage(type) {
      return type.startsWith('image')
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
            this.notifySuccess({
              message:
                'アップロードしました\nリンクを知る全ての人が参照できます'
            })
            return res.data
          case 400:
          case 401:
            console.error(res)
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
.show-details
  position: relative
  top: -1.7em
  height: 0
</style>
