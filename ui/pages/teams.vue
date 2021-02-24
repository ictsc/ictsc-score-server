<template>
  <v-container>
    <v-row justify="center">
      <page-title title="チーム一覧">
        <pen-button
          v-if="isStaff"
          elevation="2"
          x-small
          absolute
          class="ml-2 mb-4"
          @click.stop="showModal = true"
        />
      </page-title>

      <team-modal v-model="showModal" is-new />
    </v-row>

    <v-divider class="mt-3 mb-4" />

    <v-row v-if="isNotPlayer" no-gutters class="mx-4 mb-4">
      <v-col>
        <v-text-field
          v-model="search"
          placeholder="ユーザ番号 ユーザ名 組織"
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
import PenButton from '~/components/commons/PenButton'
import TeamCard from '~/components/teams/TeamCard'
import TeamModal from '~/components/misc/TeamModal'

export default {
  name: 'Teams',
  components: {
    PageTitle,
    PenButton,
    TeamCard,
    TeamModal,
  },
  fetch() {
    orm.Queries.teams()
  },
  data() {
    return {
      search: '',
      showModal: false,
    }
  },
  computed: {
    teams() {
      return this.sortByNumber(
        this.isStaff ? orm.Team.all() : orm.Team.playersWithoutTeam99
      )
    },
  },
  methods: {
    isDisplay(team) {
      if (!this.search) {
        return true
      }

      const simpleSearch = this.stringSimplify(this.search)

      return [team.displayName, team.organization].some((str) =>
        this.stringSimplify(str).includes(simpleSearch)
      )
    },
  },
}
</script>
