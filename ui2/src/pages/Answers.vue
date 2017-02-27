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
            <router-link :to="{name: 'problem-answers', params: {id: problem.id, team: team.id}}" class="team">
              {{ team.id }}. {{ team.name }}
            </router-link>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.team {
  padding: .3rem;
  border: 1px solid #ddd;
  background: #aaa;
  border-radius: 5px;
  display: block;
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
      return API.getProblems();
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
  },
}
</script>

