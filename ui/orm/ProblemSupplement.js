import { Model } from '@vuex-orm/core'

export default class ProblemSupplement extends Model {
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
