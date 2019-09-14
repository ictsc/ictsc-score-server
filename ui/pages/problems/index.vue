<template>
  <v-container>
    <!-- 問題・カテゴリ追加ボタン -->
    <v-layout v-if="isStaff" column class="floating-area">
      <v-btn
        color="primary"
        class="elevation-6 my-2"
        @click="showProblemModal = true"
      >
        <v-layout row align-center justify-start>
          <v-icon>mdi-plus</v-icon>
          <span class="text-left">
            問題追加
          </span>
        </v-layout>
      </v-btn>

      <v-btn
        color="primary"
        class="elevation-6"
        @click="showCategoryModal = true"
      >
        <v-layout row align-center justify-start>
          <v-icon>mdi-plus</v-icon>
          <span class="text-left">
            カテゴリ追加
          </span>
        </v-layout>
      </v-btn>
    </v-layout>

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

    <v-layout column justify-start>
      <v-flex>
        <v-layout column align-center>
          <page-title title="問題一覧" />
        </v-layout>
      </v-flex>

      <v-flex v-if="realtimeGrading">
        <flow />
      </v-flex>

      <v-flex mt-2>
        <attention />
      </v-flex>

      <v-flex v-for="category in categories" :key="category.id" class="mt-2">
        <v-divider class="mb-1" />
        <category :category="category" />
      </v-flex>
    </v-layout>
  </v-container>
</template>

<style scoped lang="sass"></style>

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
          .with('problems.body')
          .all()
      )
    }
  },
  fetch() {
    orm.Category.eagerFetch({}, ['problems'])
  }
}
</script>
<style scoped lang="sass">
.floating-area
  position: fixed
  z-index: 100
  top: 3rem
  right: 0.5rem
</style>
