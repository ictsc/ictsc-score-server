import orm from '~/orm'
import BaseModel from '~/orm/BaseModel'

export default class Answer extends BaseModel {
  static entity = 'answers'

  static fields() {
    return {
      id: this.string(),
      // 本当は [[this.string()]]
      bodies: this.attr(),
      confirming: this.boolean().nullable(),
      problemId: this.string(),
      problem: this.belongsTo(orm.Problem, 'problemId'),
      teamId: this.string(),
      team: this.belongsTo(orm.Team, 'teamId'),
      point: this.number().nullable(),
      percent: this.number().nullable(),
      createdAt: this.string()
    }
  }

  // この書き方でもリアクティブになる
  get delayFinishInSec() {
    const now = this.$store().getters['time/currentTimeMsec']
    const delay = this.$store().getters['contestInfo/gradingDelaySec'] * 1000
    return Math.floor((Date.parse(this.createdAt) + delay - now) / 1000)
  }

  get delayFinishInString() {
    if (this.delayFinishInSec >= 60) {
      return `${Math.floor(this.delayFinishInSec / 60)}分`
    } else {
      return `${this.delayFinishInSec}秒`
    }
  }

  // scoreが無い or score.pointがnullなら採点中
  get hasPoint() {
    return this.percent !== null && this.percent !== undefined
  }
}
