<template>
  <v-layout column>
    <v-flex v-if="isPlayer">
      <answer-form
        :problem-body="problemBody"
        :latest-answer="sortedAnswers[0]"
      />
    </v-flex>
    <!-- TODO: 解答が0のときは何か表示する(特にstaff) -->
    <v-flex v-for="answer in sortedAnswers" :key="answer.id">
      <answer-card :answer="answer" :problem-body="problemBody" />
    </v-flex>
  </v-layout>
</template>
<script>
import AnswerCard from '~/components/organisms/AnswerCard'
import AnswerForm from '~/components/organisms/AnswerForm'
export default {
  name: 'AnswerPanel',
  components: {
    AnswerCard,
    AnswerForm
  },
  props: {
    answers: {
      type: Array,
      required: true
    },
    problemBody: {
      type: Object,
      required: true
    }
  },
  computed: {
    sortedAnswers() {
      return this.sortByCreatedAt(this.answers).reverse()
    }
  }
}
</script>
<style scoped lang="sass"></style>
