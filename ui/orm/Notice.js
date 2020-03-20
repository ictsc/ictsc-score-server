import orm from '~/orm'
import BaseModel from '~/orm/BaseModel'

export default class Notice extends BaseModel {
  static entity = 'notices'

  static fields() {
    return {
      id: this.string(),
      title: this.string(),
      text: this.string(),
      pinned: this.boolean(),
      teamId: this.string().nullable(),
      team: this.belongsTo(orm.Team, 'teamId'),
      createdAt: this.string()
    }
  }
}
