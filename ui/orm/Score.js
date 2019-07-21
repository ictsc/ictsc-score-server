import BaseModel from '~/orm/BaseModel'

export default class Score extends BaseModel {
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
