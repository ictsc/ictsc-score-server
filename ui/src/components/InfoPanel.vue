<template>
  <div class="panel">
    <span class="limit">{{ limit | tickDuration("HH:mm:ss") }}</span>
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
import { tickDuration, latestAnswer } from '../utils/Filters'
import { nestedValue } from '../utils/Utils'
import * as d3 from 'd3'
import { mapGetters } from 'vuex'

export default {
  name: 'info-panel',
  filters: {
    tickDuration,
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
  },
  computed: {
    limit () {
      var end = this.contest.competition_end_at;
      if (end) {
        let duration = new Date(end).valueOf() - this.currentDate.valueOf();
        if (duration > 0) {
          return duration;
        } else {
          return 'Contest has finished';
        }
      } else {
        return 0
      }
    },
    ratio () {
      return d3.format('.3%')(this.scoredPurePoint / this.sumPurePoint);
    },
    ...mapGetters([
      'contest',
      'isParticipant',
    ]),
  },
  watch: {
    problems (val) {
      try {
        this.sumPurePoint = val.reduce((p, n) => p + n.perfect_point, 0);

        const scoreOf = problem => (nestedValue(latestAnswer(problem.answers), 'score', 'subtotal_point') || 0);
        this.scoredPurePoint = val.reduce((p, n) => p + scoreOf(n), 0);
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

