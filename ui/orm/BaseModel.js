import inflection from 'inflection'
import { Model } from '@vuex-orm/core'
import VuexORMGraphQLPlugin from '@vuex-orm/plugin-graphql'

// eager lodingを制御するためのメソッド提供する
// hasOne は自動で取得されるが、hasManyはeagerLoadで指定しないと取得できない
// 多段では使えない
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

  static getContext() {
    return VuexORMGraphQLPlugin.instance.getContext()
  }

  static getSchema() {
    return this.getContext().loadSchema()
  }

  // 自身を取得するためのクエリ文字列を構築
  static buildField({ isList }) {
    const name = isList ? this.entity : inflection.singularize(this.entity)
    const fields = this.fields()
    const fieldsText = Object.keys(fields)
      .filter(field => field !== '$isPersisted' && !fields[field].foreignKey)
      .join(' ')

    return `${name} { ${fieldsText} }`
  }

  // Helpers
  get createdAtHM() {
    return $nuxt.$moment(this.createdAt).format('HH:mm')
  }

  get updatedAtHM() {
    return $nuxt.$moment(this.updatedAt).format('HH:mm')
  }

  get createdAtShort() {
    return $nuxt.$moment(this.createdAt).format('DD日 HH:mm:ss')
  }

  get updatedAtShort() {
    return $nuxt.$moment(this.updatedAt).format('DD日 HH:mm:ss')
  }

  get createdAtSimple() {
    return $nuxt.$moment(this.createdAt).format('MM月DD日 HH:mm:ss')
  }

  get updatedAtSimple() {
    return $nuxt.$moment(this.updatedAt).format('MM月DD日 HH:mm:ss')
  }
}
