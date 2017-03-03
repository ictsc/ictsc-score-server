<template>
  <div>
    <h1>質問一覧</h1>
    <div class="tools">
      <button v-on:click="filterSelect = 0" :class="{ active: filterSelect == 0 }" class="btn label-secondary">全て</button>
      <button v-on:click="filterSelect ^= 1" :class="{ active: filterSelect & 1 }" class="btn label-danger">未回答</button>
      <button v-on:click="filterSelect ^= 2" :class="{ active: filterSelect & 2 }" class="btn label-warning">対応中</button>
      <button v-on:click="filterSelect ^= 4" :class="{ active: filterSelect & 4 }" class="btn label-success">解決済</button>
    </div>
    <div v-loading="asyncLoading" class="issue-list">
      <template v-for="item in currentIssues" class="">
        <router-link
          :to="{name: 'problem-issues', params: {id: '' + item.problem_id, team: '' + item.team_id, issue: '' + item.id}}"
          class="item d-flex align-items-center">
          <div class="status">
            <button v-if="item.status === 3" class="btn label-success">解決済</button>
            <button v-else-if="item.status === 2" class="btn label-warning">対応中</button>
            <button v-else-if="item.status === 1" class="btn label-danger">未回答</button>
          </div>
          <div class="title">
            <h4>{{ item.problem ? item.problem.title : '???' }}</h4>
            <h3>{{ item.title }}</h3>
            <p v-if="item.team">{{ item.team.id }}. {{ item.team.name }}</p>
            <p v-else>???</p>
          </div>
          <div class="comments head">
            <div class="content">{{ firstComment(item.comments).text }}</div>
            <div class="meta">チーム名 参加者: {{ firstComment(item.comments).member.name }}</div>
          </div>
          <template v-if="lastResponseComment(item.comments).member">
            <div  class="comments answer">
              <div class="content">{{ lastResponseComment(item.comments).text }}</div>
              <div class="meta">チーム名 {{ lastResponseComment(item.comments).member.name }}</div>
            </div>
          </template>
          <template v-else>
            <div  class="comments answer empty">
            </div>
          </template>
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
.item .comments.answer {
  background: #F0F0F0;
}
.item .comments .meta {
  color: #aaa;
  text-align: right;
  font-size: .9em;
}

.tools {
  text-align: center;
  margin: 3rem 0;
}
.tools button {
  margin: .3rem;
}
</style>

<script>
import { SET_TITLE } from '../store/'
import { API } from '../utils/Api'
import { issueStatus } from '../utils/Filters'

export default {
  name: 'issues',
  data () {
    return {
      filterSelect: 0,
    }
  },
  asyncData: {
    issuesDefault: [],
    issues () {
      return API.getIssuesWithComments()
        .then(res => {
          return res.map(issue => {
            issue.status = issueStatus(issue);
            return issue;
          });
        });
    },
  },
  computed: {
    currentIssues () {
      return this.issues.filter(i =>
        !this.filterSelect ||
        (this.filterSelect & 1) === i.status ||
        (this.filterSelect & 2) === i.status ||
        (this.filterSelect & 4) === i.status + 1
      )
    }
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
      var notWriterComment = comments.filter(c => c.member.role_id !== 4);
      if (notWriterComment.length === 0) return {};
      return notWriterComment[notWriterComment.length - 1];
    },
  },
}
</script>

