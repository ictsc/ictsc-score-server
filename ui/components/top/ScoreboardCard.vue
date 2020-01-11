<template>
  <!-- root要素がv-menuだと上位コンポーネントからmarginが適用できない -->
  <div>
    <v-menu
      open-on-hover
      offset-y
      allow-overflow
      open-delay="400"
      max-width="40em"
    >
      <template v-slot:activator="{ on }">
        <v-card
          :ripple="false"
          elevation="4"
          class="px-4 py-2 disable-click-effect"
          v-on="on"
        >
          <v-row no-gutters class="title">
            <v-col cols="6">
              {{ scoreboard.displayRank }}
            </v-col>

            <v-col cols="6" class="text-right">
              {{ scoreboard.displayScore }}
            </v-col>
          </v-row>

          <v-row no-gutters>
            <v-col class="truncate-clamp2">
              {{ scoreboard.displayTeamName }}
            </v-col>
          </v-row>
        </v-card>
      </template>

      <team-details-card v-if="!!scoreboard.team" :team="scoreboard.team" />
    </v-menu>
  </div>
</template>
<script>
import TeamDetailsCard from '~/components/misc/TeamDetailsCard'

export default {
  name: 'ScoreboardCard',
  components: {
    TeamDetailsCard
  },
  props: {
    scoreboard: {
      type: Object,
      required: true
    }
  }
}
</script>
