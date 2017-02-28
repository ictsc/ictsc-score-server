<template>
  <div v-loading="asyncLoading">
    <h1>到着質問</h1>
    <div class="issue-list">
      <template v-for="item in issues" class="">
        <router-link
          :to="{name: 'problem-issues', params: {id: '' + item.problem_id, team: '' + item.team_id, issue: '' + item.id}}"
          class="item d-flex align-items-center">
          <div class="status">
            <button v-if="item.closed" class="btn btn-success">解決済</button>
            <button v-else class="btn btn-warning">対応中</button>
          </div>
          <div class="title">
            <h4>問題タイトル</h4>
            <h3>{{ item.title }}</h3>
            <p>team: {{ item.team }}</p>
          </div>
          <div class="comments head">
            <div class="content">{{ firstComment(item.comments).text }}</div>
            <div class="meta">チーム名 参加者: {{ firstComment(item.comments).member_id }}</div>
          </div>
          <div class="comments answer">
            <div class="content">{{ lastResponseComment(item.comments).text }}</div>
            <div class="meta">チーム名 参加者</div>
          </div>
        </router-link>
      </template>
    </div>
  </div>
</template>

<style scoped>
.item {
  color: inherit;
  border-bottom: 1px solid #FDBBCC;
  padding: 1rem 0;
  margin: 1rem 0;
}
.item .status {
  flex-basis: 7rem;
  text-align: center;
  flex-shrink: 0;
  flex-grow: 0;
}
.item .title {
  flex-shrink: 0;
  flex-grow: .5;
  flex-basis: 15rem;
  min-width: 15rem;
}
.item .comments {
  min-width: 15rem;
  min-height: 5rem;
  flex-basis: 15rem;
  flex-grow: 1;
  background: #ddd;
  margin: 0 1rem;
  padding: 1rem;
  border-radius: 10px;
}
.item .comments .meta {
  color: #aaa;
  text-align: right;
  font-size: .9em;
}
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
    },
  },
  computed: {
  },
  watch: {
  },
  mounted () {
    this.$store.dispatch(SET_TITLE, '到着質問');
  },
  destroyed () {
  },
  methods: {
    firstComment (comments) {
      return comments[0] || {};
    },
    lastResponseComment (comments) {
      // todo admin filter
      if (comments.length < 2) return {};
      return comments[comments.length - 1];
    },
  },
}
</script>

