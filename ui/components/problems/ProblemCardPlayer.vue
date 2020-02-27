<template>
  <!-- TODO: 予選考慮(realtimeGrading) -->
  <v-card-text class="py-2 height-full">
    <template v-if="problem.isReadable">
      <!-- タイトル -->
      <v-row no-gutters class="flex-nowrap">
        <div class="truncate-clamp2" style="height: 3.4em">
          {{ problem.title }}
        </div>
      </v-row>

      <v-divider class="pb-1" />

      <!-- 状態 & 有効得点(有効得点%) & 最高得点 -->
      <v-row no-gutters class="flex-nowrap">
        <v-col cols="auto">
          {{ currentState }}
        </v-col>

        <v-spacer />

        <v-col cols="auto">
          {{ currentScore }}
        </v-col>
      </v-row>

      <!-- (リセット中 | 採点遅延中)の時間 -->
      <v-row no-gutters class="flex-nowrap">
        {{ currentAnswerable }}
      </v-row>
    </template>
    <template v-else>
      <v-row
        no-gutters
        align="center"
        justify="center"
        class="flex-nowrap height-full"
      >
        <v-col cols="auto">
          <v-icon>mdi-lock</v-icon>
        </v-col>

        <v-col class="pl-3 black--text">
          <div v-if="problem.openAtBegin && problem.openAtEnd">
            公開 {{ problem.openAtBegin }}<br />
            終了 {{ problem.openAtEnd }}
          </div>

          <v-row
            v-if="problem.previousProblemId"
            no-gutters
            class="flex-nowrap"
          >
            <v-col class="text-truncate text-right">
              {{ problem.previousProblemTitle }}
            </v-col>
            <v-col>
              の基準を突破
            </v-col>
          </v-row>
        </v-col>
      </v-row>
    </template>
  </v-card-text>
</template>
<script>
export default {
  name: 'ProblemCardPlayer',
  props: {
    hover: {
      type: Boolean,
      default: false
    },
    problem: {
      type: Object,
      required: true
    },
    color: {
      type: String,
      required: true
    }
  },
  computed: {
    scoredAnswers() {
      return this.problem.answers.filter(answer => answer.hasPoint)
    },
    unscoredAnswers() {
      return this.problem.answers.filter(answer => !answer.hasPoint)
    },
    maxScoreAnswer() {
      const answer = this.$_.max(this.scoredAnswers, answer => answer.percent)
      return answer === -Infinity ? null : answer
    },
    // 0以上の値が返る
    latestAnswerDelayFinishInSec() {
      const latestAnswer = this.findNewer(this.problem.answers)
      return latestAnswer ? latestAnswer.delayFinishInSec : 0
    },
    // 0以上の値が返る
    latestPenaltyDelayFinishInSec() {
      const latestPenalty = this.findNewer(this.problem.penalties)
      return latestPenalty ? latestPenalty.delayFinishInSec : 0
    },
    inGrading() {
      return this.latestAnswerDelayFinishInSec > 0
    },
    inResetting() {
      return this.latestPenaltyDelayFinishInSec > 0
    },
    currentScore() {
      // 採点済みの解答が無いなら '---'
      if (this.scoredAnswers.length === 0) {
        return `---/${this.problem.perfectPoint}`
      }

      return `${this.maxScoreAnswer.percent}% ${this.maxScoreAnswer.point}/${this.problem.perfectPoint}点`
    },
    currentState() {
      if (this.inResetting) {
        this.changeColor('warning lighten-2')
        return 'リセット中'
      } else if (this.problem.answers.length === 0) {
        this.changeColor('')
        return '未解答'
      } else if (this.unscoredAnswers.length === 0) {
        this.changeColor('')
        return '採点中'
      } else if (this.maxScoreAnswer && this.maxScoreAnswer.percent >= 100) {
        this.changeColor('success lighten-1')
        return '満点'
      } else {
        this.changeColor('')
        return '解答済み'
      }
      // 未突破 基準突破
    },
    currentAnswerable() {
      // 解答可能か
      if (this.inGrading || this.inResetting) {
        const count = this.timeSimpleStringJp(
          Math.max(
            this.latestAnswerDelayFinishInSec,
            this.latestPenaltyDelayFinishInSec
          )
        )

        return `解答・リセット可能まで${count}`
      } else {
        return '解答・リセット可能'
      }
    }
  },
  methods: {
    changeColor(color) {
      this.$emit('update:color', color)
    }
  }
}
</script>
