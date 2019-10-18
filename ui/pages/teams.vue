<template>
  <v-container>
    <v-row justify="center">
      <page-title title="チーム一覧" />
    </v-row>

    <v-divider class="mt-3 mb-4" />

    <v-row align="start" class="mx-5" no-gutters>
      <v-col
        v-for="team of teams"
        :key="team.id"
        :cols="isFixedWidth ? 'auto' : 4"
      >
        <v-card tile class="mb-6 mr-6" :color="team.color">
          <v-card-title class="subtitle-1">
            {{ team.displayName }}
          </v-card-title>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import orm from '~/orm'
import PageTitle from '~/components/commons/PageTitle'

export default {
  name: 'Teams',
  components: {
    PageTitle
  },
  computed: {
    teams() {
      return this.sortByNumber(orm.Team.players)
    },
    isFixedWidth() {
      return this.teams.length > 18
    }
  },
  beforeCreate() {
    orm.Team.eagerFetch({}, [])
  }
}
</script>
