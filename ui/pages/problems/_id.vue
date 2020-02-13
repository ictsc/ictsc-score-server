<template>
  <v-container fluid grid-list-md>
    <v-row v-if="problemIsReadable">
      <!-- 左の問題詳細パネル -->
      <v-col cols="6">
        <details-panel :problem="problem" />
      </v-col>

      <!-- 右の質問・解答パネル -->
      <v-col cols="6">
        <!-- チーム名&セレクタ -->
        <v-overflow-btn
          v-if="isNotPlayer"
          v-model="selectedTeamId"
          :loading="teamFetching"
          :items="teams"
          item-text="displayName"
          item-value="id"
          label="チーム選択"
          auto-select-first
          clearable
          editable
          dense
          hide-details
          class="mt-0 mb-2"
          @focus="fetchTeams"
        />

        <v-tabs v-model="currentTab" grow active-class="always-active-color">
          <v-tabs-slider></v-tabs-slider>
          <v-tab replace append :to="'#' + answersTabName">解答</v-tab>
          <v-tab replace append :to="'#' + issuesTabName">質問</v-tab>
        </v-tabs>

        <v-tabs-items
          v-if="teamId"
          v-model="currentTab"
          class="pt-4 transparent"
        >
          <v-tab-item :value="answersTabName">
            <answer-panel :answers="answers" :problem-body="problem.body" />
          </v-tab-item>
          <v-tab-item :value="issuesTabName">
            <issue-panel :problem="problem" :team-id="teamId" />
          </v-tab-item>
        </v-tabs-items>
      </v-col>
    </v-row>
  </v-container>
</template>
<script>
import AnswerPanel from '~/components/problems/id/AnswerPanel'
import IssuePanel from '~/components/problems/id/IssuePanel'
import DetailsPanel from '~/components/problems/id/DetailsPanel'
import orm from '~/orm'

const MODE_REGEXP = /^#(issues|answers)(=(.*))?$/

export default {
  name: 'Problem',
  components: {
    AnswerPanel,
    IssuePanel,
    DetailsPanel
  },
  fetch({ params }) {
    orm.Queries.problemMisc(params.id)
  },
  data() {
    return {
      selectedTeamId: null,
      currentTab: null,
      teamFetching: false,
      teamFetched: false
    }
  },
  computed: {
    teamId() {
      if (this.isPlayer) {
        return this.currentTeamId
      }

      const match = MODE_REGEXP.exec(this.$route.hash)
      return match ? match[3] : null
    },
    tabMode() {
      // URL末尾の #issues=:team_id からモードを判定する
      const match = MODE_REGEXP.exec(this.$route.hash)
      return match ? match[1] : null
    },
    modeIsBlank() {
      return !this.tabMode
    },
    answersTabName() {
      return 'answers' + this.hashTailTeamId()
    },
    issuesTabName() {
      return 'issues' + this.hashTailTeamId()
    },
    problemId() {
      return this.$route.params.id
    },
    problem() {
      // 編集モーダルや各表示部で使うデータを結合する
      // categoryとpreviousProblemは編集モーダルで必要
      return orm.Problem.query()
        .with([
          'category',
          'body',
          'previousProblem',
          'environments.team',
          'supplements',
          'answers',
          'issues.comments'
        ])
        .find(this.problemId)
    },
    problemIsReadable() {
      return this.problem && this.problem.isReadable
    },
    answers() {
      return this.problem.answers.filter(o => o.teamId === this.teamId)
    },
    teams() {
      return this.sortByNumber(orm.Team.players)
    }
  },
  watch: {
    selectedTeamId(value) {
      this.$router
        .replace({
          name: this.$route.name,
          params: this.$route.params,
          hash: `#${this.tabMode}${this.hashTailTeamId()}`
        })
        .catch(err => {
          if (err.name !== 'NavigationDuplicated') {
            console.error(err)
          }
        })
    }
  },
  mounted() {
    // dataではisPlayerが使えないためここでセット
    this.selectedTeamId = this.teamId
    this.currentTab = this.tabMode
  },
  methods: {
    hashTailTeamId() {
      // プレイヤーならURL末尾にチームIDを付与しない
      // playerではselectedTeamId === currentTeamId

      // fetchCurrentSession中だとrole判定ができないので応急処置
      return (!this.currentTeamId || this.isNotPlayer) && this.selectedTeamId
        ? `=${this.selectedTeamId}`
        : ''
    },
    async fetchTeams() {
      if (this.teamFetched) {
        return
      }

      this.teamFetching = true
      await orm.Queries.teams()
      this.teamFetching = false
      this.teamFetched = true
    }
  },
  head() {
    return {
      title: this.$elvis(this.problem, 'body.title')
    }
  }
}
</script>
