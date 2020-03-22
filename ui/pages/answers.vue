<template>
  <v-container>
    <v-row justify="center">
      <v-col cols="auto" align="center" class="pt-0">
        <page-title title="解答一覧" />

        <v-overflow-btn
          v-model="problemDisplayTitle"
          :items="problems"
          item-text="displayTitle"
          item-value="displayTitle"
          label="問題選択"
          auto-select-first
          clearable
          editable
          dense
          hide-details
          class="mt-0"
        />

        <display-toggle-buttons v-model="displayToggle" class="mt-4" />
      </v-col>
    </v-row>

    <!-- 一覧 -->
    <v-container>
      <div v-for="problem in problems" :key="problem.id">
        <div v-show="isDisplayProblem(problem)" class="mb-4">
          <div class="title pl-2">{{ problem.displayTitle }}</div>

          <v-row align="start" justify="start" class="mx-0">
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
      </div>
    </v-container>
  </v-container>
</template>
<script>
import { mapGetters } from 'vuex'
import orm from '~/orm'
import { JsonStroage } from '~/plugins/json-storage'
import PageTitle from '~/components/commons/PageTitle'
import AnswerCard from '~/components/answers/AnswerCard'
import DisplayToggleButtons from '~/components/answers/DisplayToggleButtons'

export default {
  name: 'Answers',
  components: {
    AnswerCard,
    DisplayToggleButtons,
    PageTitle
  },
  mixins: [
    // 透過的にローカルストレージにアクセスできる
    JsonStroage.accessor('answer-list', 'displayToggle', []),
    JsonStroage.accessor('answer-list', 'problemDisplayTitle', undefined)
  ],
  fetch() {
    orm.Queries.problemsAnswersTeam()
  },
  computed: {
    ...mapGetters('contestInfo', ['realtimeGrading']),

    problems() {
      const problems = orm.Problem.query()
        .with(['body', 'category', 'answers', 'answers.team'])
        .all()

      return problems.sort((a, b) => this.compareOrder(a, b))
    }
  },
  methods: {
    compareOrder(a, b) {
      const aCO = this.$elvis(a, 'category.order')
      const bCO = this.$elvis(b, 'category.order')

      if (aCO < bCO) return -1
      if (aCO > bCO) return 1
      if (a.order < b.order) return -1
      if (a.order > b.order) return 1
      return 0
    },

    // 各チームの最終解答のみの配列にする
    shrinkAnswers(answers) {
      // teamIdをキーとしたanswerの配列
      const teamsAnswers = this.$_.groupBy(answers, answer => answer.teamId)

      // TODO: 本戦では未採点の最も古い解答を出すべき

      // そのチームの複数解答を最も新しい解答1つに上書き
      if (this.realtimeGrading) {
        // 未採点の最も古い解答 or 最高得点
        return Object.keys(teamsAnswers).map(teamId => {
          const unscoredAnswers = teamsAnswers[teamId].filter(
            answer => !answer.hasPoint
          )

          if (unscoredAnswers.length === 0) {
            return this.$_.max(teamsAnswers[teamId], answer => answer.percent)
          } else {
            return this.findOlder(unscoredAnswers)
          }
        })
      } else {
        // 最新の解答
        return Object.keys(teamsAnswers).map(teamId =>
          this.findNewer(teamsAnswers[teamId])
        )
      }
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
      if (this.displayToggle.includes('onlyHasNotPoint')) {
        if (answer.hasPoint) {
          return false
        } else {
          return this.displayToggle.includes('onlyConfirming')
            ? answer.confirming
            : true
        }
      } else {
        return this.displayToggle.includes('onlyConfirming')
          ? answer.confirming
          : true
      }
    },
    isDisplayProblem(problem) {
      if (!this.problemDisplayTitle) {
        return true
      }

      return problem.displayTitle === this.problemDisplayTitle
    }
  }
}
</script>
