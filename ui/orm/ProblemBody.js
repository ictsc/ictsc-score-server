import { Model } from '@vuex-orm/core'
import orm from '~/orm'

export default class ProblemBody extends Model {
  static entity = 'problemBodies'

  static fields() {
    return {
      id: this.string(),
      // problemId: this.belongsTo(orm.Problem, 'problemId')
    }
  }
}
