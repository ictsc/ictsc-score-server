import inflection from 'inflection'
import orm from '~/orm'
import BaseModel from '~/orm/BaseModel'

export default class Mutations extends BaseModel {
  // -- Mutations build helpers --

  static buildMutationField(field) {
    if (typeof field === 'string') {
      return field
    } else if (Array.isArray(field)) {
      return field[0].buildField({ isList: true })
    } else {
      return field.buildField({ isList: false })
    }
  }

  // fields: Modelの生クエリ文字列か配列
  static buildMutation(mutation, fields) {
    const fieldsString =
      typeof fields === 'string'
        ? fields
        : fields.map(field => this.buildMutationField(field)).join('\n')

    return `
      mutation operator($input: ${inflection.camelize(mutation)}Input!) {
        ${mutation}(input: $input) {
          ${fieldsString}
        }
      }
    `
  }

  // storeに対してcreate update delete処理をする
  // レスポンスは各モデルを想定
  static async sendMutationBase(mutation, params, fields, type) {
    const query = this.buildMutation(mutation, fields)
    const response = await this.store().dispatch('entities/simpleMutation', {
      query,
      variables: { input: params }
    })

    // if (!response[mutation]) {
    //   return response
    // }

    const responseForEach = func => {
      Object.keys(response[mutation]).forEach(key => {
        const value = response[mutation][key]
        console.info('response value', key, value)

        // __typenameなどは無視、値がレコードでなくても無視
        if (key[0] === '_' || typeof value !== 'object') {
          return
        }

        const getter = `entities/${inflection.pluralize(key)}`
        const model = this.store().getters[getter]().model

        // レスポンスから取得したモデルとレコードを関数に渡す
        if (Array.isArray(value)) {
          value.forEach(v => func(model, value))
        } else {
          func(model, value)
        }
      })
    }

    // Vuexへの登録・削除を行う
    switch (type) {
      case 'upsert':
        responseForEach((model, record) =>
          model.insertOrUpdate({ data: record })
        )
        break
      case 'delete':
        responseForEach((model, record) => model.delete(record.id))
        break
      default:
        throw new Error(`unsupported type ${type}`)
    }

    return response
  }

  // sendMutationBaseに加え、結果の通知を行う
  // 例外は全てここで握りつぶされる
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
    try {
      const response = await this.sendMutationBase(
        mutation,
        params,
        fields,
        type
      )

      if (action) {
        $nuxt.notifySuccess({
          message: `${action}に成功しました`
        })
      }

      // resolveがあれば実行する
      !!resolve && resolve(response)

      return response
    } catch (error) {
      // GraphQLからエラーがって返来たらハンドリングする
      console.info('[catch on sendMutation]', error.message)

      if (action) {
        $nuxt.notifyWarning({
          message: `${action}に失敗しました`,
          details: error.message
        })
      }
    }
  }

  // -- Mutations --

  static applyProblem({
    action,
    resolve,
    params: {
      code,
      categoryCode,
      previousProblemCode,
      order,
      teamIsolate,
      openAtBegin,
      openAtEnd,
      writer,
      secretText,
      mode,
      title,
      genre,
      text,
      perfectPoint,
      solvedCriterion,
      candidates,
      corrects,
      silent
    }
  }) {
    return this.sendMutation({
      action,
      resolve,
      mutation: 'applyProblem',
      params: {
        code,
        categoryCode,
        previousProblemCode,
        order,
        teamIsolate,
        openAtBegin,
        openAtEnd,
        writer,
        secretText,
        mode,
        title,
        genre,
        text,
        perfectPoint,
        solvedCriterion,
        candidates,
        corrects,
        silent
      },
      fields: [orm.Problem, orm.ProblemBody],
      type: 'upsert'
    })
  }

  static deleteProblem({ action, resolve, params: { code } }) {
    return this.sendMutation({
      action,
      resolve,
      mutation: 'deleteProblem',
      params: { code },
      fields: [orm.Problem, orm.ProblemBody],
      type: 'delete'
    })
  }

  static addProblemSupplement({
    action,
    resolve,
    params: { problemCode, text }
  }) {
    return this.sendMutation({
      action,
      resolve,
      mutation: 'addProblemSupplement',
      params: { problemCode, text },
      fields: [orm.ProblemSupplement],
      type: 'upsert'
    })
  }

  static deleteProblemSupplement({
    action,
    resolve,
    params: { problemSupplementId }
  }) {
    return this.sendMutation({
      action,
      resolve,
      mutation: 'deleteProblemSupplement',
      params: { problemSupplementId },
      fields: [orm.ProblemSupplement],
      type: 'delete'
    })
  }

  static applyProblemEnvironment({
    action,
    resolve,
    params: {
      problemCode,
      teamNumber,
      name,
      service,
      status,
      host,
      port,
      user,
      password,
      secretText,
      silent
    }
  }) {
    return this.sendMutation({
      action,
      resolve,
      mutation: 'applyProblemEnvironment',
      params: {
        problemCode,
        teamNumber,
        name,
        service,
        status,
        host,
        port,
        user,
        password,
        secretText,
        silent
      },
      fields: [orm.ProblemEnvironment],
      type: 'upsert'
    })
  }

  static deleteProblemEnvironment({
    action,
    resolve,
    params: { problemEnvironmentId }
  }) {
    return this.sendMutation({
      action,
      resolve,
      mutation: 'deleteProblemEnvironment',
      params: { problemEnvironmentId },
      fields: [orm.ProblemEnvironment],
      type: 'delete'
    })
  }

  static startIssue({ action, resolve, params: { problemId, text } }) {
    return this.sendMutation({
      action,
      resolve,
      mutation: 'startIssue',
      params: { problemId, text },
      fields: [orm.Issue, orm.IssueComment],
      type: 'upsert'
    })
  }

  static transitionIssueState({
    action,
    resolve,
    params: { issueId, currentStatus }
  }) {
    return this.sendMutation({
      action,
      resolve,
      mutation: 'transitionIssueState',
      params: { issueId, currentStatus },
      fields: [orm.Issue],
      type: 'upsert'
    })
  }

  static addIssueComment({ action, resolve, params: { issueId, text } }) {
    return this.sendMutation({
      action,
      resolve,
      mutation: 'addIssueComment',
      params: { issueId, text },
      fields: [orm.Issue, orm.IssueComment],
      type: 'upsert'
    })
  }

  static applyCategory({
    action,
    resolve,
    params: { code, title, description, order, silent }
  }) {
    return this.sendMutation({
      action,
      resolve,
      mutation: 'applyCategory',
      params: { code, title, description, order, silent },
      fields: [orm.Category],
      type: 'upsert'
    })
  }

  static deleteCategory({ action, resolve, params: { code } }) {
    return this.sendMutation({
      action,
      resolve,
      mutation: 'deleteCategory',
      params: { code },
      fields: [orm.Category],
      type: 'delete'
    })
  }

  static addAnswer({ action, resolve, params: { problemId, bodies } }) {
    return this.sendMutation({
      action,
      resolve,
      mutation: 'addAnswer',
      params: { problemId, bodies },
      fields: [orm.Answer],
      type: 'upsert'
    })
  }

  static applyScore({ action, resolve, params: { answerId, percent } }) {
    return this.sendMutation({
      action,
      resolve,
      mutation: 'applyScore',
      params: { answerId, percent },
      fields: [orm.Answer],
      type: 'upsert'
    })
  }

  static confirmingAnswer({
    action,
    resolve,
    params: { answerId, confirming }
  }) {
    return this.sendMutation({
      action,
      resolve,
      mutation: 'confirmingAnswer',
      params: { answerId, confirming },
      fields: [orm.Answer],
      type: 'upsert'
    })
  }

  static regradeAnswers({ action, resolve, params: { problemId } }) {
    return this.sendMutation({
      action,
      resolve,
      mutation: 'regradeAnswers',
      params: { problemId },
      fields: [[orm.Answer], 'total', 'succeeded', 'failed'],
      type: 'upsert'
    })
  }

  static applyTeam({
    action,
    resolve,
    params: {
      name,
      number,
      role,
      beginner,
      secretText,
      password,
      organization,
      color,
      silent
    }
  }) {
    return this.sendMutation({
      action,
      resolve,
      mutation: 'applyTeam',
      params: {
        name,
        number,
        role,
        beginner,
        secretText,
        password,
        organization,
        color,
        silent
      },
      fields: [orm.Team],
      type: 'upsert'
    })
  }

  static addNotice({
    action,
    resolve,
    params: { title, text, pinned, targetTeamId }
  }) {
    return this.sendMutation({
      action,
      resolve,
      mutation: 'addNotice',
      params: { title, text, pinned, targetTeamId },
      fields: [orm.Notice],
      type: 'upsert'
    })
  }

  static addPenalty({ action, resolve, params: { problemId } }) {
    return this.sendMutation({
      action,
      resolve,
      mutation: 'addPenalty',
      params: { problemId },
      fields: [orm.Penalty],
      type: 'upsert'
    })
  }

  static deleteNotice({ action, resolve, params: { noticeId } }) {
    return this.sendMutation({
      action,
      resolve,
      mutation: 'deleteNotice',
      params: { noticeId },
      fields: [orm.Notice],
      type: 'delete'
    })
  }

  static pinNotice({ action, resolve, params: { noticeId, pinned } }) {
    return this.sendMutation({
      action,
      resolve,
      mutation: 'pinNotice',
      params: { noticeId, pinned },
      fields: [orm.Notice],
      type: 'upsert'
    })
  }

  static updateConfig({ action, resolve, params: { key, value } }) {
    return this.sendMutation({
      action,
      resolve,
      mutation: 'updateConfig',
      params: { key, value },
      fields: [orm.Config],
      type: 'upsert'
    })
  }

  static deleteSession({ action, resolve, params: { sessionId } }) {
    return this.sendMutation({
      action,
      resolve,
      mutation: 'deleteSession',
      params: { sessionId },
      fields: [orm.Session],
      type: 'delete'
    })
  }
}
