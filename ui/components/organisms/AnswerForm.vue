<template>
  <v-form ref="form" v-model="valid" @submit.prevent="confirming = true">
    <v-card color="white" elevation="2">
      <v-card-text class="py-0">
        <markdown-text-area
          v-if="problemBody.modeIsTextbox"
          v-model="answerBodies[0][0]"
          :readonly="confirming"
          :placeholder="answerPlaceholder"
          hide-details
          class="pt-2"
        />

        <answer-form-radio-button
          v-else-if="problemBody.modeIsRadioButton"
          v-model="answerBodies"
          :candidates-groups="problemBody.candidates"
          :readonly="confirming"
          class="pb-3"
        />

        <answer-form-checkbox
          v-else-if="problemBody.modeIsCheckbox"
          v-model="answerBodies"
          :candidates-groups="problemBody.candidates"
          :readonly="confirming"
          class="pb-3"
        />

        <template v-else>
          未実装の問題タイプです
        </template>
      </v-card-text>
    </v-card>

    <v-btn
      :disabled="!valid || confirming || waitAnswer"
      type="submit"
      color="success"
      class="mt-2"
      block
    >
      <template v-if="!waitAnswer">
        確認
      </template>
      <template v-else>
        再解答まで{{ latestAnswer.delayFinishInString }}
      </template>
    </v-btn>

    <!-- 解答提出前の強制確認ダイアログ -->
    <v-dialog
      v-model="confirming"
      :persistent="sending"
      scrollable
      max-width="70em"
    >
      <v-card>
        <v-card-title>
          <span>内容確認</span>
        </v-card-title>

        <v-divider></v-divider>
        <v-card-text class="pa-1">
          <markdown :content="confirmContent" />
        </v-card-text>

        <!-- 警告 -->
        <v-divider />
        <ul class="warning lighten-2 py-1 pr-1">
          <template v-if="!realtimeGrading">
            <li>最後に提出された解答のみ採点します</li>
          </template>
          <template v-else-if="gradingDelaySec !== 0">
            <li>解答後{{ gradingDelayString }}間は再解答できなくなります</li>
          </template>

          <li>複数の解答をまたがず1つの解答内に全ての内容を収めてください</li>
        </ul>

        <v-divider></v-divider>
        <v-card-actions>
          <v-spacer />
          <v-btn left :loading="sending" color="success" @click="submit">
            解答
          </v-btn>
          <v-btn left :disabled="sending" @click="confirming = false">
            キャンセル
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </v-form>
</template>
<script>
import { mapGetters } from 'vuex'
import orm from '~/orm'
import AnswerFormRadioButton from '~/components/molecules/AnswerFormRadioButton'
import AnswerFormCheckbox from '~/components/molecules/AnswerFormCheckbox'
import Markdown from '~/components/atoms/Markdown'
import MarkdownTextArea from '~/components/molecules/MarkdownTextArea'

const answerPlaceholder = `解答はマークダウンで記述できます。

お疲れ様です。〇〇です。
問題 XXX の解答を送らせていただきます。

この問題ではxxxxxが原因でトラブルが発生したと考えられました。
そのため、以下のように設定を変更し、○○が正しく動くことを確認いたしました。
確認のほどよろしくお願いします。


## 手順

### 1. /etc/hoge/hoo.bar の編集

\`config.yaml\` の項目をtrueへ変更


### 2. …

`

export default {
  name: 'AnswerForm',
  components: {
    AnswerFormCheckbox,
    AnswerFormRadioButton,
    Markdown,
    MarkdownTextArea
  },
  props: {
    problemBody: {
      type: Object,
      required: true
    },
    latestAnswer: {
      type: Object,
      default: null
    }
  },
  data() {
    return {
      confirming: false,
      valid: false,
      sending: false,
      answerBodies: this.getStorage(),
      answerPlaceholder
    }
  },
  computed: {
    waitAnswer() {
      return (this.$elvis(this.latestAnswer, 'delayFinishInSec') || 0) > 0
    },

    ...mapGetters('contestInfo', [
      'gradingDelaySec',
      'gradingDelayString',
      'realtimeGrading'
    ]),
    ...mapGetters('time', ['currentTimeMsec']),

    confirmContent() {
      if (this.problemBody.modeIsTextbox) {
        return this.answerBodies[0][0]
      } else if (
        this.problemBody.modeIsRadioButton ||
        this.problemBody.modeIsCheckbox
      ) {
        return this.answerBodies
          .map(
            (candidates, index) =>
              `### 選択肢${index + 1}\n` +
              candidates.map(c => `* ${c}\n`).join('\n')
          )
          .join('\n')
      } else {
        throw new Error(`unsupported problem mode ${this.problemBody.mode}`)
      }
    }
  },
  watch: {
    answerBodies(value) {
      this.setStorage(value)
    }
  },
  methods: {
    storageKey() {
      return `answerForm-answerBodies-${this.problemBody.problemId}`
    },
    getStorage() {
      const value = this.$jsonStorage.get(this.storageKey())

      // 有効な値があれば返す. [] '' 0 は有効な値
      if (value !== null && value !== undefined) {
        return value
      }

      if (this.problemBody.modeIsTextbox) {
        this.setStorage([[]])
      } else if (
        this.problemBody.modeIsRadioButton ||
        this.problemBody.modeIsCheckbox
      ) {
        this.setStorage((this.problemBody.candidates || [[]]).map(o => []))
      } else {
        throw new Error(`unsupported problem mode ${this.problemBody.mode}`)
      }

      return this.$jsonStorage.get(this.storageKey())
    },
    setStorage(value) {
      return this.$jsonStorage.set(this.storageKey(), value)
    },
    async submit() {
      this.sending = true

      await orm.Answer.addAnswer({
        action: '解答提出',
        resolve: () => {
          this.confirming = false
          this.answerBodies = this.answerBodies.map(o => [])
          // answerBodiesを空にしたらバリデーションをリセットしないと真っ赤になる
          this.$refs.form.resetValidation()
        },
        params: {
          problemId: this.problemBody.problemId,
          bodies: this.answerBodies
        }
      })

      this.sending = false
    }
  }
}
</script>
