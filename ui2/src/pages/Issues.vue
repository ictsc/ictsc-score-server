<template>
  <div v-loading="asyncLoading">
    <h1>質問一覧</h1>
    <div class="issue-list">
      <template v-for="item in issues" class="item">
        <router-link :to="{name: 'problem-issues', params: {id: '' + item.problem_id, team: '' + item.team_id, issue: '' + item.id}}">トップ
          <p>closed: {{ item.closed }}</p>
          <h3>{{ item.title }}</h3>
          <p>team: {{ item.team }}</p>
          <pre>{{ item.comments }}</pre>
        </router-link>
      </template>
    </div>
  </div>
</template>

<style scoped>

</style>

<script>
import { SET_TITLE } from '../store/'
import { API } from '../utils/Api'

export default {
  name: 'issues',
  data () {
    return {
    }
  },
  asyncData: {
    issuesDefault: {},
    issues () {
      return API.getIssues();
    }

  },
  computed: {
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

