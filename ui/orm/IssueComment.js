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

  static addIssueComment({ action, resolve, params: { issueId, text } }) {
    return this.sendMutation({
      action,
      resolve,
      mutation: 'addIssueComment',
      params: { issueId, text },
      fields: [orm.Issue, IssueComment],
      type: 'upsert'
    })
  }

  get isOurComment() {
    return (
      // eslint-disable-next-line no-undef
      (!this.fromStaff && $nuxt.isPlayer) || (this.fromStaff && !$nuxt.isPlayer)
    )
  }
}
