<template>
  <v-card
    append
    :disabled="!problem.isReadable"
    :to="problemURL"
    width="12em"
    height="6em"
    class="pl-4 pr-2 py-4"
  >
    <template v-if="problem.isReadable">
      <div class="subtitle-1 text-truncate">
        {{ elvis(problem, 'body.title') }}
      </div>

      <div v-if="isStaff">コード {{ problem.code }}</div>

      <div class="body-2">満点 {{ elvis(problem, 'body.perfectPoint') }}</div>
    </template>
    <template v-else>
      <v-layout justify-center align-center fill-height>
        <v-icon>mdi-lock</v-icon>
      </v-layout>
    </template>
  </v-card>
</template>
<script>
export default {
  name: 'ProblemCard',
  props: {
    problem: {
      type: Object,
      required: true
    }
  },
  computed: {
    problemURL() {
      if (!this.problem.isReadable) {
        return ''
      } else if (this.isPlayer) {
        return `${this.problem.id}#answers`
      } else {
        return this.problem.id
      }
    }
  }
}
</script>
