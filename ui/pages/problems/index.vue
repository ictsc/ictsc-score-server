<template>
  <v-container>
    <!-- 問題・カテゴリ追加ボタン -->
    <v-col v-if="isStaff" cols="auto" class="floating-area-100 top-right pa-0">
      <problem-modal is-new>
        <template v-slot:activator="{ on }">
          <v-btn block color="primary" class="elevation-4 my-2" v-on="on">
            <v-row align="center" justify="start">
              <v-icon>mdi-plus</v-icon>
              <span class="text-left"> 問題追加 </span>
            </v-row>
          </v-btn>
        </template>
      </problem-modal>

      <category-modal is-new>
        <template v-slot:activator="{ on }">
          <v-btn block color="primary" class="elevation-4" v-on="on">
            <v-row align="center" justify="start">
              <v-icon>mdi-plus</v-icon>
              <span class="text-left"> カテゴリ追加 </span>
            </v-row>
          </v-btn>
        </template>
      </category-modal>
    </v-col>

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
    ProblemModal,
  },
  computed: {
    ...mapGetters('contestInfo', ['gradingDelaySec', 'realtimeGrading']),
    categories() {
      const withArg = this.isPlayer
        ? [
            'problems',
            'problems.body',
            'problems.answers',
            'problems.penalties',
          ]
        : ['problems.body', 'problems.category']

      return this.sortByOrder(orm.Category.query().with(withArg).all())
    },
  },
  watch: {
    isLoggedIn: {
      immediate: true,
      handler(value) {
        // 未ログインだとisPlayer判定がおかしくなるためcreatedではなくwatchで行う
        if (value) {
          orm.Queries.pageProblems()
        }
      },
    },
  },
}
</script>
<style scoped lang="sass">
.top-right
  top: 3rem
  right: 0.5rem
</style>
