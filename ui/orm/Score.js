import { Model } from '@vuex-orm/core'

export default class Score extends Model {
  static entity = 'scores'

  static fields() {
    return {
      id: this.string(),
      point: this.number(),
      answerId: this.string(),
      solved: this.boolean()
    }
  }
}
