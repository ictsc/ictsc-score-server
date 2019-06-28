import { Model } from '@vuex-orm/core'
import orm from '~/orm'

export default class ProblemEnvironment extends Model {
  static entity = 'problemEnvironments'

  static fields() {
    return {
      id: this.string(),
      teamId: this.string(),
      team: this.belongsTo(orm.Team, 'teamId'),
      problemId: this.string(),
      problem: this.belongsTo(orm.Problem, 'problemId'),
      status: this.string(),
      host: this.string(),
      user: this.string(),
      password: this.string(),
      createdAt: this.string(),
      updatedAt: this.string()
    }
  }
}
