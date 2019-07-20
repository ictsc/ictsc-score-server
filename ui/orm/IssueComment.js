import { Model } from '@vuex-orm/core'
import orm from '~/orm'

export default class IssueComment extends Model {
  static entity = 'issueComments'

  static fields() {
    return {
      id: this.string(),
      from_staff: this.boolean(),
      text: this.string().nullable(),
      issueId: this.string(),
      issue: this.belongsTo(orm.Issue, 'issueId'),
      createdAt: this.string()
    }
  }
}
