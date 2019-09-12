<template>
  <v-container>
    <v-layout row justify-center class="grey lighten-3">
      <v-flex xs3>
        <answer-flow-item
          title="問題を選んで解答"
          body="解放されている問題を選択し、解答を行ってください。"
        />
      </v-flex>
      <v-flex shrink class="arrow" />
      <v-flex xs3>
        <answer-flow-item
          :title="`運営が採点 (最速${gradingDelayString})`"
          :body="`解答後${gradingDelayString}間は再解答できません。`"
        />
      </v-flex>
      <v-flex shrink class="arrow" />
      <v-flex xs3>
        <answer-flow-item
          title="採点結果を確認"
          body="高得点を目指して追加の解答も可能です。"
        />
      </v-flex>
    </v-layout>
  </v-container>
</template>

<script>
import { mapGetters } from 'vuex'
import AnswerFlowItem from '~/components/atoms/AnswerFlowItem'

export default {
  name: 'AnsewerFlow',
  components: {
    AnswerFlowItem
  },
  computed: {
    ...mapGetters('contestInfo', ['gradingDelayString'])
  }
}
</script>

<style scoped lang="sass">
.arrow
  min-width: 4rem
  background-image: url('~assets/img/arrow.svg')
</style>
