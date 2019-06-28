import { Model } from '@vuex-orm/core'
import orm from '~/orm'

export default class ProblemBody extends Model {
  static entity = 'problemBodies'

  static fields() {
    return {
      id: this.string(),
      mode: this.string(),
      title: this.string(),
      text: this.string(),
      perfectPoint: this.number(),
      problemId: this.string(),
      problem: this.belongsTo(orm.Problem, 'problemId'),
      // 本当は[[this.string()]].nullable()
      candidates: this.string().nullable(),
      corrects: this.string().nullable(),
      createdAt: this.string(),
      updatedAt: this.string()
    }
  }
}
