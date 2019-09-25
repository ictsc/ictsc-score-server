<template>
  <v-container>
    <v-layout column align-center>
      <page-title title="解答一覧" />

      <v-switch
        v-model="showAll"
        :label="showAll ? '全表示' : '未採点のみ'"
        hide-details
      />

      <v-select
        v-model="problemCode"
        :items="problems"
        clearable
        hide-details
        item-text="title"
        item-value="code"
        label="問題名"
        class="pb-3"
      />
    </v-layout>

    <!-- 一覧 -->
    <v-container>
      <v-layout v-for="problem in problems" :key="problem.id">
        <div v-show="isDisplayProblem(problem)" class="mb-4">
          <div class="title">{{ problem.code }} {{ problem.body.title }}</div>

          <v-row class="mx-0" justify="start" align="start">
            <template v-for="answer in filter(problem.answers)">
              <answer-card
                v-show="isDisplayAnswer(answer)"
                :key="answer.id"
                :answer="answer"
                :problem="problem"
                class="ma-1"
              />
            </template>

            <v-spacer />
          </v-row>
        </div>
      </v-layout>
    </v-container>
  </v-container>
</template>
<script>
import orm from '~/orm'
import { JsonStroage } from '~/plugins/json-storage'
import PageTitle from '~/components/commons/PageTitle'
import AnswerCard from '~/components/answers/AnswerCard'

export default {
  name: 'Answers',
  components: {
    AnswerCard,
    PageTitle
  },
  mixins: [
    // 透過的にローカルストレージにアクセスできる
    JsonStroage.accessor('answer-list', 'showAll', true),
    JsonStroage.accessor('answer-list', 'problemCode', undefined)
  ],
  computed: {
    problems() {
      const problems = orm.Problem.query()
        .with(['body', 'answers', 'answers.team'])
        .all()

      return this.$_.sortBy(problems, p => this.$elvis(p, 'body.title'))
    }
  },
  fetch() {
    orm.Problem.eagerFetch({}, ['answers', 'team'])
    orm.Team.eagerFetch({}, [])
  },
  methods: {
    // 各チームの最終解答のみの配列にする
    shrinkAnswers(answers) {
      const teamsAnswers = this.$_.groupBy(answers, answer => answer.teamId)

      // TODO: 本戦では未採点の最も古い解答を出すべき
      // そのチームの複数解答を最も新しい解答1つに上書き
      return Object.keys(teamsAnswers).map(teamId =>
        this.findNewer(teamsAnswers[teamId])
      )
    },
    filterAnswers(answers) {
      const result = this.shrinkAnswers(answers)

      return result
    },
    sortByTeamNumber(answers) {
      return this.$_.sortBy(answers, a => a.team.number)
    },
    filter(answers) {
      return this.sortByTeamNumber(this.filterAnswers(answers))
    },
    isDisplayAnswer(answer) {
      return this.showAll || !answer.hasPoint
    },
    isDisplayProblem(problem) {
      if (!this.problemCode) {
        return true
      }

      return problem.code === this.problemCode
    }
  }
}
</script>
