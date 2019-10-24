<template>
  <v-container>
    <v-row justify="center">
      <page-title title="チーム一覧" />
    </v-row>

    <v-divider class="mt-3 mb-4" />

    <v-row align="start" class="mx-4" no-gutters>
      <v-col
        v-for="team of teams"
        :key="team.id"
        :cols="isFixedWidth ? 4 : 'auto'"
        align-self="stretch"
        class="pb-3 pr-3"
      >
        <team-card :team="team" :show-number="isFixedWidth" />
      </v-col>
    </v-row>
  </v-container>
</template>
<script>
import orm from '~/orm'
import PageTitle from '~/components/commons/PageTitle'
import TeamCard from '~/components/teams/TeamCard'

export default {
  name: 'Teams',
  components: {
    PageTitle,
    TeamCard
  },
  computed: {
    teams() {
      return this.sortByNumber(orm.Team.playersWithoutTeam99)
    },
    isFixedWidth() {
      return this.teams.length <= 18
    }
  },
  beforeCreate() {
    orm.Team.eagerFetch({}, [])
  }
}
</script>
