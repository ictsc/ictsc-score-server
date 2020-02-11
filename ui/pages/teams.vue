<template>
  <v-container>
    <v-row justify="center">
      <page-title title="チーム一覧" />
    </v-row>

    <v-divider class="mt-3 mb-4" />

    <v-row v-if="isNotPlayer" no-gutters class="mx-4 mb-4">
      <v-col>
        <v-text-field
          v-model="search"
          placeholder="チーム番号 チーム名 学校"
          append-icon="mdi-table-search"
          clearable
          single-line
          hide-details
        />
      </v-col>
    </v-row>

    <v-row align="start" class="mx-4" no-gutters>
      <template v-for="team of teams">
        <v-col
          v-show="isDisplay(team)"
          :key="team.id"
          cols="4"
          align-self="stretch"
          class="pb-3 pr-2"
        >
          <team-card :team="team" />
        </v-col>
      </template>
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
  data() {
    return {
      search: ''
    }
  },
  computed: {
    teams() {
      return this.sortByNumber(
        this.isStaff ? orm.Team.all() : orm.Team.playersWithoutTeam99
      )
    }
  },
  fetch() {
    orm.Queries.teams()
  },
  methods: {
    isDisplay(team) {
      if (!this.search) {
        return true
      }

      const simpleSearch = this.stringSimplify(this.search)

      return [team.displayName, team.organization].some(str =>
        this.stringSimplify(str).includes(simpleSearch)
      )
    }
  }
}
</script>
