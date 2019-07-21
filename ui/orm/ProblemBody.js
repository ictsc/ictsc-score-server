import orm from '~/orm'
import BaseModel from '~/orm/BaseModel'

export default class ProblemBody extends BaseModel {
  static entity = 'problemBodies'

  static fields() {
    return {
      id: this.string(),
      mode: this.string(),
      title: this.string(),
      text: this.string(),
      perfectPoint: this.number(),
      solvedCriterion: this.number(),
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
