<template>
  <div class="host">
    <div
      v-loading="scoreboardLoading"
      v-if="scoreboard && scoreboard.length"
      class="scoreboard"
    >
      <div class="team-list">
        <template v-for="item in scoreboard">
          <router-link
            :to="{name: 'team-detail', params: {id: item.team ? item.team.id : ''}}"
            class="team-item"
          >
            <div
              :style="{ background: (result.find(x => x.id === item.team.id) || { color: 'black'}).color }"
              class="team-item-color"
            >
              {{ item.rank }}位
            </div>
            <div
              class="team-item-content"
            >
              <div v-if="item.team">{{ item.team.organization }}</div>
              <div v-if="item.team">{{ item.team.name }}</div>
            </div>
          </router-link>
        </template>
      </div>
    </div>
    <div>
      <graph
        :graph-data="result"
        :height="650"
        :notfound="false"
        v-loading="asyncLoading"
        title="タイトル"
        class="graph access"
      />
    </div>
  </div>
</template>

<style scoped>
.host {
  display: flex;
  width: 100%;
  position: absolute;
  left: 0;
  right: 0;
  margin: -1rem 0;
  background-color: #34393e;
  padding: 12px 1rem 90px 1rem;
}
.host > :nth-child(2) {
  flex-grow: 1;
  margin-left: 1rem;
}

.scoreboard {
  width: fit-content;
}

.team-list {
  padding: 1rem;
  margin-bottom: 2rem;
  display: flex;
  flex-direction: column;
  font-weight: bold;
  background-color: #111;
  width: 100%;
}

.team-item {
  display: inline-flex;
  margin: .2rem .5rem;
  justify-content: center;
  align-items: center;
  position: relative;
  width: 100%;
}

.team-item:not(.team-item:last-child) {
  margin-bottom: 1rem;
}

.team-item-color {
  min-height: 3rem;
  min-width: 5rem;
  font-size: 2rem;
  display: inline-flex;
  justify-content: center;
  align-items: center;
  color: white;
  border-radius: 2px;
  text-stroke: 1px #000;
  -webkit-text-stroke: 1px #000;
  white-space: nowrap;
  overflow: hidden;
}

.team-item-content {
  flex-grow: 1;
  display: flex;
  flex-direction: column;
  padding-left: 1rem;
}

.team-item-content > :nth-child(1) {
  color: #aaa;
  font-size: .8rem;
  overflow: hidden;
  white-space: nowrap;
  text-overflow: ellipsis;
}

.team-item-content > :nth-child(2) {
  color: #fafbfd;
  font-size: 1.5rem;
  overflow: hidden;
  white-space: nowrap;
  text-overflow: ellipsis;
  width: 12rem;
}

.tag {
  display: inline-block;
  width: 1em;
  height: 1em;
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

export default {
  name: 'Summary',
  components: {
    Graph,
  },
  data () {
    return {
    }
  },
  asyncData: {
    teamsDefault: [],
    teams () {
      return API.getTeamsWithScore();
    },
    scoreboard () {
      return API.getScoreboard();
    },
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
  mounted () {
    this.$store.dispatch(SET_TITLE, 'ダッシュボード');
  },
  destroyed () {
  },
  methods: {
  },
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
</style>
