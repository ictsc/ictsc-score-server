import { Model } from '@vuex-orm/core'
// import pluralizeLib from 'pluralize'
import inflection from 'inflection'
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

  // 自身を受けてるためのフィールドを組み立てる
  static buildMutationField() {
    const name = inflection.singularize(this.entity)
    const fields = this.fields()
    const fieldsText = Object.keys(fields)
      .filter(field => field !== '$isPersisted' && !fields[field].foreignKey)
      .join(' ')

    return `
      ${name} {
        ${fieldsText}
      }
    `
  }

  static buildMutation(mutation, fields) {
    // TODO: delete comments
    // const fields = Object.keys(this.fields()).filter(field => field !== '$isPersisted').join(" ")
    // const operationParams = Object.entries(params).map(o => o.join(': ')).join(', ')
    // const mutationParams = Object.keys(params).map(o => `${o.slice(1)}: ${o}`).join(', ')
    // const query = 'mutation addAnswer($input: AddAnswerInput!) {addAnswer(input: $input) { errors answer { id  }  }}'
    // const variables = { input: { problemId: '3230156e-75ab-442d-9fdf-3d9d19981c43', bodies: [['']]  } }
    // $nuxt.$store.dispatch('entities/simpleMutation', { query, variables })

    const fieldsString =
      typeof fields === 'string'
        ? fields
        : fields.map(m => m.buildMutationField()).join('\n')

    const query = `
      mutation operator($input: ${inflection.camelize(mutation)}Input!) {
        ${mutation}(input: $input) {
          ${fieldsString}
        }
      }
    `

    return query
  }

  // try catchで囲めばキャッチできる
  // storeに対してcreate update delete処理をする
  // レスポンスは各モデルを想定
  static async sendMutationBase(mutation, params, fields, type) {
    const query = this.buildMutation(mutation, fields)
    const res = await this.store().dispatch('entities/simpleMutation', {
      query,
      variables: { input: params }
    })

    // エラーでないならvuexへの登録・更新・削除を行う
    if (!res.errors) {
      const resForEach = f => {
        Object.keys(res[mutation])
          .filter(key => key[0] !== '_')
          .forEach(key => {
            const getter = `entities/${inflection.pluralize(key)}`
            const model = this.store().getters[getter]().model

            // レスポンスから取得したモデルとレコードを関数に渡す
            f(model, res[mutation][key])
          })
      }

      switch (type) {
        case 'upsert':
          resForEach((model, record) => model.insertOrUpdate({ data: record }))
          break
        case 'delete':
          resForEach((model, record) => model.delete(record.id))
          break
        default:
          throw new Error(`unsupported type ${type}`)
      }
    }

    return res
  }

  // sendMutationBaseに加え、結果の通知を行う
  // 例外は全て個々で握りつぶされる
  // actionを指定すると、成功・失敗・例外 の通知を出す
  static async sendMutation({
    mutation,
    params,
    fields,
    type,
    subject,
    resolve,
    action
  }) {
    const notify = (type, message) =>
      this.store().commit(`notification/${type}`, { message })

    try {
      const res = await this.sendMutationBase(mutation, params, fields, type)

      if (res.errors) {
        console.error(res.errors)
        if (action) {
          notify('notifyWarning', `${action}に失敗しました`)
        }
      } else {
        if (action) {
          notify('notifySuccess', `${action}に成功しました`)
        }

        // resolveがあれば実行する
        !!resolve && resolve(res)
      }

      return res
    } catch (error) {
      // apollo client側でハンドル済みなため、ここでは通知しない
      console.error(error)
    }
  }

  get createdAtHM() {
    // eslint-disable-next-line no-undef
    return $nuxt.$moment(this.createdAt).format('HH:mm')
  }

  get updatedAtHM() {
    // eslint-disable-next-line no-undef
    return $nuxt.$moment(this.updatedAt).format('HH:mm')
  }

  get createdAtShort() {
    // eslint-disable-next-line no-undef
    return $nuxt.$moment(this.createdAt).format('D日 HH:mm:ss')
  }

  get updatedAtShort() {
    // eslint-disable-next-line no-undef
    return $nuxt.$moment(this.updatedAt).format('D日 HH:mm:ss')
  }
}
