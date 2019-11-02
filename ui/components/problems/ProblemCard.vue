<template>
  <v-card
    :disabled="!problem.isReadable"
    :to="problemURL"
    append
    tile
    width="12em"
  >
    <v-container height="6em">
      <v-row align="center" justify="center" style="height: 4em">
        <v-card-text class="py-0 black--text">
          <template v-if="problem.isReadable">
            <div class="subtitle-1 text-truncate">
              {{ elvis(problem, 'body.title') }}
            </div>

            <div v-if="isStaff">コード {{ problem.code }}</div>

            <div class="body-2">
              満点 {{ elvis(problem, 'body.perfectPoint') }}
            </div>
          </template>
          <template v-else>
            <v-row justify="center" class="pa-0">
              <v-icon>mdi-lock</v-icon>
            </v-row>
          </template>
        </v-card-text>
      </v-row>
    </v-container>
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
      } else {
        return `${this.problem.id}#answers`
      }
    }
  }
}
</script>
