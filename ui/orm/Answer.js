import { Model } from '@vuex-orm/core'
import orm from '~/orm'

export default class Answer extends Model {
  static entity = 'answers'

  static fields() {
    return {
      id: this.string(),
      // 本当は [[this.string()]]
      bodies: this.string(),
      confirming: this.boolean().nullable(),
      problemId: this.string(),
      problem: this.belongsTo(orm.Problem, 'problemId'),
      teamId: this.string(),
      team: this.belongsTo(orm.Team, 'teamId'),
      score: this.hasOne(orm.Score, 'answerId'),
      createdAt: this.string()
    }
  }
}
