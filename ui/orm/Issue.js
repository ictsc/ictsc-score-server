import orm from '~/orm'
import BaseModel from '~/orm/BaseModel'

export default class Issue extends BaseModel {
  static entity = 'issues'

  static fields() {
    return {
      id: this.string(),
      status: this.string(),
      comments: this.hasMany(orm.IssueComment, 'issueId'),
      problemId: this.string(),
      problem: this.belongsTo(orm.Problem, 'problemId'),
      teamId: this.string(),
      team: this.belongsTo(orm.Team, 'teamId'),
      updatedAt: this.string()
    }
  }
}
