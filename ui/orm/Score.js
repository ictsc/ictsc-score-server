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

  static applyScore({ action, resolve, params: { answerId, point } }) {
    return this.sendMutation({
      action,
      resolve,
      mutation: 'applyScore',
      params: { answerId, point },
      fields: [Score],
      type: 'upsert'
    })
  }
}
