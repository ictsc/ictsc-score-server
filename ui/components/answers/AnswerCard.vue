<template>
  <v-card
    :to="answerURL"
    :color="color"
    width="12em"
    height="5em"
    class="pa-1 pl-2"
  >
    <div class="subtitle-1 text-truncate">
      No.{{ answer.team.number }} {{ answer.team.name }}
    </div>

    <div v-if="answer.hasPoint">{{ answer.percent }}% {{ answer.point }}点</div>
    <div v-else>
      未採点
    </div>

    <div v-if="showTimer">
      {{ answer.delayFinishInSec | tickDuration('mm:ss') }}
    </div>
  </v-card>
</template>
<script>
import { mapGetters } from 'vuex'

export default {
  name: 'AnswerCard',
  props: {
    answer: {
      type: Object,
      required: true
    },
    problem: {
      type: Object,
      required: true
    }
  },
  computed: {
    ...mapGetters('contestInfo', ['realtimeGrading']),

    showTimer() {
      return (
        this.realtimeGrading &&
        this.problem.modeIsTextbox &&
        this.answer.delayFinishInSec >= -600
      )
    },
    answerURL() {
      return `/problems/${this.answer.problemId}#answers=${this.answer.teamId}`
    },
    color() {
      if (this.answer.confirming) {
        if (this.answer.hasPoint) {
          return 'info lighten-1'
        } else {
          return 'purple lighten-3'
        }
      } else if (this.answer.hasPoint) {
        return ''
      } else {
        return 'error lighten-1'
      }
    }
  }
}
</script>
