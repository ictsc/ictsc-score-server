<template>
  <div class="host">
    <div
      v-loading="scoreboardLoading"
      v-if="scoreboardLoading || (scoreboard && scoreboard.length)"
      class="scoreboard"
    >
      <div class="team-list">
        <template v-for="item in scoreboard">
          <router-link
            :to="{name: 'team-detail', params: {id: item.team ? item.team.id : ''}}"
            class="team-item"
          >
            <div
              :style="{ background: (graphData.find(x => x.id === item.team.id) || { color: 'black'}).color }"
              class="team-item-color"
            >
              {{ item.rank }}位
            </div>
            <div
              v-if="item.team"
              class="team-item-content"
            >
              <div>
                {{ item.team.organization }}
              </div>
              <div>
                <div>
                  {{ item.team.name }}
                </div>
                <div>
                  {{ item.score }}<span class="unit">点</span>
                </div>
              </div>
            </div>
          </router-link>
        </template>
      </div>
    </div>
    <div
      class="right-content"
    >
      <div
        v-if="$route.query.content === 'answer-table' && problems"
      >
        <table
          class="answer-table"
        >
          <tr>
            <td />
            <template v-for="item in problems">
              <th>
                {{ item.title }}
              </th>
            </template>
          </tr>
          <template v-for="item in tableData">
            <tr
              v-bind:key="item.id"
            >
              <td
                class="team_name"
              >
                {{ item.team_name }}
              </td>
              <template v-for="point in item.points">
                <td>
                  {{ point }}
                </td>
              </template>
            </tr>
          </template>
        </table>
      </div>
      <div
        v-else
      >
        <graph
          :graph-data="graphData"
          :height="650"
          :notfound="false"
          v-loading="asyncLoading"
          title="タイトル"
          class="graph"
        />
      </div>
      <div
        class="controller"
      >
        <div>
          <div class="form-check">
            <input
              id="auto-move-checkbox"
              v-model="isAutoTransition"
              type="checkbox"
              class="form-check-input"
            >
            <label
              class="form-check-label"
              for="auto-move-checkbox"
            >
              自動遷移
            </label>
          </div>
          <input
            v-model="intervalSec"
            type="number"
            placeholder="遷移までの時間(秒)"
          >
        </div>
        <router-link
          :to="{name: 'summary', query: {content: 'graph'}}"
          class="button"
        >
          グラフ
        </router-link>
        <router-link
          :to="{name: 'summary', query: {content: 'answer-table'}}"
          class="button"
        >
          解答表
        </router-link>
      </div>
    </div>
  </div>
</template>

<style scoped>
.host {
  display: flex;
  /* 大型ディスプレイで遠くから見ることを想定し、コンテンツの横幅を拡張 */
  width: 100%;
  min-height: max-content;
  height: 100%;
  position: absolute;
  left: 0;
  right: 0;
  margin: -1rem 0;
  background-color: #34393e;
  padding: 12px 1rem 90px 1rem;
}

.right-content {
  width: 75%;
}

.graph {
  margin-left: 1rem;
  box-shadow: 0px 0px 7px 1px rgba(0,0,0,.3);
}

.answer-table {
  margin-left: 1rem;
  color: white;
  border: 1px solid #ddd;
}

.answer-table td,
.answer-table th {
  text-align: right;
  border: 1px solid #ddd;
  padding: 0 5px;
}

.team_name {
  overflow: hidden;
  white-space: nowrap;
  text-overflow: ellipsis;
  width: 8rem;
  max-width: 8rem;
}

.controller {
  display: flex;
  color: white;
  flex-grow: 1;
  justify-content: flex-end;
}

.scoreboard {
  min-width: 25rem;
  width: 25%;
}

.team-list {
  padding: 1rem;
  margin-bottom: 2rem;
  display: flex;
  flex-direction: column;
  font-weight: bold;
  background-color: #111;
  width: 100%;
  box-shadow: 0px 0px 7px 1px rgba(0,0,0,.3);
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
  display: flex;
  color: #fafbfd;
}

.team-item-content > :nth-child(2) > :nth-child(1) {
  font-size: 1.5rem;
  overflow: hidden;
  white-space: nowrap;
  text-overflow: ellipsis;
  width: 12rem;
}

.team-item-content > :nth-child(2) > :nth-child(2) {
  font-size: 1.5rem;
  white-space: nowrap;
  width: 4rem;
  padding-left: 1rem;
}

.team-item-content .unit {
  font-size: 1rem;
  padding: 0 4px;
}

.controller {
  display: flex;
  float: right;
  margin: 1rem;
}

.button {
  margin: 0 1rem;
  color: #ddd;
  border: solid 1px #ddd;
  font-size: 1.5rem;
  padding: .5rem 1.5rem;
  border-radius: 2px;
  transition: all .3s ease-out;
}

.button:hover {
  color: #fff;
  border: solid 1px #fff;
  background-color: rgba(0, 0, 0, .3)
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
      intervalId: undefined,
      intervalSec: 6,
      isAutoTransition: false
    }
  },
  asyncData: {
    teamsDefault: [],
    teams () {
      return API.getTeamsWithScore();
    },
    problems () {
      return API.getProblemsWithScore();
    },
    scoreboard () {
      return API.getScoreboard();
    },
  },
  watch: {
    isAutoTransition (val) {
      if (val) {
        this.autoTransition();
      } else {
        this.clearAutoTransition();
      }
    },
    intervalSec () {
      this.clearAutoTransition();
      if (this.isAutoTransition) {
        this.autoTransition();
      }
    }
  },
  methods: {
    autoTransition () {
      console.log('start auto transition page');
      clearInterval(this.intervalId);
      setInterval(
        this.$router.push({
          name: 'summary',
          query: {
            content: this.$route.query.content === 'answer-table' ? 'graph' : 'answer-table'
          }
        }),
        this.intervalSec
      );
    },
    clearAutoTransition () {
      clearInterval(this.intervalId);
      this.intervalId = undefined;
    }
  },
  computed: {
    graphData () {
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
    tableData () {
      return this.teams.map(team => (
        {
          team_name: team.name,
          points: this.problems.map(x => {
            const answers = Array.from(x.answers.filter(x => x.team_id === team.id))
              .sort((a, b) => +new Date(b.created_at) - +new Date(a.created_at));
            return (answers[0] && answers[0].score) ? answers[0].score.point : 0
          })
        }
      ))
    }
  },
  mounted () {
    this.$store.dispatch(SET_TITLE, 'ダッシュボード');
  },
  destroyed () {
    clearInterval(this.intervalId);
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
</style>
