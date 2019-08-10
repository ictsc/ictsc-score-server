<template>
  <!-- TODO: ここでreadable判定してもいいかも → Loadingしたい -->
  <v-container fluid fill-height grid-list-md>
    <v-layout row>
      <!-- 左の問題詳細パネル -->
      <v-flex :xs6="showRigthPanel">
        <problem-details-panel v-if="problemIsReadable" :problem="problem" />
      </v-flex>

      <!-- 右の質問・解答パネル -->
      <v-flex v-if="showRigthPanel" xs6>
        <v-tabs v-model="tabMode" grow active-class="always-active-color">
          <v-tab replace append :to="'#' + issuesTabName">質問</v-tab>
          <v-tab replace append :to="'#' + answersTabName">解答</v-tab>
        </v-tabs>

        <v-tabs-items v-model="tabMode" class="pt-2">
          <v-tab-item :value="issuesTabName">
            <issue-panel :problem="problem" :team-id="teamId" />
          </v-tab-item>
          <v-tab-item :value="answersTabName">
            <answer-panel :answers="answers" :problem-body="problem.body" />
          </v-tab-item>
        </v-tabs-items>
      </v-flex>
    </v-layout>

    <!-- チーム名 -->
    <v-snackbar :value="isStaff && !!teamId" :timeout="0" color="primary">
      <v-layout justify-center row>
        <v-progress-circular v-if="!team" indeterminate />

        <template v-else>
          <span>{{ team.displayName }}</span>
        </template>
      </v-layout>
    </v-snackbar>
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
  head() {
    return {
      title: this.$elvis(this.problem, 'body.title')
    }
  },
  computed: {
    mode() {
      // URL末尾の #issues=:team_id からモードを判定する
      const match = MODE_REGEXP.exec(this.$route.hash)
      console.log('match')
      console.log(match)
      return match ? match[1] : null
    },
    modeIsBlank() {
      return !this.mode
    },
    answersTabName() {
      return 'answers' + this.hashTailTeamId
    },
    issuesTabName() {
      return 'issues' + this.hashTailTeamId
    },
    problemId() {
      return this.$route.params.id
    },
    teamId() {
      if (this.isPlayer) {
        return this.currentTeamId
      }

      const match = MODE_REGEXP.exec(this.$route.hash)
      return match ? match[3] : null
    },
    hashTailTeamId() {
      // プレイヤーならURL末尾にチームIDを付与しない
      return !this.isPlayer && this.teamId ? `=${this.teamId}` : ''
    },
    problem() {
      // TODO: bodyが無ければ loading
      // TODO: エラー通知&表示
      return orm.Problem.query()
        .with([
          'body',
          'environments.team',
          'supplements',
          'answers.score',
          'answers.problem.body',
          'issues.comments'
        ])
        .find(this.problemId)
    },
    problemIsReadable() {
      // bodyが取得できるなら、公開問題と判断する
      return !!this.elvis(this.problem, 'body')
    },
    showRigthPanel() {
      return this.problemIsReadable && !!this.teamId
    },
    answers() {
      return this.problem.answers.filter(o => o.teamId === this.teamId)
    },
    team() {
      return orm.Team.query().find(this.teamId)
    }
  },
  fetch({ params }) {
    // TODO: bodyが取得できないならエラーにする
    // TODO: modeによって動作を変えたい?(staffの操作が少し軽くなる)

    orm.Problem.eagerFetch(params.id, [
      'environments',
      'supplements',
      'answers',
      'issues'
    ])
  },
  mounted() {
    this.tabMode = this.mode

    // TODO: contestInfoと同時にfetchしたほうがいいかもしれない
    if (!this.isPlayer) {
      orm.Team.eagerFetch()
    }
  }
}
</script>
<style scoped lang="sass">
.always-active-color
  &::before
    opacity: 0.12 !important
</style>
