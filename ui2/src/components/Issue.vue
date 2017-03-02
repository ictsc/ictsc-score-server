<template>
  <div>
    <div class="head">
      <div class="body d-flex">
        <div class="status">
          <div>
            <button v-if="value.closed" v-on:click="switchClosed()" class="btn btn-secondary">Closed</button>
            <button v-else v-on:click="switchClosed()" class="btn btn-secondary">Opened</button>
          </div>
          <div><small>解決したら<br>クリック</small></div>
        </div>
        <div class="content">
          <router-link :to="{name: 'problem-issues', params: {id: '' + value.problem_id, team: '' + value.team_id, issue: '' + value.id}}">
            <h3>{{ value.title }}</h3>
          </router-link>
          <!--<pre>{{ value }}</pre>-->
          <markdown :value="firstComment.text"></markdown>
        </div>
      </div>
      <div class="meta">
        投稿　{{ value.created_at }}　|　更新　{{ value.updated_at }}
      </div>
    </div>
    <div class="tail">
      <div v-for="item in tailComment" class="item" :class="{ admin: item.member.role_id === 2 }">
        <div class="comment">
          <markdown :value="item.text"></markdown>
        </div>
        <div class="meta">投稿者: {{ item.member.name }} | {{ item.created_at }}</div>
      </div>
    </div>
    <div class="post">
      <simple-markdown-editor v-model="post"></simple-markdown-editor>
      <div class="tools">
        <button v-on:click="postComment()" class="btn btn-success">投稿</button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.head {
  margin-bottom: 1rem;
}
.head .status {
  flex-shrink: 0;
  flex-grow: 0;
  text-align: center;
  margin-right: 2rem;
}
.head .content {
}
.head .body {
  padding: 2rem 0;
  border-bottom: 1px solid #FDBBCC;
  margin: .5rem 0;
}
.meta {
  text-align: right;
  font-size: .8rem;
  color: #95989A;
}

.tail .item {
  margin: 0 0 2rem 5rem;
}
.tail .item .comment {
  background: #F0F0F0;
  /*margin: 0 0 0 5rem;*/
  padding: .7rem;
  border-radius: 10px;
}
.tail .item.admin {
  margin-right: 5rem;
  margin-left: 0;
}
.tail .item.admin .comment {
  background: #D8D8D8;
}

.post .tools {
  text-align: right;
}
</style>

<script>
import SimpleMarkdownEditor from '../components/SimpleMarkdownEditor'
import Markdown from '../components/Markdown'
import { Emit, PUSH_NOTIF, REMOVE_NOTIF } from '../utils/EventBus'
import { API } from '../utils/Api'

export default {
  name: 'issue',
  components: {
    SimpleMarkdownEditor,
    Markdown,
  },
  props: {
    value: Object,
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
    firstComment () {
      if (this.value && this.value.comments && this.value.comments[0]) {
        return this.value.comments[0];
      } else {
        return {}
      }
    },
    tailComment () {
      if (this.value && this.value.comments) {
        return this.value.comments.slice(1);
      } else {
        return []
      }
    },
    issueId () {
      return this.value.id;
    }
  },
  watch: {
  },
  mounted () {
  },
  destroyed () {
  },
  methods: {
    postComment () {
      Emit(REMOVE_NOTIF, msg => msg.key === 'issue');

      API.addIssueComment(this.issueId, this.post)
        .then(res => {
          this.post = '';
          Emit(PUSH_NOTIF, {
            type: 'success',
            title: '投稿しました',
            detail: '',
            key: 'issue',
          });
          if (this.reload.apply) {
            this.reload();
          }
        })
        .catch(err => {
          console.log(err)
          Emit(PUSH_NOTIF, {
            type: 'error',
            title: '投稿に失敗しました',
            key: 'issue',
          });
        })
    },
    async switchClosed () {
      Emit(REMOVE_NOTIF, msg => msg.key === 'issue');
      try {
        var newState = !this.value.closed;
        await API.patchIssues(this.value.id, {
          closed: newState,
        });
        this.value.closed = newState;
      } catch (err) {
        console.log(err)
        Emit(PUSH_NOTIF, {
          type: 'error',
          title: 'ステータスの変更に失敗しました',
          key: 'issue',
        });
      }
    },
  },
}
</script>

