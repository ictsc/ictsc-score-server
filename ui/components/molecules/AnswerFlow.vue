<template>
  <div class>
    <Item
      title="各カテゴリから問題を選んで解答"
      body="解放されている問題を選択し、解答を行ってください。"
    />
    <Item
      :title="aboutGradingDelayTitle"
      body="運営が採点中はその問題を解けません。"
    />
    <Item
      title="採点結果を確認"
      body="満点でない場合は、高得点を目指して追加の解答も可能です。"
    />
  </div>
</template>

<script>
import { mapGetters } from 'vuex'
import Item from '~/components/atoms/AnswerFlowItem'

export default {
  name: 'AnsewerFlow',
  components: {
    Item
  },
  computed: {
    ...mapGetters('contest', ['gradingDelayMinString']),

    aboutGradingDelayTitle: function() {
      return `運営が採点 (最速${this.gradingDelayMinString})`
    }
  }
}
</script>

<style scoped lang="sass"></style>
