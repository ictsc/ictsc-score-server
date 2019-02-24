<template>
  <div>
    <h1>Result</h1>
    <graph
      :graph-data="result"
      :height="500"
      :notfound="false"
      v-loading="asyncLoading"
      title="タイトル"
      class="graph access"
    />
    <div class="list">
      <div
        v-for="item in result"
        class="item"
      >
        <i
          :style="{ background: item.color }"
          class="tag"
        /> {{ item.name }}
      </div>
    </div>
  </div>
</template>

<style scoped>
.tag {
  display: inline-block;
  width: 1em;
  height: 1em;
}
.item {
  display: inline-block;
  margin: 0 .5rem;
}
</style>

<script>
import { SET_TITLE } from '../store/'
import Graph from '../components/Graph'
import { API } from '../utils/Api'
import * as d3 from 'd3';
import { latestAnswer } from '../utils/Filters'
import { nestedValue } from '../utils/Utils'
import * as _ from 'underscore'

window.d3 = d3;

export default {
  name: 'Result',
  components: {
    Graph,
  },
  data () {
    return {
    }
  },
  computed: {
    result () {
      return this.teams.map((team, index) => {
        // その時点での合計スコア
        const getPileSubtotal = (answers, date) => {
          return _.chain(answers)
            // 指定時間以前の解答
            .filter(a => new Date(a.created_at) <= new Date(date))
            // 問題毎の解答一覧 problem_id => [Answer, ...]
            .groupBy('problem_id')
            // 得点として使用する解答のみ集める
            .map(latestAnswer)
            // 合計
            .reduce((sum, ans) => sum + ans.score.subtotal_point, 0);
        };

        // スコアのついた解答
        const scoredAnswers = team.answers.filter(ans => ans.score);

        const answers = scoredAnswers
          .map(ans => ({
            problem: ans.problem_id,
            subtotal: nestedValue(ans, 'score', 'subtotal_point'),
            total: getPileSubtotal(scoredAnswers, ans.created_at),
            date: new Date(ans.created_at),
          }))

        return Object.assign({}, team, {
          answers: _.sortBy(answers, 'date'),
          color: d3.interpolateSpectral(index / this.teams.length),
        });
      })
    },
  },
  watch: {
  },
  asyncData: {
    teamsDefault: [],
    teams () {
      return API.getTeamsWithScore();
    },
  },
  mounted () {
    this.$store.dispatch(SET_TITLE, 'ページ名');
  },
  destroyed () {
  },
  methods: {
  },
}
</script>
