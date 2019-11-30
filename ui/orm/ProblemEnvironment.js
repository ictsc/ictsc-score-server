import orm from '~/orm'
import BaseModel from '~/orm/BaseModel'

export default class ProblemEnvironment extends BaseModel {
  static entity = 'problemEnvironments'

  static fields() {
    return {
      id: this.string(),
      teamId: this.string(),
      team: this.belongsTo(orm.Team, 'teamId'),
      problemId: this.string(),
      problem: this.belongsTo(orm.Problem, 'problemId'),
      status: this.string(),
      host: this.string(),
      user: this.string(),
      password: this.string(),
      note: this.string().nullable(),
      createdAt: this.string(),
      updatedAt: this.string()
    }
  }

  get sshCommand() {
    return `ssh "${this.user}@${this.host}"`
  }

  get sshpassCommand() {
    return `sshpass -p "${this.password}" ${this.sshCommand}`
  }

  get vncURL() {
    return `${this.host}:5901`
  }
}
