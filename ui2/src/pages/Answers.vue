<template>
  <div v-loading="asyncLoading">
    <h1>解答と採点</h1>
    <div class="problems">
      <div v-for="problem in problems" class="problem">
        <h3>{{ problem.title }}</h3>
        <p><small>
          {{ problem.reference_point }} - 
          {{ problem.perfect_point }} - 
          {{ problem.solved_teams_count }}
        </small></p>
        <div class="teams row">
          <div v-for="team in teams" class="col-3">
            <router-link
              :to="{name: 'problem-answers', params: {id: problem.id, team: team.id}}"
              :class="'team status-' + status(problem.answers, team.id)">
              {{ team.id }}. {{ team.name }}
              <!--status: {{ status(problem.answers, team.id) }}
              {{ teamAnswers(problem.answers, team.id) }}-->
            </router-link>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.problem {
  margin-bottom: 2rem;
}
.team {
  padding: .3rem;
  margin-bottom: .5rem;
  border: 1px solid #ddd;
  background: #aaa;
  border-radius: 5px;
  display: block;
}
.team.status-0 {
  background: #F1F7A6;
  color: #8DA700;
}
.team.status-1 {
  background: #FFB1BC;
  color: #F00000;
}
.team.status-2 {
  background: #CBF5E0;
  color: #00A353;
}
</style>

<script>
import { SET_TITLE } from '../store/'
import { API } from '../utils/Api'

export default {
  name: 'answers',
  data () {
    return {
    }
  },
  asyncData: {
    problemsDefault: [],
    problems () {
      return API.getProblemsWithScore();
    },
    teamsDefault: [],
    teams () {
      return API.getTeams();
    },
  },
  computed: {
  },
  watch: {
  },
  mounted () {
    this.$store.dispatch(SET_TITLE, '解答と採点');
  },
  destroyed () {
  },
  methods: {
    teamAnswers (answers, teamId) {
      return answers.filter(ans => ans.team_id === teamId);
    },
    status (answers, teamId) {
      // 0 未回答  1 未採点  2 採点済み
      var teamAnswers = this.teamAnswers(answers, teamId).filter(ans => ans.completed);
      if (teamAnswers.length === 0) return 0;
      return teamAnswers
        .reduce((p, n) => Math.min(p, n.score ? 2 : 1), 2);
    },
  },
}
</script>

