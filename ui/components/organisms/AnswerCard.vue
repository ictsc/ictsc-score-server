<template>
  <expandable-card v-model="opened" color="primary">
    <!-- TODO: ボタンの内容の表示位置を固定したい(縦に揃えたい) -->
    <template v-slot:button>
      <v-layout row align-center>
        <v-flex>
          <span v-if="answer.hasPoint">
            得点 {{ answer.point }}
            <v-icon v-if="$elvis(answer, 'score.solved')" small>
              mdi-check-bold
            </v-icon>
          </span>
          <span v-else-if="isStaff">未採点</span>
          <span v-else>採点中</span>
        </v-flex>

        <!-- 採点猶予後から10分はタイマーを表示する -->
        <v-flex v-if="isStaff && -600 <= answer.delayFinishInSec">
          <span>
            {{ answer.delayFinishInSec | tickDuration('mm:ss') }}
          </span>
        </v-flex>
      </v-layout>
    </template>

    <template v-if="isStaff">
      <grade-form :answer="answer" :problem-body="problemBody" />
      <v-divider />
    </template>

    <div style="text-align: end">提出時刻: {{ answer.createdAt }}</div>
    <markdown
      v-if="problemBody.modeIsTextbox"
      :content="answer.bodies[0][0]"
      readonly
    />

    <answer-form-radio-button
      v-else-if="problemBody.modeIsRadioButton"
      v-model="answer.bodies"
      :candidates-groups="problemBody.candidates"
      readonly
      class="pb-2"
    />

    <answer-form-checkbox
      v-else-if="problemBody.modeIsCheckbox"
      v-model="answer.bodies"
      :candidates-groups="problemBody.candidates"
      readonly
      class="pb-2"
    />

    <template v-else>
      未実装の問題タイプです
    </template>
  </expandable-card>
</template>
<script>
import AnswerFormRadioButton from '~/components/molecules/AnswerFormRadioButton'
import AnswerFormCheckbox from '~/components/molecules/AnswerFormCheckbox'
import ExpandableCard from '~/components/molecules/ExpandableCard'
import GradeForm from '~/components/molecules/GradeForm'
import Markdown from '~/components/atoms/Markdown'

// TODO: 有効得点を目立たせる

export default {
  name: 'AnswerCard',
  components: {
    AnswerFormCheckbox,
    AnswerFormRadioButton,
    ExpandableCard,
    GradeForm,
    Markdown
  },
  props: {
    answer: {
      type: Object,
      required: true
    },
    problemBody: {
      type: Object,
      required: true
    }
  },
  data() {
    return {
      opened: false
    }
  }
}
</script>
