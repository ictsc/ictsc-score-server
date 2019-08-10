import orm from '~/orm'
import BaseModel from '~/orm/BaseModel'

export default class Issue extends BaseModel {
  static entity = 'issues'
  // 多段でfetchEagerが使えないのでここで明記
  static eagerLoad = ['comments']

  static fields() {
    return {
      id: this.string(),
      status: this.string(),
      comments: this.hasMany(orm.IssueComment, 'issueId'),
      problemId: this.string(),
      problem: this.belongsTo(orm.Problem, 'problemId'),
      teamId: this.string(),
      team: this.belongsTo(orm.Team, 'teamId'),
      updatedAt: this.string()
    }
  }

  static startIssue({ action, resolve, params: { problemId, text } }) {
    return this.sendMutation({
      action,
      resolve,
      mutation: 'startIssue',
      params: { problemId, text },
      fields: [Issue, orm.IssueComment],
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
      fields: [Issue],
      type: 'upsert'
    })
  }

  get statusJp() {
    switch (this.status) {
      case 'unsolved':
        return '要対応'
      case 'in_progress':
        return '対応中'
      case 'solved':
        return '解決済'
      default:
        throw new Error(`unsupported status ${this.status}`)
    }
  }

  get statusColor() {
    switch (this.status) {
      case 'unsolved':
        return 'error'
      case 'in_progress':
        return 'warning'
      case 'solved':
        return 'success'
      default:
        throw new Error(`unsupported status ${this.status}`)
    }
  }
}
