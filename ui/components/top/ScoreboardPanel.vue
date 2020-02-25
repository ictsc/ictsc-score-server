<template>
  <v-sheet elevation="0" class="px-2">
    <template v-if="isNotPlayer">
      <panel-label v-if="notBeginnerScoreboards.length !== 0" label="順位" />
      <scoreboard-group :scoreboards="notBeginnerScoreboards" />

      <panel-label
        v-if="beginnerScoreboards.length !== 0"
        label="順位 - 解答サポート"
        class="mt-12"
      />
      <scoreboard-group :scoreboards="beginnerScoreboards" />
    </template>
    <template v-else>
      <panel-label label="順位" />
      <scoreboard-group :scoreboards="scoreboards" />
    </template>
  </v-sheet>
</template>
<script>
import orm from '~/orm'
import PanelLabel from '~/components/top/PanelLabel'
import ScoreboardGroup from '~/components/top/ScoreboardGroup'

export default {
  name: 'ScoreboardPanel',
  components: {
    ScoreboardGroup,
    PanelLabel
  },
  data() {
    return {
      fetching: false
    }
  },
  computed: {
    scoreboards() {
      return orm.Scoreboard.query()
        .with('team')
        .all()
    },
    beginnerScoreboards() {
      return this.scoreboards.filter(sb => sb.team.beginner)
    },
    notBeginnerScoreboards() {
      return this.scoreboards.filter(sb => !sb.team.beginner)
    }
  },
  // なぜかfetch()だと呼ばれない
  async created() {
    try {
      this.fetching = true
      await orm.Queries.scoreboardsTeam()
    } finally {
      this.fetching = false
    }
  }
}
</script>
