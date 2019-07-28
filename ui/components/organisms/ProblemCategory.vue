<template>
  <v-layout column>
    <v-flex>
      <h2>{{ category.title }}</h2>

      <div class="body-2 ml-2">
        {{ category.description }}
      </div>
    </v-flex>

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
import ProblemCard from '~/components/molecules/ProblemCard'

export default {
  name: 'CategoryArea',
  components: {
    ProblemCard
  },
  props: {
    category: {
      type: Object,
      required: true
    }
  },
  computed: {
    problems() {
      return this.sortByOrder(this.category.problems)
    }
  }
}
</script>
