<template>
  <div class="steps d-flex">
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

<style scoped>
.steps {
  margin: 2rem 0;
}
.steps .item {
  flex-grow: 1;
  min-width: 5rem;
  padding: 1rem;
  padding-right: 4rem;
  background: #efefef;
  position: relative;
  background-image: url('~assets/arrow.svg');
  background-repeat: repeat-y;
  background-position: right center;
}
.steps .item:last-child {
  background-image: none;
  padding-right: 1rem;
}
.steps .item p {
  margin: 0;
}
</style>
