<template>
  <v-container>
    <!-- 問題・カテゴリ追加ボタン -->
    <v-col v-if="isStaff" cols="auto" class="floating-area-100 top-right pa-0">
      <v-btn
        block
        color="primary"
        class="elevation-4 my-2"
        @click="showProblemModal = true"
      >
        <v-row align="center" justify="start">
          <v-icon>mdi-plus</v-icon>
          <span class="text-left">
            問題追加
          </span>
        </v-row>
      </v-btn>

      <v-btn
        block
        color="primary"
        class="elevation-4"
        @click="showCategoryModal = true"
      >
        <v-row align="center" justify="start">
          <v-icon>mdi-plus</v-icon>
          <span class="text-left">
            カテゴリ追加
          </span>
        </v-row>
      </v-btn>
    </v-col>

    <!-- モーダル -->
    <!-- エラー防止のためにモーダルをレンダリングしない -->
    <template v-if="isStaff">
      <!-- 開いた時にデータを再度fetchさせるため -->
      <problem-modal
        v-if="showProblemModal"
        v-model="showProblemModal"
        is-new
      />
      <category-modal
        v-if="showCategoryModal"
        v-model="showCategoryModal"
        is-new
      />
    </template>

    <v-row justify="center">
      <page-title title="問題一覧" />
    </v-row>

    <flow v-if="realtimeGrading" />
    <attention />

    <div v-for="category in categories" :key="category.id">
      <v-divider class="my-2" />
      <category :category="category" />
    </div>
  </v-container>
</template>
<script>
import { mapGetters } from 'vuex'
import PageTitle from '~/components/commons/PageTitle'
import Attention from '~/components/problems/Attention'
import Flow from '~/components/problems/Flow'
import CategoryModal from '~/components/misc/CategoryModal'
import Category from '~/components/problems/Category'
import ProblemModal from '~/components/misc/ProblemModal'
import orm from '~/orm'

export default {
  name: 'Problems',
  components: {
    Attention,
    Flow,
    CategoryModal,
    PageTitle,
    Category,
    ProblemModal
  },
  fetch() {
    orm.Queries.categoriesProblems()
  },
  data() {
    return {
      showCategoryModal: false,
      showProblemModal: false
    }
  },
  computed: {
    ...mapGetters('contestInfo', ['gradingDelaySec', 'realtimeGrading']),
    categories() {
      return this.sortByOrder(
        orm.Category.query()
          .with(['problems.body', 'problems.category'])
          .all()
      )
    }
  }
}
</script>
<style scoped lang="sass">
.top-right
  top: 3rem
  right: 0.5rem
</style>
