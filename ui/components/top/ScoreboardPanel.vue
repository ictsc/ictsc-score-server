<template>
  <v-sheet elevation="0">
    <v-container fluid>
      <template v-if="isNotPlayer">
        <panel-label label="順位" />
        <scoreboard-group :scoreboards="notBeginnerScoreboards" />

        <panel-label label="順位(サポート)" class="mt-12" />
        <scoreboard-group :scoreboards="beginnerScoreboards" />
      </template>
      <template v-else>
        <panel-label label="順位" />
        <scoreboard-group :scoreboards="scoreboards" />
      </template>
    </v-container>
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
      // 順位変更があるとVuexにある古い値が表示されるので全削除
      orm.Scoreboard.deleteAll()
      await orm.Scoreboard.eagerFetch({}, ['team'])
    } finally {
      this.fetching = false
    }
  }
}
</script>
