<template>
  <!-- TODO: 幅が足りないと崩れる -->
  <v-layout row>
    <answer-flow-item
      title="各カテゴリから問題を選んで解答"
      body="解放されている問題を選択し、解答を行ってください。"
    />
    <answer-flow-item
      :title="aboutGradingDelayTitle"
      body="運営が採点中はその問題を解けません。"
    />
    <answer-flow-item
      title="採点結果を確認"
      body="満点でない場合は、高得点を目指して追加の解答も可能です。"
    />
  </v-layout>
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
    ...mapGetters('contestInfo', ['gradingDelayString']),

    aboutGradingDelayTitle() {
      return `運営が採点 (最速${this.gradingDelayString})`
    }
  }
}
</script>

<style scoped lang="sass"></style>
