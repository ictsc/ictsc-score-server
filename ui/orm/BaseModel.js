import { Model } from '@vuex-orm/core'
// import pluralizeLib from 'pluralize'
import inflection from 'inflection'
import VuexORMGraphQLPlugin from '@vuex-orm/plugin-graphql'

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

  static getSchema() {
    return VuexORMGraphQLPlugin.instance.getContext().loadSchema()
  }

  // 自身を受けてるためのフィールドを組み立てる
  static buildMutationField() {
    const fields = this.fields()
    const fieldsText = Object.keys(fields)
      .filter(field => field !== '$isPersisted' && !fields[field].foreignKey)
      .join(' ')

    return `
      ${inflection.camelize(this.name, true)} {
        ${fieldsText}
      }
    `
  }

  static buildMutation(mutationName, models) {
    // TODO: delete comments
    // const fields = Object.keys(this.fields()).filter(field => field !== '$isPersisted').join(" ")
    // const operationParams = Object.entries(params).map(o => o.join(': ')).join(', ')
    // const mutationParams = Object.keys(params).map(o => `${o.slice(1)}: ${o}`).join(', ')
    // const query = 'mutation addAnswer($input: AddAnswerInput!) {addAnswer(input: $input) { errors answer { id  }  }}'
    // const variables = { input: { problemId: '3230156e-75ab-442d-9fdf-3d9d19981c43', bodies: [['']]  } }
    // $nuxt.$store.dispatch('entities/simpleMutation', { query, variables })

    const fields = models.map(m => m.buildMutationField()).join('\n')
    const query = `
      mutation operator($input: ${inflection.camelize(mutationName)}Input!) {
        ${mutationName}(input: $input) {
          ${fields}
        }
      }
    `

    return query
  }

  // try catchで囲めばキャッチできる
  // storeに対してcreate update delete処理をする
  static async sendMutation(mutationName, params, models, type) {
    const query = this.buildMutation(mutationName, models)
    const res = await this.store().dispatch('entities/simpleMutation', {
      query,
      variables: { input: params }
    })

    console.log(res)

    if (!res.errors) {
      switch (type) {
        case 'upsert':
          Object.keys(res[mutationName])
            .filter(key => key[0] !== '_')
            .forEach(key => {
              const getter = `entities/${inflection.pluralize(key)}`
              const model = this.store().getters[getter]().model
              model.insertOrUpdate({ data: res[mutationName][key] })
            })
          break
        case 'delete':
          // paramsが1つなら、それをIDと断定して削除する
          const keys = Object.key(params)
          if (keys.length === 1) {
            // TODO: 動作確認&エラー処理
            this.delete(params[keys[0]])
          } else {
            // 実装が変わって意図しない挙動を起こす可能性がある
            throw new Error(`delete mutation support only one parameter`)
          }
          break
        default:
          throw new Error(`unsupported type ${type}`)
      }
    }

    return res
  }
}
