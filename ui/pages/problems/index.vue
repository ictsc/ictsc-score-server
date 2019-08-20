<template>
  <v-container>
    <v-layout column justify-start>
      <v-flex>
        <v-layout column align-center>
          <page-title title="問題一覧" />
        </v-layout>
      </v-flex>

      <v-flex v-if="realtimeGrading">
        <answer-flow />
      </v-flex>

      <v-flex mt-2>
        <answer-attention />
      </v-flex>

      <v-flex v-for="category in categories" :key="category.id" class="mt-2">
        <v-divider class="mb-1" />
        <problem-category :category="category" />
      </v-flex>
    </v-layout>
  </v-container>
</template>

<style scoped lang="sass"></style>

<script>
import { mapGetters } from 'vuex'
import PageTitle from '~/components/atoms/PageTitle'
import AnswerAttention from '~/components/molecules/AnswerAttention'
import AnswerFlow from '~/components/molecules/AnswerFlow'
import ProblemCategory from '~/components/organisms/ProblemCategory'
import orm from '~/orm'

export default {
  name: 'Problems',
  components: {
    AnswerAttention,
    AnswerFlow,
    PageTitle,
    ProblemCategory
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
