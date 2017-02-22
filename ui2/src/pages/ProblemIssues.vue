<template>
  <div>
    <div class="row">
      <div class="col-6">
        <problem :id="problemId"></problem>
      </div>
      <div class="col-6">
        <h3>質問</h3>
        <!--<pre>{{ currentIssues }}</pre>-->
        <div class="new-issue">
          <input v-model="issueTitle" type="text" class="form-control"
            placeholder="タイトルは具体的かつ端的に記入してください">
          <simple-markdown-editor v-model="issueText"></simple-markdown-editor>
          <div class="tools">
            <button v-on:click="postNewIssue()" class="btn btn-success">質問投稿</button>
          </div>
        </div>

        <template v-for="issue in currentIssues">
          <issue :value="issue" :reload="reload"></issue>
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
import SimpleMarkdownEditor from '../components/SimpleMarkdownEditor'
import {
  Emit,
  PUSH_NOTIF,
  REMOVE_NOTIF,
  RELOAD_SESSION
} from '../utils/EventBus'

export default {
  name: 'problem-issues',
  components: {
    Problem,
    Issue,
    SimpleMarkdownEditor,
  },
  data () {
    return {
      issueTitle: '',
      issueText: '',
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
    postNewIssue () {
      Emit(REMOVE_NOTIF, msg => msg.key === 'issue');

      API.addIssues(this.problemId, this.issueTitle)
        .then(res => API.addIssueComment(res.id, this.issueText))
        .then(res => {
          this.issueTitle = '';
          this.issueText = '';
          this.reload();
          Emit(PUSH_NOTIF, {
            type: 'success',
            icon: 'check',
            title: '投稿しました',
            detail: '',
            key: 'login',
            autoClose: true,
          });
        })
        .catch(err => {
          console.log(err)
          Emit(PUSH_NOTIF, {
            type: 'error',
            icon: 'warning',
            title: '投稿に失敗しました',
            key: 'login',
            autoClose: false,
          });
        });
    },
    reload () {
      this.asyncReload();
    }
  },
}
</script>

