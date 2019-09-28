<template>
  <expandable-card v-model="opened" color="white">
    <!-- カードの帯 -->
    <template v-slot:button>
      <v-row align="center">
        <v-col>
          <span v-if="!realtimeGrading && isPlayer">
            提出済
          </span>
          <span v-else>
            <template v-if="answer.hasPoint">
              得点 {{ answer.point }}
              <v-icon v-if="answer.solved" small>
                mdi-check-bold
              </v-icon>
            </template>
            <template v-else-if="isStaff">
              未採点
            </template>
            <template v-else>
              採点中
            </template>
          </span>
        </v-col>

        <!-- 採点猶予後から10分はタイマーを表示する -->
        <v-col v-if="isStaff && -600 <= answer.delayFinishInSec">
          <span>
            {{ answer.delayFinishInSec | tickDuration('mm:ss') }}
          </span>
        </v-col>
      </v-row>
    </template>

    <!-- 採点フォーム -->
    <template v-if="isStaff">
      <grading-form :answer="answer" :problem-body="problemBody" />
      <v-divider />
    </template>

    <!-- 提出時刻 -->
    <p class="text-right caption">提出時刻: {{ answer.createdAtShort }}</p>

    <!-- 解答本体 -->
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
import { mapGetters } from 'vuex'

import AnswerFormRadioButton from '~/components/problems/id/AnswerFormRadioButton'
import AnswerFormCheckbox from '~/components/problems/id/AnswerFormCheckbox'
import ExpandableCard from '~/components/commons/ExpandableCard'
import GradingForm from '~/components/problems/id/GradingForm'
import Markdown from '~/components/commons/Markdown'

export default {
  name: 'AnswerCard',
  components: {
    AnswerFormCheckbox,
    AnswerFormRadioButton,
    ExpandableCard,
    GradingForm,
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
      opened: null
    }
  },
  computed: {
    ...mapGetters('contestInfo', ['realtimeGrading'])
  },
  created() {
    // dateではcomputed(isStaff)が使えない
    this.opened = this.isStaff && !this.answer.hasPoint
  }
}
</script>
