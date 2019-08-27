import BaseModel from '~/orm/BaseModel'

export default class Team extends BaseModel {
  static entity = 'teams'

  static fields() {
    return {
      id: this.string(),
      role: this.string(),
      name: this.string().nullable(),
      organization: this.string().nullable(),
      number: this.number().nullable(),
      color: this.string().nullable()
    }
  }

  static applyTeam({
    action,
    resolve,
    params: { name, number, role, password, organization, color }
  }) {
    return this.sendMutation({
      action,
      resolve,
      mutation: 'applyTeam',
      params: { name, number, role, password, organization, color },
      fields: [Team],
      type: 'upsert'
    })
  }

  get displayName() {
    return `No.${this.number} ${this.name}`
  }

  get numberStr() {
    return this.number.toString()
  }
}
