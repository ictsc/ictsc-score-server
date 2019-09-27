<template>
  <v-layout row align-end :reverse="comment.isOurComment">
    <v-flex xs10 d-flex child-flex>
      <v-card>
        <markdown :content="comment.text" :color="comment.color" />
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
import Markdown from '~/components/commons/Markdown'
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
  }
}
</script>
