<template>
  <div>
    <div class="row">
      <div class="col-6">
        <problem :id="problemId" />
      </div>
      <div
        v-loading="issuesLoading"
        class="col-6"
      >
        <problem-mode-switch
          :problemId="problemId"
          :teamId="teamId"
          :answers="answers"
        />
        
        <router-link
          v-if="isSingleIssue"
          :to="{name: 'problem-issues', params: {id: problemId, team: teamId }}"
        >
          質問一覧
        </router-link>

        <template v-if="!isSingleIssue && isParticipant">
          <h3>新規質問</h3>
          <div class="new-issue">
            <div class="answerExample">
              <h3>質問例</h3>
              <p>タイトル例：xyzについて</p>
              <p>
                質問例：<br>
                &emsp;・問題xxxに使われているhogeですが、○○という認識でよろしいでしょうか？
              </p>
              <p>&emsp;・問題yyyで使用されている機材のzzzが正しく動作していないように思われます。一度見ていただけませんか？</p>
              <p>&emsp;・○○したいのですが大丈夫でしょうか？</p>
            </div>
            <div class="form-group">
              <input
                v-model="issueTitle"
                type="text"
                class="form-control"
                placeholder="タイトルは具体的かつ端的に記入してください"
              >
            </div>
            <simple-markdown-editor v-model="issueText" />
            <div class="text-length">
              {{ issueText.length }} / {{ issueMaxLength }}文字 (目安)
            </div>
            <div class="tools">
              <button
                v-on:click="postNewIssue()"
                v-bind:disabled="!canPushSubmitButton"
                class="btn btn-success btn-block"
              >
                質問投稿
              </button>
            </div>
          </div>
        </template>

        <template v-for="issue in currentIssues">
          <issue
            :value="issue"
            :reload="reload"
          />
        </template>
      </div>
    </div>
  </div>
</template>

<style scoped>

.answerExample {
  color: #aaa;
  margin: 20px 0;
  padding: 10px 20px;
}

.answerExample h3 {
  border-bottom: 1px solid #ddd;
  padding: 5px 10px 3px;
}

.answerExample p {
  margin-bottom: 1.2rem;
}

.answerExample p:last-child {
  margin-bottom: inherit;
}

.new-issue .text-length {
  text-align: right;
}

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
  name: 'ProblemIssues',
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
      issueMaxLength: 4095,
      posting: false,
    }
  },
  asyncData: {
    issuesDefault: [],
    issues () {
      if (this.issueId) return API.getIssue(this.issueId).then(r => [r]);
      else return API.getIssuesWithComments();
    },
    answersDefault: [],
    answers () {
      return API.getTeamWithAnswers(this.teamId).then(res => res.answers)
    },
  },
  computed: {
    problemId () {
      return '' + this.$route.params.id;
    },
    teamId () {
      return '' + this.$route.params.team;
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
    // 文字数が文字数制限以下かどうか
    canPushSubmitButton () {
      return this.issueText.length <= this.issueMaxLength && !this.posting;
    },
    ...mapGetters([
      'isParticipant',
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

