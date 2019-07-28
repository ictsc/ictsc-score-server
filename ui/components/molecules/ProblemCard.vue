<template>
  <v-card append :to="problemURL" width="12em" height="6em" class="pa-1">
    <div class="subtitle-1 text-truncate">
      {{ elvis(problem, 'body.title') }}
    </div>
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
      if (this.problem.body === null) {
        // TODO: 遷移させない & エラーメッセージ
        return ''
      } else if (this.isPlayer) {
        return `${this.problem.id}#issues`
      } else {
        return this.problem.id
      }
    }
  }
}
</script>

<style scoped lang="sass"></style>
