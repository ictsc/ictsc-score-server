<template>
  <!-- TODO: コメントがない場合のempty state -->
  <v-layout column>
    <!-- ステータスボタン -->
    <v-flex v-if="!!issue" class="pb-1">
      <v-layout column align-center>
        <v-flex>
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
        </v-flex>
        <v-flex v-if="!isAudience" class="pt-0 pl-2">
          <span class="caption grey--text text--darken-1">
            {{ statusDescription }}
          </span>
        </v-flex>
      </v-layout>
    </v-flex>

    <!-- コメント一覧 -->
    <v-flex>
      <!-- TODO: 出現アニメーションが欲しい -->
      <v-layout column>
        <v-flex v-for="comment in comments" :key="comment.id" mt-1>
          <issue-comment-card :comment="comment" />
        </v-flex>
      </v-layout>
    </v-flex>

    <!-- コメントフォーム -->
    <template v-if="showCommentForm">
      <v-flex mt-1>
        <v-card>
          <v-card-text class="pt-1 pb-0">
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
      </v-flex>
      <v-flex>
        <v-btn
          :disabled="isAudience || !valid"
          :loading="commentSending"
          block
          color="success"
          @click="sendComment"
        >
          送信
        </v-btn>
      </v-flex>
    </template>
  </v-layout>
</template>
<script>
import orm from '~/orm'
import MarkdownTextArea from '~/components/molecules/MarkdownTextArea'
import IssueCommentCard from '~/components/molecules/IssueCommentCard'

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
