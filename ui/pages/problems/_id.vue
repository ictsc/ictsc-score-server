<template>
  <v-container fluid fill-height grid-list-md>
    <v-layout row>
      <v-flex xs6>
        <problem-details-panel v-if="problemIsReadable" :problem="problem" />
        <!-- TODO: デバッグ情報削除 -->
        <p>
          デバッグ情報(そのうち消す)<br />
          問題ID {{ problemId }}<br />
          モード {{ mode }}<br />
          チーム {{ teamId }}
        </p>
      </v-flex>

      <v-flex xs6>
        <!-- TODO: team指定がないときは非表示にする -->
        <v-tabs v-model="tabMode" grow>
          <v-tab append :to="'#' + issuesTabName">質問</v-tab>
          <v-tab append :to="'#' + answersTabName">解答</v-tab>

          <v-tab-item :value="issuesTabName">
            <issue-panel />
          </v-tab-item>

          <v-tab-item :value="answersTabName">
            <answer-panel />
          </v-tab-item>
        </v-tabs>
      </v-flex>
    </v-layout>
  </v-container>
</template>

<script>
import AnswerPanel from '~/components/organisms/AnswerPanel'
import IssuePanel from '~/components/organisms/IssuePanel'
import ProblemDetailsPanel from '~/components/organisms/ProblemDetailsPanel'
import orm from '~/orm'

const MODE_REGEXP = /^#(issues|answers)(=(.*))?$/

export default {
  name: 'Problem',
  components: {
    AnswerPanel,
    IssuePanel,
    ProblemDetailsPanel
  },
  data() {
    return {
      tabMode: null
    }
  },
  computed: {
    mode() {
      // URL末尾の #issues=:team_id からモードを判定する
      const match = MODE_REGEXP.exec(this.$route.hash)
      return match === null ? null : match[1]
    },
    modeIsBlank() {
      return this.mode === null
    },
    answersTabName() {
      return 'answers=' + this.teamId
    },
    issuesTabName() {
      return 'issues=' + this.teamId
    },
    problemId() {
      return this.$route.params.id
    },
    teamId() {
      if (this.isPlayer) {
        return this.currentTeamId
      }

      const match = MODE_REGEXP.exec(this.$route.hash)

      if (match !== null) {
        return match[3]
      } else {
        return null
      }
    },
    problem() {
      // TODO: エラー通知&表示
      return orm.Problem.query()
        .with([
          'body',
          'environments.team',
          'supplements',
          'answers',
          'issues.comments'
        ])
        .find(this.problemId)
    },
    problemIsReadable() {
      // bodyが取得できるなら、公開問題と判断する
      return !!this.elvis(this.problem, 'body')
    }
  },
  fetch({ params }) {
    // TODO: modeによって動作を変えたい?(staffの操作が少し軽くなる)
    orm.Problem.eagerFetch(params.id, [
      'environments',
      'supplements',
      'answers',
      'issues.comments'
    ])
  },
  mounted() {
    this.tabMode = this.mode
  }
}
</script>
<style scoped lang="sass"></style>
