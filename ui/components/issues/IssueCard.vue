<template>
  <v-card :to="issueURL" height="5em">
    <v-row align="center" justify="start" class="ml-0 pr-2 full-height">
      <!-- 状態 -->
      <v-col class="pa-0 full-height status">
        <v-sheet :class="statusColor" class="full-height right-no-radius">
          <v-layout justify-center align-center fill-height>
            {{ issue.statusJp }}
          </v-layout>
        </v-sheet>
      </v-col>

      <!-- 問題名 チーム名 最終返答 -->
      <v-col class="pa-0 ml-2 mr-3 card-info">
        <div class="body-2 text-truncate">
          {{ issue.problem.displayTitle }}<br />

          <template v-if="isNotPlayer">
            {{ issue.team.displayName }}<br />
          </template>
          <template v-else>
            <div class="pt-2" />
          </template>

          最新返答 {{ issue.latestReplyAtDisplay }}
        </div>
      </v-col>

      <!-- 最近のコメント -->
      <v-row class="ml-0 mr-3">
        <v-col
          v-for="comment in recentlyComments"
          :key="comment.id"
          class="pa-0 ml-2"
        >
          <!-- 通常はただの文字列して表示し、ホバーでMarkdownツールチップ -->
          <v-tooltip
            open-delay="400"
            min-width="50%"
            max-width="50%"
            bottom
            content-class="pa-0 elevation-8 opacity-none"
          >
            <template v-slot:activator="{ on }">
              <v-card
                height="4em"
                width="10em"
                :color="comment.color"
                v-on="on"
              >
                <!-- 一覧ではただのテキストとして表示 -->
                <v-card-text class="caption py-0 truncate">
                  {{ comment.text }}
                </v-card-text>
              </v-card>
            </template>

            <!-- ツールチップではMarkdownとして表示 -->
            <markdown :content="comment.text" :color="comment.color" />
          </v-tooltip>
        </v-col>

        <!-- カードの枚数が足りない分の余白 -->
        <v-spacer />
      </v-row>

      <!-- ここでも必要 -->
      <v-spacer />
    </v-row>
  </v-card>
</template>
<script>
import Markdown from '~/components/commons/Markdown'

export default {
  name: 'IssueCard',
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
    issueURL() {
      const base = `/problems/${this.issue.problemId}#issues`

      if (this.isPlayer) {
        return base
      } else {
        return `${base}=${this.issue.teamId}`
      }
    }
  }
}
</script>
<style scoped lang="sass">
.full-height
  height: 100%

.opacity-none
  opacity: 1 !important

.truncate
  overflow: hidden
  display: -webkit-box
  -webkit-box-orient: vertical
  -webkit-line-clamp: 3

.status
  max-width: 4.2em
  min-width: 4.2em

.right-no-radius
  border-top-right-radius: 0
  border-bottom-right-radius: 0

.card-info
  max-width: 10em
  min-width: 10em
</style>
