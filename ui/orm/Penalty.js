import orm from '~/orm'
import BaseModel from '~/orm/BaseModel'

export default class Penalty extends BaseModel {
  static entity = 'penalties'

  static fields() {
    return {
      id: this.string(),
      problemId: this.string(),
      problem: this.belongsTo(orm.Problem, 'problemId'),
      teamId: this.string(),
      team: this.belongsTo(orm.Team, 'teamId'),
      createdAt: this.string(),
      updatedAt: this.string()
    }
  }

  get delayFinishInSec() {
    // この書き方でもリアクティブになる
    const now = this.$store().getters['time/currentTimeMsec']
    const delay = this.$store().getters['contestInfo/resetDelaySec'] * 1000
    return Math.floor((Date.parse(this.createdAt) + delay - now) / 1000)
  }

  get delayTickDuration() {
    return $nuxt.tickDuration(this.delayFinishInSec)
  }
}
