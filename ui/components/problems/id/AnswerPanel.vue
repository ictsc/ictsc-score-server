<template>
  <div>
    <answer-form
      v-if="isPlayer"
      :problem="problem"
      :waiting-submit-sec="waitingSubmitSec"
      class="mb-1"
    />

    <answer-card
      v-for="answer in sortedAnswers"
      :key="answer.id"
      :answer="answer"
      :problem="problem"
      class="mb-1"
    />
  </div>
</template>
<script>
import AnswerCard from '~/components/problems/id/AnswerCard'
import AnswerForm from '~/components/problems/id/AnswerForm'
export default {
  name: 'AnswerPanel',
  components: {
    AnswerCard,
    AnswerForm,
  },
  props: {
    answers: {
      type: Array,
      required: true,
    },
    problem: {
      type: Object,
      required: true,
    },
    waitingSubmitSec: {
      type: Number,
      required: true,
    },
  },
  computed: {
    sortedAnswers() {
      return this.sortByCreatedAt(this.answers).reverse()
    },
  },
}
</script>
