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
}
