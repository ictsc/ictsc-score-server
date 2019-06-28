<template>
  <div class="alert alert-warning" role="alert">
    <h4 class="alert-heading">
      問題解答の注意点
    </h4>
    <ul>
      <li>
        採点結果は、採点依頼を送信してから{{
          gradingDelayMinString
        }}後に返ってきます。
      </li>
      <li>採点中はその問題へ新たに解答することはできません。</li>
    </ul>
  </div>
</template>

<script>
import { mapGetters } from 'vuex'

export default {
  name: 'AnswerAttention',
  computed: {
    ...mapGetters('contest', ['gradingDelayMinString']),

    aboutGradingDelayTitle: function() {
      return `運営が採点 (最速${this.gradingDelayMinString})`
    }
  }
}
</script>
