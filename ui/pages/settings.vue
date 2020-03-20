<template>
  <v-container fluid :class="background" class="px-6">
    <v-row justify="center">
      <page-title title="管理" />
    </v-row>

    <!-- エクスポート・インポート -->
    <v-row justify="center">
      <v-col cols="auto">
        <export-import-buttons
          label="チーム一覧"
          filename-prefix="teams"
          :fetch="fetchTeams"
          :apply="applyTeam"
          :fields="$orm.Team.mutationFieldKeys()"
        />
        <export-import-buttons
          label="カテゴリ一覧"
          filename-prefix="categories"
          :fetch="fetchCategories"
          :apply="applyCategory"
          :fields="categoryFields"
          class="mt-4"
        />
        <export-import-buttons
          label="問題一覧"
          filename-prefix="problems"
          :fetch="fetchProblems"
          :apply="applyProblem"
          :fields="$orm.Problem.mutationFieldKeys()"
          :parallel="false"
          class="mt-4"
        />
        <export-import-buttons
          label="接続情報一覧"
          filename-prefix="environments"
          :fetch="fetchProblemEnvironments"
          :apply="applyProblemEnvironment"
          :fields="$orm.ProblemEnvironment.mutationFieldKeys()"
          class="mt-4"
        />
        <export-import-buttons
          label="設定一覧"
          filename-prefix="configs"
          :fetch="fetchConfigs"
          :apply="updateConfig"
          :fields="configFields"
          class="mt-4"
        />

        <export-scores-button />
      </v-col>
    </v-row>

    <!-- 追加・編集・再採点 -->
    <v-row justify="center">
      <v-col class="fixed-width">
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
          item-text="displayTitle"
          class="mt-4"
        >
          <template v-slot="{ item, isNew }">
            <category-modal value :item="item" :is-new="isNew" />
          </template>
        </item-select-button>

        <item-select-button
          :fetch="fetchProblems"
          label="問題 追加・編集"
          item-text="displayTitle"
          class="mt-4"
        >
          <template v-slot="{ item, isNew }">
            <problem-modal
              value
              :item="reloadProblem(item.id)"
              :is-new="isNew"
            />
          </template>
        </item-select-button>

        <item-select-button
          :fetch="fetchProblems"
          :prepend-new-item="false"
          label="再採点"
          item-text="displayTitle"
          class="mt-4"
        >
          <template v-slot="{ item }">
            <regrade-answers-modal value :problem="item" />
          </template>
        </item-select-button>
      </v-col>
    </v-row>

    <!-- コンテスト設定 -->
    <v-row justify="center" no-gutters class="mt-8">
      <v-col class="fixed-width">
        <label>コンテスト設定</label>
        <config-table />
      </v-col>
    </v-row>

    <!-- セッション一覧 -->
    <v-row justify="center" no-gutters class="mt-8">
      <v-col class="fixed-width">
        <label>有効なセッション一覧</label>
        <session-table />
      </v-col>
    </v-row>

    <!-- 削除系 -->
    <v-row justify="start" class="mt-12 px-2 white" no-gutters>
      <v-col>
        <v-switch
          v-model="showDelete1"
          :label="showDelete1 ? '戻して' : '押すな危険'"
          color="warning"
          hide-details
          class="mt-12"
        />

        <v-switch
          v-show="showDelete1"
          v-model="showDelete2"
          :label="showDelete2 ? '寝ぼけてない?' : '危ないよ!'"
          color="error"
          class="my-12"
          hide-details
        />

        <v-row justify="center" no-gutters>
          <v-col class="fixed-width">
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
import SessionTable from '~/components/settings/SessionTable'
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
    SessionTable,
    TeamModal
  },
  data() {
    return {
      showDelete1: false,
      showDelete2: false,

      categoryFields: ['code', 'title', 'order', 'description'],
      configFields: ['key', 'value']
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
      await orm.Queries.teams()
      return this.sortByNumber(orm.Team.all())
    },
    async fetchCategories() {
      await orm.Queries.categories()
      return this.sortByOrder(orm.Category.all())
    },
    async fetchConfigs() {
      await orm.Queries.configs()
      return this.$_.sortBy(orm.Config.all(), 'key')
    },
    async fetchProblems() {
      await orm.Queries.problemsCategory()
      return this.sortByOrder(
        orm.Problem.query()
          .with(['body', 'category', 'previousProblem'])
          .all()
      )
    },
    async fetchProblemEnvironments() {
      await orm.Queries.problemEnvironmentsTeamProblem()

      return this.sortByOrder(
        orm.ProblemEnvironment.query()
          .with(['problem', 'team'])
          .all()
      )
    },
    // item-select-buttonを通すと一部リアクティブじゃなくなる
    reloadProblem(id) {
      return orm.Problem.query()
        .with(['body', 'category', 'previousProblem'])
        .find(id)
    },
    async applyTeam(params) {
      let result = false

      await orm.Mutations.applyTeam({
        resolve: () => (result = true),
        params: { ...params, silent: true }
      })

      return result
    },
    async applyCategory(params) {
      let result = false

      await orm.Mutations.applyCategory({
        resolve: () => (result = true),
        params: { ...params, silent: true }
      })

      return result
    },
    async applyProblem(params) {
      let result = false

      await orm.Mutations.applyProblem({
        resolve: () => (result = true),
        params: { ...params, silent: true }
      })

      return result
    },
    async applyProblemEnvironment(params) {
      let result = false

      await orm.Mutations.applyProblemEnvironment({
        resolve: () => (result = true),
        params: { ...params, silent: true }
      })

      return result
    },
    async updateConfig(params) {
      let result = false

      await orm.Mutations.updateConfig({
        resolve: () => (result = true),
        params: { ...params }
      })

      return result
    }
  }
}
</script>
<style scoped lang="sass">
.fixed-width
  min-width: 34em
  max-width: 34em
</style>
