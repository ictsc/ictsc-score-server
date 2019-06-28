<template>
  <div>
    <h1>問題一覧</h1>
    <div class="description">
      <answer-flow />
      <answer-attention />
    </div>
  </div>
</template>

<style scoped>
.fixed-tool-tips {
  position: fixed;
  top: 5rem;
  right: 3rem;
  z-index: 1;
}
.fixed-tool-tips > * {
  cursor: pointer;
  padding: 1rem;
  background: #888;
  color: white;
  line-height: 1;
  border-radius: 2rem;
  font-size: 1.2rem;
  margin-bottom: 5px;
}

.add > .fa {
  padding-right: 5px;
}

.groups {
  min-height: 15rem;
}
.group {
  border-top: 1px solid #ccc;
  padding: 2rem;
}
.group h2 {
  display: inline-block;
  color: #fdbbcc;
  font-size: 2.5rem;
}
.group .flag {
  height: 38px;
  margin-right: 0.2em;
  vertical-align: top;
}
.group .problem-numbers {
  display: inline-block;
  font-size: 1.5rem;
}
.group .detail {
  width: 100%;
}

.problems {
  align-items: center;
  margin-top: 1em;
  overflow-x: auto;
}

.problem .background {
  z-index: -998;
  position: absolute;
  width: 100%;
  height: 100%;
  border: 4px solid white;
}

.problem .background-triangle {
  z-index: -999;
  position: absolute;
  /*width: calc(100% - 10px);*/
  /*margin: 10% 5px 0;*/
  /*height: 20%;*/
  /*background: #E7EFF1;*/

  content: '';
  width: 0;
  height: 0;
  margin: 0 0 0 -63px;
  border-style: solid;
  border-width: 80px 230px 0;
  border-color: #e7eff1 transparent transparent transparent;
}

.problem .background-sealing-icon {
  z-index: -997;
  position: absolute;
  margin: 50px calc(50% - 24px) 0;
}

.problem .background-sealing-icon img {
  width: 48px;
  height: 48px;
}

.problem {
  border: 1px solid #d9d9d9;
  overflow: hidden;
  flex-wrap: nowrap;
  position: relative;
  display: block;
  color: inherit;
  text-decoration: none;

  min-height: 13em;
  max-height: 13em;
  min-width: 23em;
  max-width: 23em;

  flex: 1;
}

.problem h3 {
  margin: 14px;
  overflow-wrap: break-word;
  font-size: 1.3em;
}

.problems .problem + .arrow-next-problem {
  content: '';
  width: 0;
  height: 0;
  margin: 0 7px 0 9px;
  border-style: solid;
  border-width: 14px 0 14px 15px;
  border-color: transparent transparent transparent #e0e0e0;
}

.problem .bottom-wrapper {
  margin: 10px;
}

.problem .scores-wrapper {
  min-width: 10em;
  text-align: right;
}

.problem .scores {
  font-size: 0.96em;
}

.problem .scores .current {
  font-size: 1.15em;
  font-weight: bold;
  margin-bottom: 0;
  color: #e6003b;
}

.problem .scores .perfect_point {
  font-size: 1.06em;
}

.problem .scores .current .subtotal {
  font-size: 1.8em;
}

.problem .scores .brakedown,
.problem .scores .point {
  color: #dddddd;
}

.problem .scores .border {
  border-top: 1px solid #dddddd;
}

.problem .scores .brakedown {
  float: left;
}

.problem .tips {
  float: right;
  font-size: 1.1em;
  text-align: right;
  width: calc(50% - 10px);
}

.problem .overlay {
  position: absolute;
  background: rgba(19, 37, 48, 0.7);
  top: 0;
  bottom: 0;
  left: 0;
  right: 0;
  display: flex;
}
.problem .overlay .overlay-message {
  color: white;
  font-size: 1.2em;
  line-height: 1.5;
  font-weight: bold;
  flex-grow: 1;
  text-align: center;
  margin: auto 1em;
}

.problem .solved {
  position: absolute;
  background: rgba(0, 255, 0, 0.2);
  top: 0;
  bottom: 0;
  left: 0;
  right: 0;
  display: flex;
}

.description {
  margin-bottom: 2rem;
}
</style>

<script>
// import { SET_TITLE } from '../store/'
// import { API } from '../utils/Api'
// import { mapGetters } from 'vuex'
// import { dateRelative, latestAnswer } from '../utils/Filters'
// import { nestedValue } from '../utils/Utils'

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
    // sortedProblems() {
    //   return _.sortBy(this.problems, 'order')
    // },
    // sortedProblemGroups() {
    //   return _.sortBy(this.problemGroups, 'order')
    // },
    // problemSelect() {
    //   return [
    //     {
    //       id: null,
    //       title: 'Null'
    //     }
    //   ].concat(this.problems)
    // },
    // ...mapGetters([
    //   'contest',
    //   'isAdmin',
    //   'isStaff',
    //   'isParticipant',
    //   'isWriter',
    //   'session'
    // ]),
    // memberSelect() {
    //   return [
    //     {
    //       id: null,
    //       name: 'Null',
    //       role_id: null
    //     }
    //   ].concat(this.members)
    // }
  },
  watch: {
    // problemGroups(val) {
    //   try {
    //     this.newProblemObj.problem_group_id = val[0].id
    //   } catch (e) {
    //     console.error(e)
    //   }
    // },
    // session(val) {
    //   if (val.member) this.asyncReload('problems')
    // }
  },
  asyncData: {
    // problemGroupsDefault: [],
    //
    // problemGroups() {
    //   return API.getProblemGroups()
    // },
    // problemsDefault: [],
    // problems() {
    //   if (this.session.member) {
    //     if (this.isParticipant || this.isStaff) {
    //       return API.getProblemsWithScore()
    //     } else {
    //       return API.getProblems()
    //     }
    //   } else {
    //     return new Promise(resolve => resolve([]))
    //   }
    // },
    // membersDefault: [],
    // members() {
    //   return API.getMembers()
    // }
  },
  async fetch({ store }) {
    const { data } = await orm.Category.fetch()
    // const data = Comment.query().withAll().all()
    console.log(data)
    // store.commit('setStars', data)
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
