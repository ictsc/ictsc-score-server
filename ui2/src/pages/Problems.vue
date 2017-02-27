<template>
  <div v-loading="asyncLoading">
    <h1>問題一覧</h1>
    <div class="description">
      <p>出題ルール書いといたほうがよさそう。</p>
      <p>A〜F社から各問題が1第ずつ出題されます。採点基準を満たす解答をすると、次の問題が解答できるようになります。とか。</p>
    </div>

    <div class="groups">
      <div v-for="group in problemGroups" class="group row">
        <div class="col-6">
          <div class="detail">
            <h2>{{ group.name }}</h2>
            <markdown :value="group.description"></markdown>
          </div>
        </div>
        <div class="col-6">
          <div class="problems">
            <a href="#" class="problem d-flex">
              <div class="scores-wrapper">
                <div class="scores">
                  <div class="current">40</div>
                  <div class="max">50点満点</div>
                </div>
              </div>
              <div class="content">
                <h3>title</h3>
                <div class="tips">
                  <span>解答 1件 (1分前)</span>
                  <span>採点 1件 (1分前)</span>
                  <span>質問 3件 (1時間前)</span>
                </div>
              </div>
            </a>
            <a class="problem d-flex">
              <div class="overlay">
                <div class="overlay-message">
                  採点基準クリアで解禁
                </div>
              </div>
              <div class="scores-wrapper">
                <div class="scores">
                  <div class="current">40</div>
                  <div class="max">50点満点</div>
                </div>
              </div>
              <div class="content">
                <h3>titletitletitletitltitletitletitletitltitletitletitletitltitletitletitletitltitletitletitletitltitletitletitletitl</h3>
                <div class="tips">
                  <span>解答 1件 (1分前)</span>
                  <span>採点 1件 (1分前)</span>
                  <span>質問 3件 (1時間前)</span>
                </div>
              </div>
            </a>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.groups {
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
  font-weight: bold;
  flex-grow: 1;
  text-align: center;
  margin: auto;
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
}

</style>

<script>
import { SET_TITLE } from '../store/'
import { API } from '../utils/Api'
import Markdown from '../components/Markdown'

export default {
  name: 'problems',
  components: {
    Markdown,
  },
  data () {
    return {
    }
  },
  asyncData: {
    problemGroupsDefault: [],
    problemGroups () {
      return API.getProblemGroups();
    }
  },
  computed: {
  },
  watch: {
  },
  mounted () {
    this.$store.dispatch(SET_TITLE, '問題一覧');
  },
  destroyed () {
  },
  methods: {
  },
}
</script>

