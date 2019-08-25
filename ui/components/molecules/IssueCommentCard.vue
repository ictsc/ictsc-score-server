<template>
  <v-layout row align-end :reverse="isOurComment">
    <v-flex xs10 d-flex child-flex>
      <v-card>
        <markdown
          :content="comment.text"
          :color="isOurComment ? 'white' : 'grey lighten-2'"
        />
      </v-card>
    </v-flex>

    <v-flex shrink pa-0 d-flex child-flex>
      <span class="caption">
        {{ comment.createdAtHM }}
      </span>
    </v-flex>
    <v-spacer />
  </v-layout>
</template>
<script>
import Markdown from '~/components/atoms/Markdown'
export default {
  name: 'IssueCommentCard',
  components: {
    Markdown
  },
  props: {
    comment: {
      type: Object,
      required: true
    }
  },
  computed: {
    isOurComment() {
      return this.comment.isOurComment(this.isPlayer)
    }
  }
}
</script>
