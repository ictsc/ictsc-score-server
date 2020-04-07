import BaseModel from '~/orm/BaseModel'

export default class IssueComment extends BaseModel {
  static entity = 'issueComments'

  static fields() {
    return {
      id: this.string(),
      fromStaff: this.boolean(),
      text: this.string().nullable(),
      issueId: this.string(),
      createdAt: this.string(),
    }
  }

  get isOurComment() {
    if ($nuxt.isPlayer) {
      return !this.fromStaff
    } else {
      return this.fromStaff
    }
  }

  get color() {
    return this.isOurComment ? 'grey lighten-2' : 'white'
  }
}
