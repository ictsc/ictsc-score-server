<template>
  <!-- TODO: 仮実装 -->
  <v-card :to="answerURL" width="12em" height="4em" class="pa-1" :color="color">
    <div class="subtitle-1 text-truncate">
      No.{{ answer.team.number }} {{ answer.team.name }}
    </div>

    <div v-if="answer.hasPoint">{{ answer.point }}点</div>
    <div v-else>
      未採点
    </div>

    <div v-if="showTimer">
      {{ answer.delayFinishInSec | tickDuration('mm:ss') }}
    </div>
  </v-card>
</template>
<script>
export default {
  name: 'AnswerListCard',
  props: {
    answer: {
      type: Object,
      required: true
    }
  },
  data() {
    return {
      showTimer: this.answer.delayFinishInSec >= -600
    }
  },
  computed: {
    answerURL() {
      return `/problems/${this.answer.problemId}#answers=${this.answer.teamId}`
    },
    color() {
      return this.answer.hasPoint ? '' : 'error'
    }
  }
}
</script>
