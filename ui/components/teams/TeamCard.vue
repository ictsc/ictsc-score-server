<template>
  <v-menu
    open-on-hover
    offset-y
    allow-overflow
    open-delay="400"
    max-width="40em"
  >
    <template v-slot:activator="{ on }">
      <!-- 一覧に表示されるカード -->
      <v-card
        :ripple="false"
        tile
        height="100%"
        class="disable-click-effect"
        v-on="on"
      >
        <v-row align="center" class="height-full" no-gutters>
          <v-avatar
            :color="team.color"
            size="0.4em"
            height="100%"
            class="py-6"
            tile
          />

          <v-col class="subtitle-1 px-2 truncate-clamp2">
            {{ showNumber ? team.displayName : team.name }}
          </v-col>

          <v-icon v-if="isStaff && team.beginner" class="pr-1">
            mdi-face-agent
          </v-icon>
        </v-row>
      </v-card>
    </template>

    <team-details-card :team="team" />
  </v-menu>
</template>
<script>
import TeamDetailsCard from '~/components/misc/TeamDetailsCard'

export default {
  name: 'TeamCard',
  components: {
    TeamDetailsCard
  },
  props: {
    team: {
      type: Object,
      required: true
    },
    showNumber: {
      type: Boolean,
      default: true
    }
  }
}
</script>
