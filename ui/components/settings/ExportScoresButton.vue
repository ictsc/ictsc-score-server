<template>
  <v-col>
    <v-row justify="start">
      <label>成績出力</label>
    </v-row>

    <v-row justify="start">
      <v-btn :loading="loading" small @click="exportData">
        エクスポート
        <v-icon>mdi-file-export</v-icon>
      </v-btn>
    </v-row>
  </v-col>
</template>
<script>
import orm from '~/orm'

export default {
  name: 'ExportImportButtons',
  data() {
    return {
      loading: false,
      problems: [],
      teams: []
    }
  },
  methods: {
    // TODO: API側に持ってくる
    async fetch() {
      await orm.Queries.problemsAnswers()
      await orm.Queries.teams()

      this.problems = this.sortByOrder(
        orm.Problem.query()
          .with(['body', 'answers.team'])
          .all()
      )

      this.teams = this.sortByNumber(orm.Team.playersWithoutTeam99)
    },
    async exportData() {
      this.loading = true
      await this.fetch()

      let ungradedCount = 0

      // 各問題の解答を1チーム1つにする(得点)
      // problems[0].answers[teamId] == 最終提出解答得点
      // { '問題名' : [{ team: 'Team名', point: 999 }, ...], ... }
      this.problems.forEach(problem => {
        // この問題の解答をチーム毎に分ける
        // { teamId: [ans1, ans2, ...], ... }
        const grouped = this.$_.groupBy(problem.answers, a => a.teamId)

        problem.answers = Object.keys(grouped).reduce((answers, teamId) => {
          const latestAnswer = this.findEffectAnswer(grouped[teamId])

          // 未採点ならマズイので警告
          if (!latestAnswer.hasScore) {
            ungradedCount += 1
            const team = orm.Team.find(teamId)
            console.warn(
              `未採点 問題: ${problem.title}, チーム: ${team.displayName}`
            )
          }

          answers[teamId] = latestAnswer.point
          return answers
        }, {})
      })

      if (ungradedCount !== 0) {
        this.notifyWarning({
          message: `有効解答の内 ${ungradedCount}件が未採点です`
        })
      }

      // 未提出,未採点なら0ではなくnullになる
      const data = this.problems.reduce((obj, problem) => {
        // 解答をチームでイテレーションする
        obj[problem.title] = this.teams.map(team =>
          this.buildField(team, problem)
        )

        obj[problem.title].unshift({
          team: '満点',
          point: problem.perfectPoint
        })

        return obj
      }, {})

      this.download(
        'text/json',
        `scores ${this.currentDateTimeString()}.json`,
        JSON.stringify(data)
      )
      this.loading = false
    },
    buildField(team, problem) {
      const point = problem.answers[team.id]

      return {
        team: team.name,
        // 解答がないならundefinedになる
        point: point === undefined ? null : point
      }
    }
  }
}
</script>
