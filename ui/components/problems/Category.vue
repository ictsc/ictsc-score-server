<template>
  <div>
    <!-- エラー防止のためにモーダルをレンダリングしない -->
    <category-modal v-if="showModal" v-model="showModal" :item="category" />

    <!-- タイトル -->
    <v-container my-0 py-1>
      <v-row align="center" justify="start">
        <div class="headline">{{ category.title }}</div>

        <pen-button
          v-if="isStaff"
          class="ml-2"
          @click.stop="showModal = true"
        />
      </v-row>
    </v-container>

    <!-- 説明文 -->
    <markdown
      v-if="!!category.description"
      :content="category.description"
      class="body-2 pl-1"
    />

    <!-- 問題一覧 -->
    <v-container fluid grid-list-md class="pl-0">
      <v-layout wrap>
        <v-flex v-for="problem in problems" :key="problem.id" shrink>
          <problem-card :problem="problem" />
        </v-flex>
      </v-layout>
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
    ProblemCard
  },
  props: {
    category: {
      type: Object,
      required: true
    }
  },
  data() {
    return {
      showModal: false
    }
  },
  computed: {
    problems() {
      return this.sortByOrder(this.category.problems)
    }
  }
}
</script>
