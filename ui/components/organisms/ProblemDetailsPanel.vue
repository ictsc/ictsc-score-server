<template lang="md">
  <v-layout column>
    <v-flex>
      <div class="grey--text text--darken-3 display-1">
        {{ problem.body.title }}
      </div>
      <v-divider class="primary" />
    </v-flex>
    <v-flex>
      <problem-info-chips-area :problem="problem" class="ml-0" />
    </v-flex>
    <v-flex>
      <v-sheet v-if="!!problem.secretText" class="pa-2 white elevation-2">
        <div class="caption">運営用メモ</div>
        <v-divider />
        <markdown :content="problem.secretText" />
      </v-sheet>
    </v-flex>
    <v-flex>
      <problem-supplement-area :supplements="supplements" />
    </v-flex>
    <v-flex>
      <problem-environment-area v-if="environments.length !== 0" :environments="environments"/>
    </v-flex>
    <v-flex>
      <v-sheet class="pa-1 elevation-2">
        <!-- TODO: 長文対応どうするか -->
        <markdown :content="problem.body.text"/>
      </v-sheet>
    </v-flex>
  </v-layout>
</template>
<script>
import Markdown from '~/components/atoms/Markdown'
import ProblemEnvironmentArea from '~/components/organisms/ProblemEnvironmentArea'
import ProblemInfoChipsArea from '~/components/molecules/ProblemInfoChipsArea'
import ProblemSupplementArea from '~/components/organisms/ProblemSupplementArea'

export default {
  name: 'ProblemDetailsPanel',
  components: {
    Markdown,
    ProblemEnvironmentArea,
    ProblemInfoChipsArea,
    ProblemSupplementArea
  },
  props: {
    problem: {
      type: Object,
      required: true
    }
  },
  computed: {
    environments() {
      return this.problem.environments
    },
    supplements() {
      return this.sortByCreatedAt(this.problem.supplements).reverse()
    }
  }
}
</script>
<style scoped lang="sass"></style>
