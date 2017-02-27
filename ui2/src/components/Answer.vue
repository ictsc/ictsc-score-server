<template>
  <div>
    {{ value }}
    <div class="answers">
      <div v-if="value.comments" v-for="answer in value.comments" class="answer">
        <markdown :value="answer.text"></markdown>
        <div class="meta">
          <small>{{ answer.created_at }}</small>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
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
      // Emit(REMOVE_NOTIF, msg => msg.key === 'issue');

      // API.addIssueComment(this.issueId, this.post)
      //   .then(res => {
      //     this.post = '';
      //     Emit(PUSH_NOTIF, {
      //       type: 'success',
      //       icon: 'check',
      //       title: '投稿しました',
      //       detail: '',
      //       key: 'issue',
      //       autoClose: true,
      //     });
      //     if (this.reload.apply) {
      //       this.reload();
      //     }
      //   })
      //   .catch(err => {
      //     console.log(err)
      //     Emit(PUSH_NOTIF, {
      //       type: 'error',
      //       icon: 'warning',
      //       title: '投稿に失敗しました',
      //       key: 'issue',
      //       autoClose: false,
      //     });
      //   })
    },
  },
}
</script>

