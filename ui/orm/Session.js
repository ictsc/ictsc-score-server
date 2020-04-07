import orm from '~/orm'
import BaseModel from '~/orm/BaseModel'

export default class Session extends BaseModel {
  static entity = 'sessions'

  static fields() {
    return {
      id: this.string().nullable(),
      teamId: this.string().nullable(),
      team: this.belongsTo(orm.Team, 'teamId'),
      latestIp: this.string().nullable(),
      createdAt: this.string().nullable(),
      updatedAt: this.string().nullable(),
    }
  }
}
