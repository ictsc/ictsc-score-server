<template>
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
    <v-flex v-if="!!problem.secretText">
      <v-sheet class="white elevation-2">
        <span class="pa-2 caption">運営用メモ</span>
        <v-divider class="pb-1" />
        <markdown :content="problem.secretText" />
      </v-sheet>
    </v-flex>
    <v-flex v-if="problem.environments.length !== 0 || isStaff">
      <problem-supplement-area :supplements="problem.supplements" />
    </v-flex>
    <v-flex v-if="problem.environments.length !== 0">
      <problem-environment-area :environments="problem.environments" />
    </v-flex>
    <v-flex>
      <v-sheet class="pa-0 elevation-2">
        <span class="pa-2 caption">問題文</span>
        <v-divider class="pb-1" />
        <!-- TODO: 長文対応どうするか -->
        <markdown :content="problem.body.text" />
      </v-sheet>
    </v-flex>
  </v-layout>
</template>
<script>
import Markdown from '~/components/atoms/Markdown'
import ProblemEnvironmentArea from '~/components/organisms/ProblemEnvironmentArea'
import ProblemInfoChipsArea from '~/components/molecules/ProblemInfoChipsArea'
import ProblemSupplementArea from '~/components/organisms/ProblemSupplementArea'

// TODO: 現在の得点が見たい

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
  }
}
</script>
<style scoped lang="sass"></style>
