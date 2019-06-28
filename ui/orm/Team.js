import { Model } from '@vuex-orm/core'

export default class Team extends Model {
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
}
