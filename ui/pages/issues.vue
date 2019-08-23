<template>
  <v-container>
    <v-layout column align-center>
      <page-title title="質問一覧" />

      <v-flex class="mb-4">
        <!-- 状態選択ボタン -->
        <issue-status-select-buttons
          v-model="displayStatuses"
          red="unsolved"
          yellow="in_progress"
          green="solved"
        />

        <!-- 検索ボックス -->
        <v-text-field
          v-model="issueSearch"
          :placeholder="searchFieldPlaceholder"
          autofocus
          clearable
          append-icon="mdi-magnify"
          single-line
          hide-details
          class="mb-2"
        />
      </v-flex>

      <!-- 質問一覧 -->
      <v-flex>
        <issue-list-card
          v-for="issue in issues"
          :key="issue.id"
          :issue="issue"
          class="mb-2"
        />
      </v-flex>
    </v-layout>
  </v-container>
</template>
<script>
import orm from '~/orm'
import { JsonStroage } from '~/plugins/json-storage'
import PageTitle from '~/components/atoms/PageTitle'
import IssueStatusSelectButtons from '~/components/molecules/IssueStatusSelectButtons'
import IssueListCard from '~/components/molecules/IssueListCard'

export default {
  name: 'Issues',
  components: {
    PageTitle,
    IssueStatusSelectButtons,
    IssueListCard
  },
  mixins: [
    // 透過的にローカルストレージにアクセスできる
    JsonStroage.accessor('issue-list', 'displayStatuses', [
      'unsolved',
      'in_progress',
      'solved'
    ]),
    JsonStroage.accessor('issue-list', 'issueSearch', '')
  ],
  computed: {
    // computedを分ければ軽くなるはず?
    allIssues() {
      return orm.Issue.query()
        .with(['comments', 'problem.body', 'team'])
        .all()
    },
    statusFilteredIssues() {
      return this.allIssues.filter(i => this.displayStatuses.includes(i.status))
    },
    // 検索は一瞬で終わるが、描画が遅い
    issues() {
      const issues = this.statusFilteredIssues.filter(i => this.issueFilter(i))
      return this.$_.sortBy(issues, i => this.$elvis(i, 'problem.body.title'))
    },
    searchFieldPlaceholder() {
      return this.isStaff ? '問題名 コード 作問者 チーム名' : '問題名'
    },
    searchParams() {
      if (['', null, undefined].includes(this.issueSearch)) {
        return []
      }

      return this.issueSearch.split(' ').map(s => this.stringSimplify(s))
    }
  },
  fetch() {
    orm.Problem.eagerFetch({}, ['issues'])
  },
  methods: {
    issueFilter(issue) {
      return this.searchParams.every(param =>
        this.issueSummary(issue).includes(param)
      )
    },
    issueSummary(issue) {
      return [
        this.$elvis(issue, 'team.name'),
        this.$elvis(issue, 'team.numberStr'),
        this.$elvis(issue, 'problem.code'),
        this.$elvis(issue, 'problem.writer'),
        this.$elvis(issue, 'problem.body.title')
      ]
        .filter(e => e !== null && e !== undefined)
        .map(s => this.stringSimplify(s))
        .join(' ')
    },
    stringSimplify(str) {
      return str.replace(/-|_/g, '').toLowerCase()
    }
  }
}
</script>
