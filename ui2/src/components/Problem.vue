<template>
  <div v-loading="asyncLoading" class="problem">
    <div v-if="problemError" class="alert alert-danger">
      問題の取得にエラーが発生しました
    </div>
    <header>
      <div v-if="isAdmin" class="switch">
        <template v-if="edit">
          <button v-on:click="editCancel()" class="btn btn-secondary">キャンセル</button>
          <button v-on:click="editSubmit()" class="btn btn-success">保存</button>
        </template>
        <button v-else v-on:click="editEnter()" class="btn btn-secondary">編集</button>
      </div>
      <h2>
        <span class="sub">問題2:</span>
        <input v-if="edit" v-model="problem.title" type="text" class="form-control form-control-lg">
        <span v-else>{{ problem.title }}</span>
      </h2>
      <div class="meta">公開　{{ problem.created_at }}　|　更新　{{ problem.updated_at }}</div>
      <div class="point">
        <template v-if="edit">
          <div class="form-group row">
            <label class="col-2 col-form-label">満点</label>
            <div class="col-10">
              <input v-model="problem.perfect_point" class="form-control" type="number">
            </div>
          </div>
          <div class="form-group row">
            <label class="col-2 col-form-label">基準点</label>
            <div class="col-10">
              <input v-model="problem.reference_point" class="form-control" type="number">
            </div>
          </div>
        </template>
        <template v-else>
          満点: {{ problem.perfect_point }}
          基準点: {{ problem.reference_point }}
          通過チーム数: {{ problem.solved_teams_count }}
        </template>
      </div>
    </header>
    <aside>
      <h3><span class="sub">補足事項:</span></h3>
      <div class="comment">
        <p>補足事項</p>
        <div class="meta">01/01 00:00</div>
      </div>
      <div class="comment">
        <p>補足事項</p>
        <div class="meta">01/01 00:00</div>
      </div>
    </aside>
    <article>
      <h3><span class="sub">問題:</span></h3>
      <simple-markdown-editor v-if="edit" v-model="problem.text"></simple-markdown-editor>
      <markdown v-else :value="problem.text"></markdown>
    </article>
  </div>
</template>

<style scoped>
.problem .sub {
  display: block;
  font-size: .9rem;
  color: #95989A;
  margin-bottom: .5em;
}
.problem .meta {
  text-align: right;
  color: #95989A;
  font-size: .9rem;
}

.problem header {
  margin-bottom: 1rem;
}
.problem header h2 {
  border-bottom: 1px solid #FDBBCC;
  font-size: 2.5rem;
  padding-bottom: .5rem;
}

.problem aside .comment {
  background: #FCF0F0;
  border-radius: 10px;
  padding: 1rem;
}

.problem aside .comment {
  margin-bottom: 1rem;
}

.switch {
  text-align: right;
}
</style>

<script>
import { SET_TITLE } from '../store/'
import { API } from '../utils/Api'
import SimpleMarkdownEditor from '../components/SimpleMarkdownEditor'
import Markdown from '../components/Markdown'
import { mapGetters } from 'vuex'

export default {
  name: 'empty',
  props: {
    id: String,
  },
  components: {
    SimpleMarkdownEditor,
    Markdown,
  },
  data () {
    return {
      edit: false,
    }
  },
  asyncData: {
    problemDefault: {},
    problem () {
      return API.getProblem(this.id);
    },
  },
  computed: {
    ...mapGetters([
      'isAdmin',
    ]),
  },
  watch: {
    id (val) {
      if (val !== undefined) {
        this.asyncReload();
      }
    },
  },
  mounted () {
    this.$store.dispatch(SET_TITLE, 'ページ名');
  },
  destroyed () {
  },
  methods: {
    editEnter () {
      this.edit = true;
    },
    editCancel () {
      this.asyncReload();
      this.edit = false;
    },
    editSubmit () {
      // todo
    },
  },
}
</script>

