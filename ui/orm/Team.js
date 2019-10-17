import orm from '~/orm'
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

  get displayName() {
    return `No.${this.number} ${this.name}`
  }

  get numberStr() {
    return this.number.toString()
  }
   get isStaff() {
    return this.role === 'staff'
  }
  get isAudience() {
    return this.role === 'audience'
  }
  get isPlayer() {
    return this.role === 'player'
  }
  static get players() {
    return Team.all().filter(t => t.isPlayer)
  }
}
