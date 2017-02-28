<template>
  <div>
    <div class="answers">
      <div class="scoring">
        {{ scores }}
        <div class="row">
          <div class="col-6">
            <input type="number" class="form-control">
          </div>
          <div class="col-6">
            <button type="submit" class="btn btn-primary">採点</button>
          </div>
        </div>
      </div>
      <div v-if="value.comments" v-for="answer in value.comments" class="answer">
        <markdown :value="answer.text"></markdown>
        <div class="meta">
          <small>{{ answer.created_at }}</small>
        </div>
      </div>
      <div class="status">
        <template v-if="value.completed">
          <div v-if="isScored === true" class="result">
            得点: {{ point }} + ボーナス: {{ bonusPoint }}
            <span v-if="isFirstBlood">FirstBlood!</span>
          </div>
          <div v-if="isScored === false" class="pending">採点依頼中...</div>
        </template>
        <div v-else class="send">
          <button v-on:click="sendRequest()" class="btn btn-block btn-secondary">採点依頼を送る</button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.answers {
  border: 1px solid #fdbbcc;
  padding: 1rem;
  padding-bottom: 0;
  margin-bottom: 2rem;
}
.answer {
  margin-bottom: 1rem;
}
.status {
  margin: 0 -1rem;
  text-align: center;
}
.status .pending {
  background: #fdbbcc;
  color: white;
  padding: .5rem;
}
.status .result {
  background: #ed1848;
  color: white;
  padding: .5rem;
}
.status .send {
  padding: .5rem;
  margin: auto;
  width: 15rem;
}

.scoring {
}
</style>

<script>
import SimpleMarkdownEditor from '../components/SimpleMarkdownEditor'
import Markdown from '../components/Markdown'
import { Emit, PUSH_NOTIF, REMOVE_NOTIF } from '../utils/EventBus'
import { API } from '../utils/Api'

export default {
  name: 'answer',
  components: {
    SimpleMarkdownEditor,
    Markdown,
  },
  props: {
    value: Object,
    scores: Array,
    reload: Function,
  },
  data () {
    return {
      post: '',
    }
  },
  asyncData: {
  },
  computed: {
    issueId () {
      return this.value.id;
    },
    isScored () {
      if (this.scoresLoading) return undefined;
      else if (this.scores.length === 0) return false;
      else return true
    },
    point () {
      return this.scores.reduce((p, n) => p + n.point, 0);
    },
    bonusPoint () {
      return this.scores.reduce((p, n) => p + n.bonus_point, 0);
    },
    isFirstBlood () {
      return this.scores.reduce((p, n) => p || n.is_firstblood, false);
    },
  },
  watch: {
  },
  mounted () {
  },
  destroyed () {
  },
  methods: {
    sendRequest () {
      Emit(REMOVE_NOTIF, msg => msg.key === 'answer');
      API.patchAnswers(this.value.id, {
        completed: true,
      })
        .then(res => {
          console.log('Patch OK');
          Emit(PUSH_NOTIF, {
            type: 'success',
            icon: 'check',
            title: '投稿しました',
            detail: '',
            key: 'issue',
            autoClose: true,
          });
          if (this.reload.apply) this.reload();
        })
        .catch(err => {
          console.error(err);
          Emit(PUSH_NOTIF, {
            type: 'error',
            icon: 'warning',
            title: '投稿に失敗しました',
            key: 'issue',
            autoClose: false,
          });
        })
    },
  },
}
</script>

