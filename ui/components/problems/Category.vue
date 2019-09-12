<template>
  <v-layout column>
    <!-- エラー防止のためにモーダルをレンダリングしない -->
    <category-modal v-if="showModal" v-model="showModal" :category="category" />

    <!-- タイトル -->
    <v-flex>
      <v-container my-0 py-1>
        <v-layout row align-center justify-start>
          <v-flex shrink>
            <span class="headline">{{ category.title }}</span>
          </v-flex>
          <v-flex v-if="isStaff" shrink ml-2>
            <pen-button @click.stop="showModal = true" />
          </v-flex>
        </v-layout>
      </v-container>
    </v-flex>

    <!-- 説明文 -->
    <v-flex ml-2>
      <markdown :content="category.description" class="body-2" />
    </v-flex>

    <!-- 問題一覧 -->
    <v-container fluid grid-list-md>
      <v-layout wrap>
        <v-flex v-for="problem in problems" :key="problem.id" shrink>
          <problem-card :problem="problem" />
        </v-flex>
      </v-layout>
    </v-container>
  </v-layout>
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
