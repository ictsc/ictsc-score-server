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

  static applyScore({ answerId, point }) {
    return this.sendMutation(
      'applyScore',
      { answerId, point },
      [Score],
      'upsert'
    )
  }
}
