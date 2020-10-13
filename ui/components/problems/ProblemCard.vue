<template>
  <v-hover v-slot:default="{ hover }">
    <v-card
      :disabled="!problem.isReadable"
      :to="problemURL"
      :color="color"
      append
      tile
      width="17.6em"
    >
      <v-row align="center" no-gutters style="height: 7em">
        <problem-card-staff
          v-if="isNotPlayer"
          :problem="problem"
          :hover="hover"
        />
        <problem-card-player
          v-if="isPlayer"
          :problem="problem"
          :hover="hover"
          :color.sync="color"
        />
      </v-row>
    </v-card>
  </v-hover>
</template>
<script>
import ProblemCardPlayer from '~/components/problems/ProblemCardPlayer'
import ProblemCardStaff from '~/components/problems/ProblemCardStaff'

export default {
  name: 'ProblemCard',
  components: { ProblemCardPlayer, ProblemCardStaff },
  props: {
    problem: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      color: '',
    }
  },
  computed: {
    problemURL() {
      if (!this.problem.isReadable) {
        return ''
      } else {
        return `${this.problem.id}#answers`
      }
    },
  },
}
</script>
