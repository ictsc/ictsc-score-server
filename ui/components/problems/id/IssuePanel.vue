<template>
  <div>
    <!-- ステータスボタン -->
    <v-row v-if="!!issue" justify="center">
      <v-col cols="auto" align="center" class="pt-0">
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

        <div
          v-if="isNotAudience"
          class="caption grey--text text--darken-1 pt-1"
        >
          {{ statusDescription }}
        </div>
      </v-col>
    </v-row>

    <!-- コメント一覧 -->
    <div v-if="comments.length !== 0" class="mb-2">
      <!-- TODO: 出現アニメーションが欲しい -->
      <issue-comment-card
        v-for="comment in comments"
        :key="comment.id"
        :comment="comment"
        class="mt-1"
      />
    </div>

    <v-card v-if="isStaff && team.beginner" color="pink lighten-3">
      <div class="text-center">
        解答サポート対象チームです
        <v-icon>mdi-face-agent</v-icon>
      </div>
    </v-card>

    <!-- コメントフォーム -->
    <template v-if="showCommentForm">
      <v-card>
        <v-card-text class="py-0">
          <v-form v-model="valid">
            <markdown-text-area
              v-model="text"
              :readonly="commentSending"
              :placeholder="placeholder"
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
        :color="submitButtonColor"
        class="mt-1"
        @click="sendComment"
      >
        送信
        <v-icon v-if="isStaff && team.beginner">mdi-face-agent</v-icon>
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
    IssueCommentCard,
  },
  props: {
    problem: {
      type: Object,
      required: true,
    },
    teamId: {
      type: String,
      required: true,
    },
  },
  data() {
    const storageKey = `issueComment-${this.problem.id}`

    return {
      commentSending: false,
      statusUpdating: false,
      text: this.$jsonStorage.get(storageKey),
      storageKey,
      placeholder: 'Ctrl-Enterで送信可能です',
      valid: false,
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
        return this.problem.issues.find((issue) => issue.teamId === this.teamId)
      }
    },
    comments() {
      if (!this.issue) {
        return []
      }

      return this.sortByCreatedAt(this.issue.comments)
    },
    team() {
      return orm.Team.find(this.teamId)
    },
    submitButtonColor() {
      return this.isStaff && this.team.beginner ? 'pink lighten-3' : 'success'
    },
  },
  watch: {
    text(value) {
      this.$jsonStorage.set(this.storageKey, value)
    },
  },
  methods: {
    async sendComment() {
      this.commentSending = true
      const action = '質問投稿'
      const resolve = () => (this.text = '')

      if (this.issue) {
        await orm.Mutations.addIssueComment({
          action,
          resolve,
          params: { issueId: this.issue.id, text: this.text },
        })
      } else {
        // playerが質問する際、issueが無ければstartIssueでissueを作る
        await orm.Mutations.startIssue({
          action,
          resolve,
          params: { problemId: this.problem.id, text: this.text },
        })
      }

      this.commentSending = false
    },
    async transition() {
      this.statusUpdating = true

      await orm.Mutations.transitionIssueState({
        action: '状態遷移',
        params: { issueId: this.issue.id, currentStatus: this.issue.status },
      })

      this.statusUpdating = false
    },
  },
}
</script>
