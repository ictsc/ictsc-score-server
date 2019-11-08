<template>
  <v-hover v-slot:default="{ hover }">
    <v-card
      :disabled="!problem.isReadable"
      :to="problemURL"
      append
      tile
      width="12em"
    >
      <problem-modal v-if="isStaff" v-model="showModal" :item="problem" />

      <v-container height="6em">
        <v-row align="center" justify="center" style="height: 4em">
          <v-card-text class="py-0 black--text">
            <template v-if="problem.isReadable">
              <div class="subtitle-1 text-truncate">
                {{ elvis(problem, 'body.title') }}
              </div>

              <v-row no-gutters>
                <v-col>
                  <div v-if="isStaff">コード {{ problem.code }}</div>

                  <div class="body-2">
                    満点 {{ elvis(problem, 'body.perfectPoint') }}
                  </div>
                </v-col>

                <pen-button
                  v-if="isStaff && hover"
                  right
                  small
                  @click.stop.prevent="showModal = true"
                />
              </v-row>
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
  </v-hover>
</template>
<script>
import PenButton from '~/components/commons/PenButton'
import ProblemModal from '~/components/misc/ProblemModal'

export default {
  name: 'ProblemCard',
  components: { PenButton, ProblemModal },
  props: {
    problem: {
      type: Object,
      required: true
    }
  },
  data() {
    return {
      showModal: false
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
