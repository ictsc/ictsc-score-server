import orm from '~/orm'
import BaseModel from '~/orm/BaseModel'

export default class Problem extends BaseModel {
  static entity = 'problems'

  static fields() {
    return {
      id: this.string(),
      order: this.number(),
      teamIsolate: this.boolean(),
      previousProblemId: this.string().nullable(),
      previousProblem: this.belongsTo(orm.Problem, 'previousProblemId'),
      categoryId: this.string().nullable(),
      category: this.belongsTo(orm.Category, 'categoryId'),
      // Rangeの[begin: end)
      openAtBegin: this.string().nullable(),
      openAtEnd: this.string().nullable(),
      // staffのみ見せる
      code: this.string().nullable(),
      writer: this.string().nullable(),
      secretText: this.string().nullable(),
      // 開放時のみ見れるフィールド
      body: this.hasOne(orm.ProblemBody, 'problemId'),
      // staffは全チームの環境を見える: playerは自チームのみ
      environments: this.hasMany(orm.ProblemEnvironment, 'problemId'),
      supplements: this.hasMany(orm.ProblemSupplement, 'problemId'),
      answers: this.hasMany(orm.Answer, 'problemId'),
      issues: this.hasMany(orm.Issue, 'problemId'),
      solvedCount: this.number()
    }
  }

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
      text,
      perfectPoint,
      solvedCriterion,
      candidates,
      corrects
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
        text,
        perfectPoint,
        solvedCriterion,
        candidates,
        corrects
      },
      fields: [Problem, orm.ProblemBody],
      type: 'upsert'
    })
  }

  static deleteProblem({ action, resolve, params: { code } }) {
    return this.sendMutation({
      action,
      resolve,
      mutation: 'deleteProblem',
      params: { code },
      fields: [Problem, orm.ProblemBody],
      type: 'delete'
    })
  }

  // ProblemBodyのフィールドに透過的にアクセスするためのゲッター
  // 特にProblemModalに必要
  get mode() {
    return this.body.mode
  }
  get title() {
    return this.body.title
  }
  get text() {
    return this.body.text
  }
  get perfectPoint() {
    return this.body.perfectPoint
  }
  get solvedCriterion() {
    return this.body.solvedCriterion
  }
  get candidates() {
    return this.body.candidates
  }
  get corrects() {
    return this.body.corrects
  }
  get createdAt() {
    return this.body.createdAt
  }
  get updatedAt() {
    return this.body.updatedAt
  }
  get previousProblemCode() {
    return this.previousProblem && this.previousProblem.code
  }
  get categoryCode() {
    return this.category && this.category.code
  }
}
