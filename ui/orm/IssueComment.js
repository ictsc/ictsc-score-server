import orm from '~/orm'
import BaseModel from '~/orm/BaseModel'

export default class IssueComment extends BaseModel {
  static entity = 'issueComments'

  static fields() {
    return {
      id: this.string(),
      fromStaff: this.boolean(),
      text: this.string().nullable(),
      issueId: this.string(),
      issue: this.belongsTo(orm.Issue, 'issueId'),
      createdAt: this.string()
    }
  }

  get isOurComment() {
    return (
      // eslint-disable-next-line no-undef
      (!this.fromStaff && $nuxt.isPlayer) || (this.fromStaff && !$nuxt.isPlayer)
    )
  }

  get color() {
    return this.isOurComment ? 'grey lighten-2' : 'white'
  }
}
