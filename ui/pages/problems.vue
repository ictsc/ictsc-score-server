<template>
  <div>
    <h1>問題一覧</h1>
    <div class="description">
      <answer-flow />
      <answer-attention />
    </div>

    <ul>
      <li v-for="category in categories" :key="category.id">
        {{ category.title }}
      </li>
    </ul>
  </div>
</template>

<style scoped></style>

<script>
import { mapGetters } from 'vuex'

import AnswerAttention from '~/components/molecules/AnswerAttention'
import AnswerFlow from '~/components/molecules/AnswerFlow'
import orm from '~/orm'

export default {
  name: 'Problems',
  components: {
    AnswerAttention,
    AnswerFlow
  },

  filters: {
    // dateRelative
  },

  computed: {
    ...mapGetters('session', [
      'isStaff',
      'isAudience',
      'isPlayer',
      'isNoLogin'
    ]),

    categories() {
      return this.$_.sortBy(orm.Category.all(), 'order')
    }
  },

  async fetch({ store }) {
    await orm.Category.fetch()
  }

  // mounted() {
  //   this.$store.dispatch(SET_TITLE, '問題一覧')
  // },

  // methods: {
  //   scoringStatusText(problem) {
  //     if (problem.title === undefined) {
  //       return '解答不可'
  //     }
  //
  //     let answers = problem.answers
  //     if (!answers || answers.length === 0) {
  //       return '解答可能'
  //     } else {
  //       var createdAt = answers[answers.length - 1].created_at
  //       var publishAt =
  //         new Date(createdAt).valueOf() +
  //         (this.contest ? this.contest.answer_reply_delay_sec * 1000 : 0)
  //
  //       if (publishAt < new Date()) {
  //         return '解答可能'
  //       } else {
  //         return `${dateRelative(publishAt)}に解答送信可`
  //       }
  //     }
  //   },
  //   getScoreInfo(answers) {
  //     let nothing = {
  //       pure: 0,
  //       bonus: 0,
  //       subtotal: 0
  //     }
  //     if (!this.session.member || !answers) return nothing
  //     if (answers.length === 0) {
  //       return {
  //         pure: '---'
  //       }
  //     }
  //
  //     if (
  //       this.contest &&
  //       new Date(this.contest.competition_end_at) < Date.now()
  //     )
  //       return nothing
  //
  //     const answer = latestAnswer(answers)
  //     const pure = nestedValue(answer, 'score', 'point')
  //
  //     return {
  //       pure: pure != undefined ? pure : '採点中'
  //     }
  //   },
  //   problemUnlockConditionTitle(id) {
  //     var found = this.problems.find(p => p.id === id)
  //     if (found) {
  //       let prev = found.title ? `「${found.title}」` : '前の問題'
  //       let cond = found.team_private ? '' : 'チームが現れる'
  //       return `${prev}で基準を満たす${cond}こと`
  //     } else {
  //       return '前の問題'
  //     }
  //   },
  //   problemSolved(answers) {
  //     return nestedValue(latestAnswer(answers), 'score', 'solved') || false
  //   }
  // }
}
</script>
