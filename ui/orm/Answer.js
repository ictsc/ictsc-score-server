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
      score: this.hasOne(orm.Score, 'answerId'),
      createdAt: this.string()
    }
  }

  static addAnswer({ problemId, bodies }) {
    return this.sendMutation(
      'addAnswer',
      { problemId, bodies },
      [Answer],
      'upsert'
    )
  }

}
