<template>
  <v-container>
    <h2>解答一覧</h2>
    <!-- TODO: 仮実装 -->

    <v-layout column>
      <v-flex v-for="problem in problems" :key="problem.id">
        <v-divider class="mb-1" />
        <v-layout column>
          <v-flex>
            <h2>{{ problem.body.title }}</h2>
          </v-flex>

          <v-container fluid grid-list-md>
            <v-layout wrap>
              <v-flex v-for="answer in problem.answers" :key="answer.id" shrink>
                <answer-list-card :answer="answer" />
              </v-flex>
            </v-layout>
          </v-container>
        </v-layout>
      </v-flex>
    </v-layout>
  </v-container>
</template>
<script>
import orm from '~/orm'
import AnswerListCard from '~/components/molecules/AnswerListCard'

export default {
  name: 'Answers',
  components: {
    AnswerListCard
  },
  computed: {
    problems() {
      // TODO: bodyが無ければ loading
      // TODO: エラー通知&表示
      return orm.Problem.query()
        .with(['body', 'answers.team', 'answers.score', 'answers.problem.body'])
        .all()
    }
  },
  fetch() {
    orm.Problem.eagerFetch({}, ['answers'])
  }
}
</script>
