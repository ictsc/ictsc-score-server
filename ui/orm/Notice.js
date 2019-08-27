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
      targetTeamId: this.string().nullable(),
      targetTeam: this.belongsTo(orm.Team, 'targetTeamId'),
      createdAt: this.string()
    }
  }

  static addNotice({
    action,
    resolve,
    params: { title, text, pinned, targetTeamId }
  }) {
    return this.sendMutation({
      action,
      resolve,
      mutation: 'addNotice',
      params: { title, text, pinned, targetTeamId },
      fields: [Notice],
      type: 'upsert'
    })
  }

  static deleteNotice({ action, resolve, params: { noticeId } }) {
    return this.sendMutation({
      action,
      resolve,
      mutation: 'deleteNotice',
      params: { noticeId },
      fields: [Notice],
      type: 'delete'
    })
  }

  static pinNotice({ action, resolve, params: { noticeId, pinned } }) {
    return this.sendMutation({
      action,
      resolve,
      mutation: 'pinNotice',
      params: { noticeId, pinned },
      fields: [Notice],
      type: 'upsert'
    })
  }
}
