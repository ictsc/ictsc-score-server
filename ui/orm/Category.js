import { Model } from '@vuex-orm/core'
import orm from '~/orm'

export default class Category extends Model {
  static entity = 'categories'
  static eagerLoad = ['problems']

  static fields() {
    return {
      id: this.string(),
      code: this.string().nullable(),
      description: this.string(),
      order: this.number(),
      problems: this.hasMany(orm.Problem, 'categoryId')
    }
  }
}
