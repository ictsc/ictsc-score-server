<template>
  <!-- TODO: コメントがない場合のempty state -->
  <div>
    <!-- ステータスボタン -->
    <v-layout v-if="!!issue" column align-center class="pb-1">
      <v-btn
        :disabled="isAudience"
        :loading="statusUpdating || commentSending"
        :color="issue.statusColor"
        min-width="5em"
        min-height="5em"
        fab
        @click="transition"
      >
        {{ issue.statusJp }}
      </v-btn>

      <span v-if="!isAudience" class="caption grey--text text--darken-1 pt-1">
        {{ statusDescription }}
      </span>
    </v-layout>

    <!-- コメント一覧 -->
    <div v-if="comments.length !== 0" class="mb-2">
      <!-- TODO: 出現アニメーションが欲しい -->
      <issue-comment-card
        v-for="comment in comments"
        :key="comment.id"
        :comment="comment"
        class=" mt-1"
      />
    </div>

    <!-- コメントフォーム -->
    <template v-if="showCommentForm">
      <v-card>
        <v-card-text class="py-1">
          <v-form v-model="valid">
            <markdown-text-area
              v-model="text"
              :readonly="commentSending"
              :placeholder="placeholder"
              preview-width="70em"
              hide-details
              @submit="sendComment"
            />
          </v-form>
        </v-card-text>
      </v-card>

      <v-btn
        :disabled="isAudience || !valid"
        :loading="commentSending"
        block
        color="success"
        class="mt-1"
        @click="sendComment"
      >
        送信
      </v-btn>
    </template>
  </div>
</template>
<script>
import orm from '~/orm'
import MarkdownTextArea from '~/components/commons/MarkdownTextArea'
import IssueCommentCard from '~/components/problems/id/IssueCommentCard'

export default {
  name: 'IssuePanel',
  components: {
    MarkdownTextArea,
    IssueCommentCard
  },
  props: {
    problem: {
      type: Object,
      required: true
    },
    teamId: {
      type: String,
      required: true
    }
  },
  data() {
    const storageKey = `issueComment-${this.problem.id}`

    return {
      commentSending: false,
      statusUpdating: false,
      text: this.$jsonStorage.get(storageKey),
      storageKey,
      placeholder:
        'Markdownで記述できます\n\n送信前の自動プレビューはありません\n\nCtrl-Enterでも送信可能です',
      valid: false
    }
  },
  computed: {
    showCommentForm() {
      // 質問を初められる(issueを作れる)のはplayerのみ
      return this.isPlayer || (this.isStaff && !!this.issue)
    },
    statusDescription() {
      if (!this.issue) {
        return ''
      }

      const solvedText = '解決したらクリック'

      switch (this.issue.status) {
        case 'unsolved':
          return this.isPlayer ? solvedText : '対応を開始したらクリック'
        case 'in_progress':
          return solvedText
        case 'solved':
          return this.isPlayer
            ? '新たに質問があるならクリック'
            : '未解決ならクリック'
        default:
          throw new Error(`unsupported status ${this.issue.status}`)
      }
    },
    issue() {
      // 各チームは各問題に対して1つのissueを持つことができる
      if (this.isPlayer) {
        return this.problem.issues[0]
      } else {
        return this.problem.issues.find(issue => issue.teamId === this.teamId)
      }
    },
    comments() {
      if (!this.issue) {
        return []
      }

      return this.sortByCreatedAt(this.issue.comments)
    }
  },
  watch: {
    text(value) {
      this.$jsonStorage.set(this.storageKey, value)
    }
  },
  methods: {
    async sendComment() {
      this.commentSending = true
      const action = '質問投稿'
      const resolve = () => (this.text = '')

      if (this.issue) {
        await orm.IssueComment.addIssueComment({
          action,
          resolve,
          params: { issueId: this.issue.id, text: this.text }
        })
      } else {
        // playerが質問する際、issueが無ければstartIssueでissueを作る
        await orm.Issue.startIssue({
          action,
          resolve,
          params: { problemId: this.problem.id, text: this.text }
        })
      }

      this.commentSending = false
    },
    async transition() {
      this.statusUpdating = true

      await orm.Issue.transitionIssueState({
        action: '状態遷移',
        params: { issueId: this.issue.id, currentStatus: this.issue.status }
      })

      this.statusUpdating = false
    }
  }
}
</script>
