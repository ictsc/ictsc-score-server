<template>
  <v-container fluid :class="background">
    <v-row justify="center">
      <page-title title="管理" />
    </v-row>

    <!-- エクスポート・インポート -->
    <v-row justify="center">
      <v-col cols="auto">
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
        <export-import-buttons
          label="設定一覧"
          :fetch="fetchConfigs"
          :apply="updateConfig"
          :fields="configFields"
          class="mt-4"
        />

        <export-scores-button />
      </v-col>
    </v-row>

    <!-- 追加・編集 -->
    <v-row justify="center" class="mt-8">
      <v-col cols="6">
        <item-select-button
          :fetch="fetchTeams"
          label="チーム 追加・編集"
          item-text="displayName"
        >
          <template v-slot="{ item, isNew }">
            <team-modal value :item="item" :is-new="isNew" />
          </template>
        </item-select-button>

        <item-select-button
          :fetch="fetchCategories"
          label="カテゴリ 追加・編集"
          item-text="title"
          class="mt-4"
        >
          <template v-slot="{ item, isNew }">
            <category-modal value :item="item" :is-new="isNew" />
          </template>
        </item-select-button>

        <item-select-button
          :fetch="fetchProblems"
          label="問題 追加・編集"
          item-text="title"
          class="mt-4"
        >
          <template v-slot="{ item, isNew }">
            <problem-modal value :item="item" :is-new="isNew" />
          </template>
        </item-select-button>
      </v-col>
    </v-row>

    <!-- 再採点 -->
    <v-row justify="center">
      <v-col cols="6" class="pt-1">
        <item-select-button
          :fetch="fetchProblems"
          :prepend-new-item="false"
          label="再採点"
          item-text="title"
        >
          <template v-slot="{ item }">
            <regrade-answers-modal value :problem="item" />
          </template>
        </item-select-button>
      </v-col>
    </v-row>

    <v-row justify="center" class="mt-8">
      <v-col cols="auto">
        <label>コンテスト設定</label>
        <config-table />
      </v-col>
    </v-row>

    <v-row justify="start" class="mt-12 pt-12 white">
      <v-col>
        <v-switch
          v-model="showDelete1"
          :label="showDelete1 ? '戻して' : '押すな危険'"
          color="warning"
          hide-details
        />

        <v-switch
          v-show="showDelete1"
          v-model="showDelete2"
          :label="showDelete2 ? '寝ぼけてない?' : '危ないよ!'"
          color="error"
          class="my-12"
          hide-details
        />

        <v-row justify="center">
          <v-col cols="6">
            <delete-component-area v-show="showDelete1 && showDelete2" />
          </v-col>
        </v-row>
      </v-col>
    </v-row>
  </v-container>
</template>
<script>
import orm from '~/orm'

import CategoryModal from '~/components/misc/CategoryModal'
import ConfigTable from '~/components/settings/ConfigTable'
import DeleteComponentArea from '~/components/settings/DeleteComponentArea'
import ExportImportButtons from '~/components/settings/ExportImportButtons'
import ExportScoresButton from '~/components/settings/ExportScoresButton'
import ItemSelectButton from '~/components/settings/ItemSelectButton'
import PageTitle from '~/components/commons/PageTitle'
import ProblemModal from '~/components/misc/ProblemModal'
import RegradeAnswersModal from '~/components/settings/RegradeAnswersModal'
import TeamModal from '~/components/misc/TeamModal'

export default {
  name: 'Settings',
  components: {
    CategoryModal,
    ConfigTable,
    DeleteComponentArea,
    ExportImportButtons,
    ExportScoresButton,
    ItemSelectButton,
    PageTitle,
    ProblemModal,
    RegradeAnswersModal,
    TeamModal
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
      configFields: ['key', 'value'],
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
      return this.sortByNumber(orm.Team.all())
    },
    async fetchCategories() {
      await orm.Category.eagerFetch({}, [])
      return this.sortByOrder(orm.Category.all())
    },
    async fetchConfigs() {
      await orm.Config.eagerFetch({}, [])
      return this.$_.sortBy(orm.Config.all(), 'key')
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

      await orm.Mutation.applyTeam({
        resolve: () => (result = true),
        params: { ...params }
      })

      return result
    },
    async applyCategory(params) {
      let result = false

      await orm.Mutation.applyCategory({
        resolve: () => (result = true),
        params: { ...params }
      })

      return result
    },
    async applyProblem(params) {
      let result = false

      await orm.Mutation.applyProblem({
        resolve: () => (result = true),
        params: { ...params }
      })

      return result
    },
    async updateConfig(params) {
      let result = false

      await orm.Mutation.updateConfig({
        resolve: () => (result = true),
        params: { ...params }
      })

      return result
    }
  }
}
</script>
