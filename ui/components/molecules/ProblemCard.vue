<template>
  <v-card append :to="problemURL" width="12em" height="6em" class="pa-2 py-4">
    <div class="subtitle-1 text-truncate">
      {{ elvis(problem, 'body.title') }}
    </div>

    <div class="body-2">満点 {{ elvis(problem, 'body.perfectPoint') }}</div>
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
        return `${this.problem.id}#answers`
      } else {
        return this.problem.id
      }
    }
  }
}
</script>

<style scoped lang="sass"></style>
