<template>
  <v-container>
    <!-- TODO: 仮実装 -->
    <v-layout column>
      <v-flex>
        <v-layout column align-center>
          <page-title title="解答一覧" />
        </v-layout>
      </v-flex>

      <v-flex v-for="problem in problems" :key="problem.id">
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
import PageTitle from '~/components/atoms/PageTitle'
import AnswerListCard from '~/components/molecules/AnswerListCard'

// TODO: code, writer, title, statusで検索

export default {
  name: 'Answers',
  components: {
    AnswerListCard,
    PageTitle
  },
  computed: {
    problems() {
      // TODO: bodyが無ければ loading
      // TODO: エラー通知&表示
      const problems = orm.Problem.query()
        .with(['body', 'answers.team', 'answers.score', 'answers.problem.body'])
        .all()

      return this.$_.sortBy(problems, p => this.$elvis(p, 'body.title'))
    }
  },
  fetch() {
    orm.Problem.eagerFetch({}, ['answers'])
  }
}
</script>
