<template>
  <v-form ref="form" @submit.prevent="confirming = true">
    <v-card color="white" elevation="2">
      <v-card-text>
        <!-- TODO: プレースフォルダー -->
        <markdown-text-area
          v-if="problemBody.modeIsTextbox"
          v-model="answerBodies[0][0]"
          :error.sync="error"
          :readonly="confirming"
        />

        <answer-form-radio-button
          v-else-if="problemBody.modeIsRadioButton"
          v-model="answerBodies"
          :error.sync="error"
          :candidates-groups="problemBody.candidates"
          :readonly="confirming"
          class="pb-2"
        />

        <answer-form-checkbox
          v-else-if="problemBody.modeIsCheckbox"
          v-model="answerBodies"
          :error.sync="error"
          :candidates-groups="problemBody.candidates"
          :readonly="confirming"
          class="pb-2"
        />

        <template v-else>
          未実装の問題タイプです
        </template>
      </v-card-text>
    </v-card>

    <v-btn
      :disabled="error || confirming || waitAnswer"
      type="submit"
      color="success"
      class="mt-2"
      block
    >
      <template v-if="!waitAnswer">
        解答
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
      <v-card style="overflow-wrap: break-word">
        <v-card-title>
          <span>内容確認</span>
        </v-card-title>

        <v-divider></v-divider>
        <v-card-text class="pa-1">
          <markdown :content="confirmContent" />
        </v-card-text>

        <template v-if="gradingDelaySec !== 0">
          <v-divider></v-divider>
          <span class="warning pa-1 text-right">
            解答後{{ gradingDelayString }}間は再解答できなくなります
          </span>
        </template>

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
import AnswerFormRadioButton from '~/components/molecules/AnswerFormRadioButton'
import AnswerFormCheckbox from '~/components/molecules/AnswerFormCheckbox'
import Markdown from '~/components/atoms/Markdown'
import MarkdownTextArea from '~/components/molecules/MarkdownTextArea'
import orm from '~/orm'

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
      error: false,
      sending: false,
      answerBodies: this.getStorage()
    }
  },
  computed: {
    waitAnswer() {
      return (this.$elvis(this.latestAnswer, 'delayFinishInSec') || 0) > 0
    },

    ...mapGetters('contestInfo', ['gradingDelaySec', 'gradingDelayString']),
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

      this.setStorage((this.problemBody.candidates || [[]]).map(o => []))
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
