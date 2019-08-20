import orm from '~/orm'
import BaseModel from '~/orm/BaseModel'

export default class Category extends BaseModel {
  static entity = 'categories'

  static fields() {
    return {
      id: this.string(),
      code: this.string().nullable(),
      title: this.string(),
      description: this.string(),
      order: this.number(),
      problems: this.hasMany(orm.Problem, 'categoryId'),
      updatedAt: this.string()
    }
  }

  static applyCategory({
    action,
    resolve,
    params: { code, title, description, order }
  }) {
    return this.sendMutation({
      action,
      resolve,
      mutation: 'applyCategory',
      params: { code, title, description, order },
      fields: [Category],
      type: 'upsert'
    })
  }
}
