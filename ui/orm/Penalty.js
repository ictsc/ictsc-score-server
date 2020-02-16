import orm from '~/orm'
import BaseModel from '~/orm/BaseModel'

export default class Penalty extends BaseModel {
  static entity = 'penalties'
  static primaryKey = ['problemId', 'teamId']

  static fields() {
    return {
      id: this.string(),
      problemId: this.string(),
      problem: this.belongsTo(orm.Problem, 'problemId'),
      teamId: this.string(),
      team: this.belongsTo(orm.Team, 'teamId'),
      count: this.number(),
      createdAt: this.string(),
      updatedAt: this.string()
    }
  }
}
