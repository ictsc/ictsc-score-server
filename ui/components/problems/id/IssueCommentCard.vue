<template>
  <v-row align="end" class="pt-0 pb-2">
    <v-col v-if="comment.isOurComment" cols="2" align="end" class="pa-0">
      <div class="caption">{{ comment.createdAtHM }}</div>
    </v-col>

    <v-col cols="10" class="px-2 py-0">
      <v-card>
        <markdown :content="comment.text" :color="comment.color" />
      </v-card>
    </v-col>

    <v-col v-if="!comment.isOurComment" class="pa-0">
      <div class="caption">{{ comment.createdAtHM }}</div>
    </v-col>
  </v-row>
</template>
<script>
import Markdown from '~/components/commons/Markdown'
export default {
  name: 'IssueCommentCard',
  components: {
    Markdown,
  },
  props: {
    comment: {
      type: Object,
      required: true,
    },
  },
}
</script>
