<template>
  <v-layout column align-center>
    <label>成績出力</label>
    <v-btn :loading="loading" small @click="exportData">
      エクスポート
      <v-icon>mdi-file-export</v-icon>
    </v-btn>
  </v-layout>
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
    async fetch() {
      await orm.Problem.eagerFetch({}, ['answers'])
      await orm.Team.eagerFetch({}, [])

      this.problems = this.sortByOrder(
        orm.Problem.query()
          .with(['body', 'answers.score', 'answers.team'])
          .all()
      )
      this.teams = this.sortByOrder(orm.Team.query().all())
    },
    async exportData() {
      this.loading = true
      await this.fetch()

      /// problems[0].answers[teamId] == 最終提出解答
      this.problems.forEach(p => {
        // この問題の解答をチーム毎に分ける
        const grouped = this.$_.groupBy(p.answers, a => a.teamId)

        Object.keys(grouped).forEach(teamId => {
          // この問題の最終解答のみ取り出す
          const latest = this.$_.max(
            grouped[teamId],
            a => new Date(a.createdAt)
          )

          // 得点に換算
          // TODO: 本当なnullなら警告を出す必要がある
          grouped[teamId] = Math.floor(
            (p.body.perfectPoint * (this.$elvis(latest, 'score.point') || 0)) /
              100
          )
        })

        p.answers = grouped
      })

      /*
        {
          '問題名' : [
            { team: 'Team名', point: 999 },
            ...
          ],
          ...
        }
      */

      // 未提出なら0ではなくnullになる
      const data = this.problems.reduce((obj, problem) => {
        obj[problem.body.title] = this.teams.map(team =>
          this.buildField(team, problem)
        )

        obj[problem.body.title].unshift([
          { team: '満点', point: problem.body.perfectPoint }
        ])
        return obj
      }, {})

      this.download('text/json', `成績一覧.json`, JSON.stringify(data))
      this.loading = false
    },
    buildField(team, problem) {
      const point = problem.answers[team.id]

      return {
        team: team.name,
        point: point === undefined ? null : point
      }
    },
    // TODO: ExportImportButtonsから切り出してmixinsに移す
    download(type, filename, data) {
      const blob = new Blob([data], { type })
      const link = document.createElement('a')
      link.href = window.URL.createObjectURL(blob)
      link.download = filename
      link.click()
    }
  }
}
</script>
