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
  REMOVE_NOTIF
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
    currentAnswers () {
      return this.answers
        .filter(i => '' + i.problem_id === this.problemId)
        .filter(i => '' + i.team_id === this.teamId)
        // .filter(i => this.issueId === undefined || '' + i.id === this.issueId);
    },
  },
  watch: {
    teamId () {
      this.asyncReload('answers');
    },
  },
  mounted () {
    this.$store.dispatch(SET_TITLE, '解答一覧');
  },
  destroyed () {
  },
  methods: {
    async postNewIssue () {
      try {
        Emit(REMOVE_NOTIF, msg => msg.key === 'answer');

        var answers = await API.getAnswers();
        var filteredAnswer = answers
          .filter(i => '' + i.problem_id === this.problemId)
          .filter(i => '' + i.team_id === this.teamId);

        // 解答が無い・最後の解答がcompletedである場合、新規作成
        var answer;
        if (filteredAnswer.length === 0 || filteredAnswer[filteredAnswer.length - 1].completed) {
          answer = await API.postAnswers(this.teamId, this.problemId);
        } else {
          answer = filteredAnswer[filteredAnswer.length - 1]
        }

        await API.addAnswerComment(answer.id, this.newAnswer);

        this.newAnswer = '';
        this.reload();
        Emit(PUSH_NOTIF, {
          type: 'success',
          title: '投稿しました',
          detail: '',
          key: 'answer',
        });
      } catch (err) {
        console.error(err);
        Emit(PUSH_NOTIF, {
          type: 'error',
          title: '投稿に失敗しました',
          key: 'answer',
        });
      }
    },
    reload () {
      this.asyncReload();
    }
  },
}
</script>
