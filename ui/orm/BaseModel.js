import { Model } from '@vuex-orm/core'

// eager lodingを制御するためのメソッド提供する
// hasOne は自動で取得されるが、hasManyはeagerLoadで指定しないと取得できない
export default class BaseModel extends Model {
  static async eagerFetch(args, eagerLoad) {
    const saveEagerLoad = this.eagerLoad
    this.eagerLoad = eagerLoad

    try {
      // bypass cache
      return await this.fetch(args, true)
    } finally {
      this.eagerLoad = saveEagerLoad
    }
  }
}
