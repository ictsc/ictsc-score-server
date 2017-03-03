<template>
  <div>
    <div class="fixed-tool-tips">
      <div v-on:click="showAdd = true" class="add"><i class="fa fa-plus"></i></div>
    </div>
    <message-box v-model="showAdd">
      <span slot="title">新規問題</span>
      <div slot="body">
        <div class="form-group row">
          <label class="col-sm-2 col-form-label">グループ</label>
          <div class="col-sm-10">
            <select class="form-control" v-model="newObj.problem_group_id">
              <option v-for="group in problemGroups" :value="group.id">{{ group.name }}</option>
            </select>
          </div>
        </div>
        <div class="form-group row">
          <label class="col-sm-2 col-form-label">依存問題</label>
          <div class="col-sm-10">
            <select class="form-control" v-model="newObj.problem_must_solve_before_id">
              <option v-for="problem in problemSelect" :value="problem.id">{{ problem.title }}</option>
            </select>
          </div>
        </div>
        <div class="form-group row">
          <label class="col-sm-2 col-form-label">Title</label>
          <div class="col-sm-10">
            <input v-model="newObj.title" type="text" class="form-control" placeholder="タイトル">
          </div>
        </div>
        <div class="form-group row">
          <label class="col-sm-2 col-form-label">基準点</label>
          <div class="col-sm-10">
            <input v-model="newObj.reference_point" type="number" class="form-control">
          </div>
        </div>
        <div class="form-group row">
          <label class="col-sm-2 col-form-label">満点</label>
          <div class="col-sm-10">
            <input v-model="newObj.perfect_point" type="number" class="form-control">
          </div>
        </div>
        
        <simple-markdown-editor v-model="newObj.text"></simple-markdown-editor>
      </div>
      <template slot="buttons" scope="props">
        <button v-on:click="addProblem()" class="btn btn-lg btn-success">
          <i class="fa fa-plus"></i> 問題を追加する
        </button>
      </template>
    </message-box>

    <h1>問題一覧</h1>
    <div class="description">
      <p>
        問題グループごとに複数の問題が有ります。
      </p>
      <p>
        それぞれの問題に設定されて基準点をクリアすると、次の問題が解禁されます。
      </p>

      <div class="steps d-flex">
        <div class="item">
          <h4>各社から問題を選んで解答</h4>
          <p>解禁されている問題を選択し、解答を行ってください。</p>
        </div>
        <div class="item">
          <h4>採点依頼</h4>
          <p>解答を送信後、採点依頼ボタンをクリックして運営に送信してください。</p>
        </div>
        <div class="item">
          <h4>運営が採点 (20分間)</h4>
          <p>運営が採点中はその会社の問題を解けません。</p>
        </div>
        <div class="item">
          <h4>採点結果を確認</h4>
          <p>高得点を目指して追加の解答も可能です。</p>
        </div>
      </div>
      <div class="alert alert-warning" role="alert">
        <h4 class="alert-heading">問題解答の注意点</h4>
        <ul>
          <li>問題に解答して保存しても、「採点依頼」を送信しないと運営に採点されません。</li>
          <li>採点結果は、採点依頼を送信してから20分後に帰ってきます。</li>
          <li>採点依頼中はその会社の問題を解くことはできません。</li>
        </ul>
      </div>
    </div>

    <div v-loading="asyncLoading" class="groups">
      <div v-for="group in problemGroups" class="group row">
        <div class="col-5">
          <div class="detail">
            <h2>{{ group.name }}</h2>
            <markdown :value="group.description"></markdown>
          </div>
        </div>
        <div class="col-7">
          <div class="problems">
            <template v-for="problem in problems">
              <router-link
                v-if="group.id === problem.problem_group_id"
                :to="{ name: 'problem-detail', params: { id: '' + problem.id } }"
                class="problem d-flex">
                <div v-if="problem.title === undefined" class="overlay">
                  <div class="overlay-message">
                    <div>採点基準クリアで解禁</div>
                    <div><small>
                      依存問題: {{ problemTitle(problem.problem_must_solve_before_id) }}
                    </small></div>
                  </div>
                </div>
                <div class="scores-wrapper">
                  <div class="scores">
                    <div class="current">{{ getScore(problem.answers) }}</div>
                    <div class="max">{{ problem.perfect_point }}点満点</div>
                  </div>
                </div>
                <div class="content">
                  <h3>{{ problem.title }}</h3>
                  <div class="tips">
                    <span><i class="fa fa-pencil-square-o"></i> 解答 {{ answerCount(problem.id) }}件</span>
                    <span v-if="isMember"><i class="fa fa-check-circle"></i> 採点: {{ scoringTime(problem.answers) }} </span>
                    <span><i class="fa fa-question-circle"></i> 質問 {{ issueCount(problem.id) }}件</span>
                    <span><i class="fa fa-child"></i> {{ problem.solved_teams_count }}チーム正解</span>
                  </div>
                </div>
              </router-link>
            </template>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.fixed-tool-tips {
  position: fixed;
  top: 5rem;
  right: 3rem;
  z-index: 1;
}
.fixed-tool-tips > * {
  cursor: pointer;
  padding: 1rem;
  background: #888;
  color: white;
  line-height: 1;
  border-radius: 50%;
  font-size: 2rem;
}

.groups {
  min-height: 15rem;
}
.group {
  border-top: 1px solid #FDBBCC;
  padding: 2rem;
}
.group h2 {
  color: #FDBBCC;
  font-size: 2.5rem;
}

.problems {
}
.problem {
  background: #FCEFF2;
  border: 1px solid #FDBBCC;
  margin-bottom: 2rem;
  border-radius: 10px;
  overflow: hidden;
  flex-wrap: nowrap;
  position: relative;
  display: block;
  color: inherit;
  text-decoration: none;
}
.problem .scores-wrapper {
  flex-basis: 8em;
  flex-shrink: 0;
  flex-grow: 0;
  background: #FDC1D0;
  display: flex;
}
.problem .scores {
  margin: auto;
  flex-grow: 1;
  text-align: center;
  color: white;
  font-weight: bold;
  padding: .5rem 0;
}
.problem .scores .current {
  color: #E6003B;
  font-size: 2.5rem;
  border-bottom: 1px solid #FCEFF2;
  margin: 0 .5rem .3rem;
  line-height: 1.3
}
.problem .overlay {
  position: absolute;
  background: rgba(19,37,48,0.7);
  top: 0;
  bottom: 0;
  left: 0;
  right: 0;
  display: flex;
}
.problem .overlay .overlay-message {
  color: white;
  font-size: 2rem;
  line-height: 1;
  font-weight: bold;
  flex-grow: 1;
  text-align: center;
  margin: auto;
}
.problem .overlay .overlay-message small {
  font-size: .6em;
}

.problem .content {
  margin: auto;
  flex-grow: 1;
  padding: .5rem 2rem;
  min-width: 10rem;
}
.problem .content h3 {
  overflow-wrap: break-word;
}
.problem .content .tips {
  list-style: none;
  color: #D19696;
}
.problem .content .tips > * {
  margin-right: .7rem;
}

.description {
  margin-bottom: 4rem;
}

.steps {
  margin: 2rem 0;
}
.steps .item {
  flex-grow: 1;
  min-width: 5rem;
  padding: 1rem;
  padding-right: 4rem;
  background: #efefef;
  position: relative;
  background-image: url('../assets/img/arrow.svg');
  background-repeat: repeat-y;
  background-position: right center;
}
.steps .item:last-child {
  background-image: none;
  padding-right: 1rem;  
}
.steps .item p {
  margin: 0;
}
</style>

<script>
import { SET_TITLE } from '../store/'
import { API } from '../utils/Api'
import Markdown from '../components/Markdown'
import MessageBox from '../components/MessageBox'
import SimpleMarkdownEditor from '../components/SimpleMarkdownEditor'
import { mapGetters } from 'vuex'
import { Emit, PUSH_NOTIF, REMOVE_NOTIF } from '../utils/EventBus'
import { dateRelative } from '../utils/Filters'

export default {
  name: 'problems',
  components: {
    Markdown,
    MessageBox,
    SimpleMarkdownEditor,
  },
  filters: {
    dateRelative,
  },
  data () {
    return {
      showAdd: false,
      newObj: {
        title: '',
        text: '',
        reference_point: 0,
        perfect_point: 0,
        problem_group_id: '',
        problem_must_solve_before_id: null,
      },
    }
  },
  asyncData: {
    problemGroupsDefault: [],
    problemGroups () {
      return API.getProblemGroups();
    },
    problemsDefault: [],
    problems () {
      console.log('problems', this.session, this.isMember)
      if (this.session.member) {
        if (this.isMember) {
          return API.getProblemsWithScore();
        } else {
          return API.getProblems();
        }
      } else {
        return new Promise((resolve) => resolve([]));
      }
    },
    answersDefault: [],
    answers () {
      return API.getAnswers();
    },
    issuesDefault: [],
    issues () {
      return API.getIssues();
    },
    contentDefault: {},
    contest () {
      return API.getContest();
    }
  },
  computed: {
    problemSelect () {
      return Array.concat([{
        id: null,
        title: 'Null',
      }], this.problems);
    },
    ...mapGetters([
      'isMember',
      'session',
    ]),
  },
  watch: {
    problemGroups (val) {
      try {
        this.newObj.problem_group_id = val[0].id;
      } catch (e) {
      }
    },
    session (val) {
      if (val.member) this.asyncReload('problems');
    },
  },
  mounted () {
    this.$store.dispatch(SET_TITLE, '問題一覧');
  },
  destroyed () {
  },
  methods: {
    answerCount (problemId) {
      return this.answers
        .filter(a => a.problem_id === problemId)
        .reduce((p, n) => p + 1, 0);
    },
    issueCount (problemId) {
      return this.issues
        .filter(a => a.problem_id === problemId)
        .reduce((p, n) => p + 1, 0);
    },
    scoringTime (answers) {
      if (!answers || answers.length === 0) {
        return '採点依頼無し'
      } else if (answers.filter(ans => !ans.completed).length !== 0) {
        return '採点依頼無し';
      } else {
        var completedAt = answers[answers.length - 1].completed_at;
        var publishAt = new Date(completedAt).valueOf() +
          (this.contest ? this.contest.answer_reply_delay_sec * 1000 : 0);
        return dateRelative(publishAt);
      }
    },
    getScore (answers) {
      if (!answers) return 0;
      return answers
        .filter(ans => ans.team_id === (this.session.member && this.session.member.team_id))
        .reduce((p, n) => p + n.score.point, 0);
    },
    problemTitle (id) {
      var found = this.problems.find(p => p.id === id);
      if (found && found.title) return `${found.title} ${found.reference_point}点`;
      else return '???';
    },
    async addProblem () {
      console.log(this.newObj);
      try {
        Emit(REMOVE_NOTIF, msg => msg.key === 'problem');
        await API.postProblems(this.newObj);
        this.newObj.title = '';
        this.newObj.text = '';
        Emit(PUSH_NOTIF, {
          type: 'success',
          title: '投稿しました',
          detail: '',
          key: 'problem',
        });
        this.asyncReload('problems');
      } catch (err) {
        console.log(err)
        Emit(PUSH_NOTIF, {
          type: 'error',
          title: '投稿に失敗しました失敗しました',
          detail: '',
          key: 'problem',
        });
      }
    },
  },
}
</script>

