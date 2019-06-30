<template>
  <div class="content">
    <h2>{{ category.title }}</h2>

    <div class="columns is-multiline is-mobile is-2 is-variable">
      <problem-card
        v-for="problem in category.problems"
        :key="problem.id"
        :problem="problem"
      />
    </div>
  </div>
</template>

<script>
import ProblemCard from '~/components/molecules/ProblemCard'

export default {
  name: 'CategoryColumn',
  components: {
    ProblemCard
  },
  props: {
    category: {
      type: Object,
      default: () => ({})
    }
  },
  computed: {
    problems() {
      return this.$_.sortBy(this.category.problems, 'order')
    }
  }
}
</script>

<style scoped lang="sass"></style>
