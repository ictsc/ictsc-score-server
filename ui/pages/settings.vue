<template>
  <v-container>
    <v-layout column align-center>
      <page-title title="設定" />
    </v-layout>

    <!-- TODO: カテゴリ追加 -->
    <!-- TODO: 問題追加 -->
    <!-- TODO: チーム追加-->

    <v-layout column align-center>
      <export-import-buttons
        label="チーム一覧"
        :fetch="fetchTeams"
        :apply="applyTeam"
        :fields="teamFields"
      />
      <export-import-buttons
        label="カテゴリ一覧"
        :fetch="fetchCategories"
        :apply="applyCategory"
        :fields="categoryFields"
        class="mt-4"
      />
      <export-import-buttons
        label="問題一覧"
        :fetch="fetchProblems"
        :apply="applyProblem"
        :fields="problemFields"
        class="mt-4"
      />
    </v-layout>

    <v-layout column align-center class="mt-8">
      <label>コンテスト設定</label>

      <v-data-table
        :headers="contestInfoHeaders"
        :items="contestInfoItems"
        :items-per-page="1000"
        hide-default-footer
        dense
        class="elevation-1"
      />
    </v-layout>

    <export-scores-button class="mt-8" />
  </v-container>
</template>
<script>
import { mapGetters } from 'vuex'
import orm from '~/orm'
import PageTitle from '~/components/atoms/PageTitle'
import ExportImportButtons from '~/components/settings/ExportImportButtons'
import ExportScoresButton from '~/components/settings/ExportScoresButton'

const contestInfoKeys = [
  'gradingDelayString',
  'hideAllScore',
  'realtimeGrading',
  'textSizeLimit',
  'deleteTimeLimitString',
  'competitionTime'
]

export default {
  name: 'Settings',
  components: {
    ExportImportButtons,
    ExportScoresButton,
    PageTitle
  },
  data() {
    return {
      teamFields: [
        'role',
        'number',
        'name',
        'password',
        'organization',
        'color'
      ],
      categoryFields: ['code', 'title', 'order', 'description'],
      problemFields: [
        'code',
        'categoryCode',
        'title',
        'writer',
        'order',
        'previousProblemCode',
        'teamIsolate',
        'openAtBegin',
        'openAtEnd',
        'perfectPoint',
        'solvedCriterion',
        'secretText',
        'mode',
        'candidates',
        'corrects',
        'text'
      ]
    }
  },
  computed: {
    ...mapGetters('contestInfo', contestInfoKeys),

    contestInfoHeaders() {
      return [{ text: '名前', value: 'name' }, { text: '値', value: 'value' }]
    },
    contestInfoItems() {
      return contestInfoKeys.map(k => ({
        name: k,
        value: JSON.stringify(this[k])
      }))
    }
  },
  methods: {
    async fetchTeams() {
      // パスワードは全てnullになる
      await orm.Team.eagerFetch({}, [])
      return this.sortByNumber(orm.Team.query().all())
    },
    async fetchCategories() {
      await orm.Category.eagerFetch({}, [])
      return this.sortByOrder(orm.Category.query().all())
    },
    async fetchProblems() {
      await orm.Problem.eagerFetch({}, [])
      return this.sortByOrder(
        orm.Problem.query()
          .with(['body', 'category'])
          .all()
      )
    },
    async applyTeam(params) {
      let result = false

      await orm.Team.applyTeam({
        resolve: () => (result = true),
        params: { ...params }
      })

      return result
    },
    async applyCategory(params) {
      let result = false

      await orm.Category.applyCategory({
        resolve: () => (result = true),
        params: { ...params }
      })

      return result
    },
    async applyProblem(params) {
      let result = false

      await orm.Problem.applyProblem({
        resolve: () => (result = true),
        params: { ...params }
      })

      return result
    }
  }
}
</script>
