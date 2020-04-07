<template>
  <div>
    <!-- タイトル -->
    <v-container my-0 py-1>
      <v-row align="center" justify="start">
        <div v-if="category.title" class="headline">
          {{ category.title }}
        </div>
        <div v-else-if="isStaff">
          カテゴリ名無し (参加者には非表示)
        </div>

        <category-modal v-if="isStaff" :item="category">
          <template v-slot:activator="{ on }">
            <pen-button elevation="2" class="ml-2" v-on="on" />
          </template>
        </category-modal>
      </v-row>
    </v-container>

    <!-- 説明文 -->
    <markdown
      v-if="!!category.description"
      :content="category.description"
      class="body-2 pl-1 pt-0"
    />

    <!-- 問題一覧 -->
    <v-container fluid class="px-0 py-0">
      <v-row justify="start" no-gutters>
        <v-col
          v-for="problem in problems"
          :key="problem.id"
          cols="auto"
          class="pr-2 pb-2"
        >
          <problem-card :problem="problem" />
        </v-col>
      </v-row>
    </v-container>
  </div>
</template>
<script>
import PenButton from '~/components/commons/PenButton'
import Markdown from '~/components/commons/Markdown'
import ProblemCard from '~/components/problems/ProblemCard'
import CategoryModal from '~/components/misc/CategoryModal'

export default {
  name: 'Category',
  components: {
    CategoryModal,
    Markdown,
    PenButton,
    ProblemCard,
  },
  props: {
    category: {
      type: Object,
      required: true,
    },
  },
  computed: {
    problems() {
      return this.sortByOrder(this.category.problems)
    },
  },
}
</script>
