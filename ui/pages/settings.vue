<template>
  <v-container fluid :class="background">
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

    <v-layout column align-start class="mt-12 pt-12 white">
      <v-switch
        v-model="showDelete1"
        :label="showDelete1 ? '戻して' : '押すな危険'"
        color="warning"
        hide-details
      />

      <v-switch
        v-show="showDelete1"
        v-model="showDelete2"
        :label="showDelete2 ? '正気か?' : '危ないよ!'"
        color="error"
        class="my-12"
        hide-details
      />

      <delete-component-area v-show="showDelete1 && showDelete2" class="ml-4" />
    </v-layout>
  </v-container>
</template>
<script>
import { mapGetters } from 'vuex'
import orm from '~/orm'
import PageTitle from '~/components/commons/PageTitle'
import ExportImportButtons from '~/components/settings/ExportImportButtons'
import DeleteComponentArea from '~/components/settings/DeleteComponentArea'
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
    DeleteComponentArea,
    ExportScoresButton,
    PageTitle
  },
  data() {
    return {
      showDelete1: false,
      showDelete2: false,

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
    },
    background() {
      if (this.showDelete2 === true) {
        return 'error'
      } else if (this.showDelete1 === true) {
        return 'warning'
      } else {
        return ''
      }
    }
  },
  watch: {
    showDelete1(value) {
      if (value === false) {
        this.showDelete2 = false
      }
    },
    showDelete2(value) {
      if (value === false) {
        this.showDelete1 = false
      }
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
