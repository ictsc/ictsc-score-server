<template>
  <v-sheet class="warning pa-2">
    <div>
      問題解答の注意点
    </div>
    <ul>
      <li>
        採点結果は、採点依頼を送信してから{{
          gradingDelayString
        }}後に返ってきます。
      </li>
      <li>採点中はその問題へ新たに解答することはできません。</li>
    </ul>
  </v-sheet>
</template>

<script>
import { mapGetters } from 'vuex'

export default {
  name: 'AnswerAttention',
  computed: {
    ...mapGetters('contestInfo', ['gradingDelayString']),

    aboutGradingDelayTitle() {
      return `運営が採点 (最速${this.gradingDelayString})`
    }
  }
}
</script>
