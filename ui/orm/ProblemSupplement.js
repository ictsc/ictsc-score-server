import BaseModel from '~/orm/BaseModel'

export default class ProblemSupplement extends BaseModel {
  static entity = 'problemSupplements'

  static fields() {
    return {
      id: this.string(),
      text: this.string(),
      problemId: this.string(),
      createdAt: this.string()
    }
  }
}
