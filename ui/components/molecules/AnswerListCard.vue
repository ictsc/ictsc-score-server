<template>
  <!-- TODO: 仮実装 -->
  <v-card :to="answerURL" width="12em" height="4em" class="pa-1">
    <div class="subtitle-1 text-truncate">
      No.{{ answer.team.number }} {{ answer.team.name }}
    </div>
    <div v-if="-600 <= answer.delayFinishInSec">
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
  computed: {
    answerURL() {
      return `/problems/${this.answer.problemId}#answers=${this.answer.teamId}`
    }
  }
}
</script>
