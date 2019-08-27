<template>
  <v-sheet class="warning lighten-2 pa-2">
    <span class="subtitle-1">
      解答時の注意点
    </span>
    <ul>
      <template v-if="realtimeGrading">
        <li>
          採点結果は解答を提出してから{{ gradingDelayString }}後に返ってきます。
        </li>
        <li>{{ gradingDelayString }}間はその問題へ再解答できません。</li>
      </template>
      <template v-else>
        <li>採点は競技終了後に行われます。</li>
        <li>採点されるのは最後に提出した解答のみです。</li>
        <li>競技中は何度でも再解答可能です。</li>
      </template>
    </ul>
  </v-sheet>
</template>

<script>
import { mapGetters } from 'vuex'

export default {
  name: 'AnswerAttention',
  computed: {
    ...mapGetters('contestInfo', ['gradingDelayString', 'realtimeGrading']),

    aboutGradingDelayTitle() {
      return `運営が採点 (最速${this.gradingDelayString})`
    }
  }
}
</script>
