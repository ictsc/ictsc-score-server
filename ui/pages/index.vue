<template>
  <v-container>
    <v-row justify="center" class="flex-nowrap">
      <v-col cols="6" class="pa-0 panel-width">
        <notice-panel />
      </v-col>

      <v-col v-if="realtimeGrading" cols="6" class="pa-0 panel-width">
        <scoreboard-panel />
      </v-col>
    </v-row>
  </v-container>
</template>
<script>
import { mapGetters } from 'vuex'
import ScoreboardPanel from '~/components/top/ScoreboardPanel'
import NoticePanel from '~/components/top/NoticePanel'

export default {
  name: 'Index',
  components: {
    ScoreboardPanel,
    NoticePanel,
  },
  computed: {
    ...mapGetters('contestInfo', ['realtimeGrading']),
  },
  head() {
    return {
      title: 'トップ',
    }
  },
}
</script>
<style scoped lang="sass">
.panel-width
  min-width: 20em
  max-width: 40em
</style>
