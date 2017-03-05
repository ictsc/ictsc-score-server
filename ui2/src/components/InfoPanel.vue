<template>
  <div class="panel">
    <span class="limit">{{ limit | tickDate }}</span>
    <span v-if="isMember" class="score">
      <span class="label">Progress</span>
      <span class="ratio">{{ ratio }}</span>
    </span>
  </div>
</template>

<style scoped>
.panel {
  font-family: Menlo,Monaco,Consolas,Liberation Mono,Courier New,monospace;
  background: #ed1848;
  color: #fff;
  position: fixed;
  bottom: 0;
  left: 0;
  min-height: 3rem;
  padding: .5rem;
  border-top-right-radius: 10px;
  z-index: 1500;
}
.limit {
  font-size: 1.5rem;
}
</style>

<script>
import { API } from '../utils/Api'
import { tickDate } from '../utils/Filters'
import * as d3 from 'd3'
import { mapGetters } from 'vuex'

export default {
  name: 'info-panel',
  filters: {
    tickDate,
  },
  data () {
    return {
      currentDate: new Date(),
      sumPurePoint: 0,
      scoredPurePoint: 0,
    }
  },
  asyncData: {
    problemsDefault: [],
    problems () {
      return API.getProblemsWithScore();
    },
    contestDefault: {},
    contest () {
      return API.getContest();
    },
  },
  computed: {
    limit () {
      var end = this.contest.competition_end_time;
      if (end) {
        return new Date(end).valueOf() - this.currentDate;
      } else {
        return 0
      }
    },
    ratio () {
      return d3.format('.3%')(this.scoredPurePoint / this.sumPurePoint);
    },
    ...mapGetters([
      'isMember',
    ]),
  },
  watch: {
    problems (val) {
      try {
        this.sumPurePoint = val.reduce((p, n) => p + n.perfect_point, 0);

        var scores = answers => answers ? answers
          .reduce((p, n) => p + (n.score ? n.score.point : 0), 0) : 0;
        this.scoredPurePoint = val
          .reduce((p, n) => p + scores(n.answers), 0);
      } catch (err) {
        console.warn('scoredPurePoint', err);
      }
    },
  },
  mounted () {
    var refreshDate = () => setTimeout(() => {
      this.currentDate = new Date();
      refreshDate();
    }, 200);
    refreshDate();

    setInterval(() => {
      this.asyncReload();
    }, 120 * 1000);
  },
  destroyed () {
  },
  methods: {
  },
}
</script>

