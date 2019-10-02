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

  get statusNum() {
    switch (this.status) {
      case 'unsolved':
        return 0
      case 'in_progress':
        return 1
      case 'solved':
        return 2
      default:
        throw new Error(`unsupported status ${this.status}`)
    }
  }

  get statusJp() {
    switch (this.status) {
      case 'unsolved':
        return '未解決'
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

  get ourComments() {
    return this.comments.filter(c => c.isOurComment)
  }

  get theirsComments() {
    return this.comments.filter(c => !c.isOurComment)
  }

  get latestReplyAt() {
    const comment = $nuxt.findNewer(this.theirsComments)
    return comment ? comment.createdAt : null
  }

  get latestReplyAtDisplay() {
    const comment = $nuxt.findNewer(this.theirsComments)
    return comment ? comment.createdAtShort : 'なし'
  }
}
