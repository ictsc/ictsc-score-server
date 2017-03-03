<template>
  <div>
    <div class="row">
      <div class="col-6">
        <problem :id="problemId"></problem>
      </div>
      <div class="col-6" v-loading="issuesLoading">
        <problem-mode-switch :problemId="problemId" :teamId="teamId"></problem-mode-switch>
        
        <router-link v-if="isSingleIssue" :to="{name: 'problem-issues', params: {id: problemId, team: teamId }}">
          質問一覧
        </router-link>

        <template v-if="!isSingleIssue && isMember">
          <h3>新規質問</h3>
          <div class="new-issue">
            <div class="form-group">
              <input v-model="issueTitle" type="text" class="form-control"
                placeholder="タイトルは具体的かつ端的に記入してください">
            </div>
            <simple-markdown-editor v-model="issueText"></simple-markdown-editor>
            <div class="tools">
              <button v-on:click="postNewIssue()" class="btn btn-secondary" :disabled="posting">質問投稿</button>
            </div>
          </div>
        </template>

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
import ProblemModeSwitch from '../components/ProblemModeSwitch'
import SimpleMarkdownEditor from '../components/SimpleMarkdownEditor'
import {
  Emit,
  PUSH_NOTIF,
  REMOVE_NOTIF
} from '../utils/EventBus'
import { mapGetters } from 'vuex'

export default {
  name: 'problem-issues',
  components: {
    Problem,
    Issue,
    SimpleMarkdownEditor,
    ProblemModeSwitch,
  },
  data () {
    return {
      issueTitle: '',
      issueText: '',
      posting: false,
    }
  },
  asyncData: {
    issuesDefault: [],
    issues () {
      if (this.issueId) return API.getIssue(this.issueId).then(r => [r]);
      else return API.getIssues();
    },
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
    isSingleIssue () {
      return !!this.issueId;
    },
    currentIssues () {
      return this.issues
        .filter(i => '' + i.problem_id === this.problemId)
        .filter(i => '' + i.team_id === this.teamId)
        // .filter(i => this.issueId === undefined || '' + i.id === this.issueId);
    },
    ...mapGetters([
      'isMember',
      'session',
    ]),
  },
  watch: {
    problemId (val, old) {
      if (val !== old) {
        this.asyncReload('issues');
      }
    },
    teamId (val, old) {
      if (val !== old) {
        this.asyncReload('issues');
      }
    },
    issueId (val, old) {
      if (val !== old) {
        this.asyncReload('issues');
      }
    },
  },
  mounted () {
    this.$store.dispatch(SET_TITLE, '質問一覧');
  },
  destroyed () {
  },
  methods: {
    async postNewIssue () {
      this.posting = true;
      Emit(REMOVE_NOTIF, msg => msg.key === 'issue');

      try {
        var res = await API.addIssues(this.problemId, this.issueTitle)
        await API.addIssueComment(res.id, this.issueText);

        this.issueTitle = '';
        this.issueText = '';
        this.reload();
        Emit(PUSH_NOTIF, {
          type: 'success',
          title: '投稿しました',
          detail: '',
          key: 'login',
        });
      } catch (err) {
        console.log(err)
        Emit(PUSH_NOTIF, {
          type: 'error',
          title: '投稿に失敗しました',
          key: 'login',
        });
      }
      this.posting = false;
    },
    reload () {
      this.asyncReload();
    }
  },
}
</script>

