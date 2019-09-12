<template>
  <v-card
    append
    :to="problemURL"
    width="12em"
    height="6em"
    class="pl-4 pr-2 py-4"
  >
    <div class="subtitle-1 text-truncate">
      {{ elvis(problem, 'body.title') }}
    </div>

    <div v-if="isStaff">コード {{ problem.code }}</div>

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
