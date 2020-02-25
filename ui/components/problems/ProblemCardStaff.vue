<template>
  <v-card-text class="py-0 black--text">
    <div class="subtitle-1 text-truncate">
      {{ elvis(problem, 'body.title') }}
    </div>

    <v-row no-gutters>
      <v-col>
        <div>コード {{ problem.code }}</div>
        <div class="body-2">満点 {{ elvis(problem, 'body.perfectPoint') }}</div>
      </v-col>

      <problem-modal :item="problem">
        <template v-slot:activator="{ on }">
          <pen-button v-if="hover" right small class="pa-0" v-on="on" />
        </template>
      </problem-modal>
    </v-row>
  </v-card-text>
</template>
<script>
import PenButton from '~/components/commons/PenButton'
import ProblemModal from '~/components/misc/ProblemModal'

export default {
  name: 'ProblemCardStaff',
  components: { PenButton, ProblemModal },
  props: {
    hover: {
      type: Boolean,
      default: false
    },
    problem: {
      type: Object,
      required: true
    }
  }
}
</script>
