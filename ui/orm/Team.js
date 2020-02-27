import BaseModel from '~/orm/BaseModel'

export default class Team extends BaseModel {
  static entity = 'teams'

  static fields() {
    return {
      id: this.string(),
      role: this.string(),
      number: this.number(),
      beginner: this.boolean(),
      name: this.string(),
      organization: this.string(),
      color: this.string(),
      secretText: this.string().nullable(),
      createdAt: this.string(),
      updatedAt: this.string()
    }
  }

  static mutationFields() {
    return {
      role: '',
      name: '',
      organization: '',
      secretText: '',
      number: 0,
      color: '#FFFFFF',
      beginner: false,
      password: null
    }
  }

  get displayName() {
    return `No.${this.number} ${this.name}`
  }

  get numberStr() {
    return String(this.number)
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

  // team99は毎回使われるテストユーザー
  static get playersWithoutTeam99() {
    return Team.all().filter(t => t.isPlayer && t.name !== 'team99')
  }
}
