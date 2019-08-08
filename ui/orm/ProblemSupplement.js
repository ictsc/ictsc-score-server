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

  static addProblemSupplement({
    action,
    resolve,
    params: { problemCode, text }
  }) {
    return this.sendMutation({
      action,
      resolve,
      mutation: 'addProblemSupplement',
      params: { problemCode, text },
      fields: [ProblemSupplement],
      type: 'upsert'
    })
  }
}
