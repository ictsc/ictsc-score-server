import { Model } from '@vuex-orm/core'
import orm from '~/orm'

export default class Issue extends Model {
  static entity = 'issues'
  static eagerLoad = ['comments']

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
