<template>
  <v-card :to="issueURL" height="5em">
    <v-container fill-height py-0>
      <v-layout row align-center justify-start fill-height>
        <!-- 状態 -->
        <v-flex class="full-height" style="max-width: 4.4em">
          <v-layout
            column
            justify-center
            align-center
            class="full-height"
            :class="statusColor"
          >
            <v-flex shrink>
              {{ issue.statusJp }}
            </v-flex>
          </v-layout>
        </v-flex>

        <!-- 問題名 チーム名 最終返答 -->
        <v-flex ml-2>
          <v-layout column class="body-2 text-truncate">
            <span>{{ issue.problem.body.title }}</span>
            <span>{{ issue.team.displayName }}</span>
            <span> 最終返答: {{ latestReplyAt }} </span>
          </v-layout>
        </v-flex>

        <v-spacer />

        <!-- 最近のコメント -->
        <v-flex ml-1 shrink>
          <v-container py-0>
            <v-layout row align-center justify-end pr-2>
              <v-flex
                v-for="comment in recentlyComments"
                :key="comment.id"
                shrink
                ml-2
              >
                <!-- 通常はただの文字列して表示し、ホバーでMarkdownツールチップ -->
                <v-tooltip
                  open-delay="300"
                  min-width="50%"
                  max-width="50%"
                  bottom
                  content-class="pa-0 elevation-6"
                >
                  <template v-slot:activator="{ on }">
                    <v-card
                      height="4em"
                      width="10em"
                      :color="commentColor(comment)"
                      v-on="on"
                    >
                      <!-- ただのテキストとして表示 -->
                      <v-card-text class="caption py-0 truncate">
                        {{ comment.text }}
                      </v-card-text>
                    </v-card>
                  </template>

                  <!-- ツールチップではMarkdownとして表示 -->
                  <markdown :content="comment.text" />
                </v-tooltip>
              </v-flex>

              <!-- 足りない分を透明なカード埋めて左寄せ風にする -->
              <v-flex v-for="n in paddingCount" :key="n" shirnk ml-2>
                <v-card width="10em" color="transparent" elevation="0" />
              </v-flex>
            </v-layout>
          </v-container>
        </v-flex>
      </v-layout>
    </v-container>
  </v-card>
</template>
<script>
import Markdown from '~/components/atoms/Markdown'

export default {
  name: 'IssueListCard',
  components: {
    Markdown
  },
  props: {
    issue: {
      type: Object,
      required: true
    }
  },
  computed: {
    statusColor() {
      return this.issue.statusColor + ' white--text'
    },
    comments() {
      return this.sortByCreatedAt(this.issue.comments).reverse()
    },
    latestReplyAt() {
      const comment = this.comments.filter(c =>
        c.isOurComment(this.isPlayer)
      )[0]
      return comment ? comment.createdAtShort : 'なし'
    },
    displayCommentCount() {
      switch (this.$vuetify.breakpoint.name) {
        case 'xs':
          return 1
        case 'sm':
          return 2
        case 'md':
          return 3
        case 'lg':
          return 4
        case 'xl':
          return 4
        default:
          return 0
      }
    },
    recentlyComments() {
      return this.$_.first(this.comments, this.displayCommentCount)
    },
    paddingCount() {
      const diff = this.displayCommentCount - this.comments.length
      return diff < 0 ? 0 : diff
    },
    issueURL() {
      const base = `/problems/${this.issue.problemId}#issues`

      if (this.isPlayer) {
        return base
      } else {
        return `${base}=${this.issue.teamId}`
      }
    }
  },
  methods: {
    commentColor(comment) {
      return comment.isOurComment(this.isPlayer) ? 'white' : 'grey lighten-2'
    }
  }
}
</script>
<style scoped lang="sass">
.full-height
  height: 100%

.truncate
  overflow: hidden
  display: -webkit-box
  -webkit-box-orient: vertical
  -webkit-line-clamp: 3
  // overflow-wrap: break-word
</style>
