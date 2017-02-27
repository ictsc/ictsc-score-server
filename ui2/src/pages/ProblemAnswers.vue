<template>
  <div>
    <div class="row">
      <div class="col-6">
        <problem :id="problemId"></problem>
      </div>
      <div class="col-6" v-loading="answersLoading">
        <problem-mode-switch :problemId="problemId" :teamId="teamId"></problem-mode-switch>

        <template v-for="answer in currentAnswers">
          <answer :value="answer" :reload="reload"></answer>
        </template>

        <div class="new-issue">
          <simple-markdown-editor v-model="newAnswer"></simple-markdown-editor>
          <div class="tools">
            <button v-on:click="postNewIssue()" class="btn btn-success">解答投稿</button>
          </div>
        </div>
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
import Answer from '../components/Answer'
import ProblemModeSwitch from '../components/ProblemModeSwitch'
import SimpleMarkdownEditor from '../components/SimpleMarkdownEditor'
import {
  Emit,
  PUSH_NOTIF,
  REMOVE_NOTIF,
  RELOAD_SESSION
} from '../utils/EventBus'

export default {
  name: 'problem-answers',
  components: {
    Problem,
    SimpleMarkdownEditor,
    Answer,
    ProblemModeSwitch,
  },
  data () {
    return {
      newAnswer: '',
    }
  },
  asyncData: {
    answersDefault: [],
    answers () {
      return API.getAnswers();
    }
  },
  computed: {
    problemId () {
      return '' + this.$route.params.id;
    },
    teamId () {
      return '' + this.$route.params.team;
    },
    currentAnswers () {
      return this.answers
        .filter(i => '' + i.problem_id === this.problemId)
        .filter(i => '' + i.team_id === this.teamId)
        // .filter(i => this.issueId === undefined || '' + i.id === this.issueId);
    },
  },
  watch: {
  },
  mounted () {
    this.$store.dispatch(SET_TITLE, '解答一覧');
  },
  destroyed () {
  },
  methods: {
    // postNewIssue () {
    //   Emit(REMOVE_NOTIF, msg => msg.key === 'issue');

    //   API.addIssues(this.problemId, this.issueTitle)
    //     .then(res => API.addIssueComment(res.id, this.issueText))
    //     .then(res => {
    //       this.issueTitle = '';
    //       this.issueText = '';
    //       this.reload();
    //       Emit(PUSH_NOTIF, {
    //         type: 'success',
    //         icon: 'check',
    //         title: '投稿しました',
    //         detail: '',
    //         key: 'login',
    //         autoClose: true,
    //       });
    //     })
    //     .catch(err => {
    //       console.log(err)
    //       Emit(PUSH_NOTIF, {
    //         type: 'error',
    //         icon: 'warning',
    //         title: '投稿に失敗しました',
    //         key: 'login',
    //         autoClose: false,
    //       });
    //     });
    // },
    reload () {
      this.asyncReload();
    }
  },
}
</script>

