import orm from '~/orm'
import BaseModel from '~/orm/BaseModel'

export default class Session extends BaseModel {
  static entity = 'sessions'

  static fields() {
    return {
      id: this.string(),
      teamId: this.string(),
      team: this.belongsTo(orm.Team, 'teamId')
    }
  }
}
