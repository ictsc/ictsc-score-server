<template>
  <div>
    <div class="row">
      <div class="col-6">
        <problem :id="problemId"></problem>
      </div>
      <div class="col-6">
        <h3>質問</h3>
        <!--<pre>{{ currentIssues }}</pre>-->
        <template v-for="issue in currentIssues">
          <issue :value="issue"></issue>
        </template>
      </div>
    </div>
  </div>
</template>

<style scoped>

</style>

<script>
import { SET_TITLE } from '../store/'
import { API } from '../utils/Api'
import Problem from '../components/Problem'
import Issue from '../components/Issue'

export default {
  name: 'problem-issues',
  components: {
    Problem,
    Issue,
  },
  data () {
    return {
    }
  },
  asyncData: {
    issuesDefault: [],
    issues () {
      return API.getIssues();
    }
  },
  computed: {
    problemId () {
      return this.$route.params.id;
    },
    teamId () {
      return this.$route.params.team;
    },
    issueId () {
      return this.$route.params.issue;
    },
    currentIssues () {
      return this.issues
        .filter(i => '' + i.problem_id === this.problemId)
        .filter(i => '' + i.team_id === this.teamId)
        .filter(i => this.issueId === undefined || '' + i.id === this.issueId);
    },
  },
  watch: {
  },
  mounted () {
    this.$store.dispatch(SET_TITLE, '質問一覧');
  },
  destroyed () {
  },
  methods: {
  },
}
</script>

