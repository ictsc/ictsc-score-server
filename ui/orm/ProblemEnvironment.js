import orm from '~/orm'
import BaseModel from '~/orm/BaseModel'

export default class ProblemEnvironment extends BaseModel {
  static entity = 'problemEnvironments'

  static fields() {
    return {
      id: this.string(),
      teamId: this.string().nullable(),
      team: this.belongsTo(orm.Team, 'teamId'),
      problemId: this.string(),
      problem: this.belongsTo(orm.Problem, 'problemId'),
      name: this.string(),
      service: this.string(),
      status: this.string(),
      host: this.string(),
      port: this.number(),
      user: this.string(),
      password: this.string(),
      secretText: this.string().nullable(),
      createdAt: this.string(),
      updatedAt: this.string()
    }
  }

  static mutationFields() {
    return {
      problemCode: undefined,
      teamNumber: undefined,
      name: '',
      service: 'SSH',
      status: 'APPLIED',
      host: '',
      port: 22,
      user: '',
      password: '',
      secretText: ''
    }
  }

  get teamNumber() {
    return this.team && this.team.number
  }

  get problemCode() {
    return this.problem && this.problem.code
  }

  get isSSH() {
    return /SSH/i.test(this.service)
  }

  get isVNC() {
    return /VNC/i.test(this.service)
  }

  get isTelnet() {
    return /Telnet/i.test(this.service)
  }

  get sshCommand() {
    return `ssh '${this.user}@${this.host}' -p ${this.port}`
  }

  get sshpassCommand() {
    return `sshpass -p "${this.password}" ${this.sshCommand}`
  }

  get vncURL() {
    return `${this.host}:${this.port}`
  }

  get telnetCommand() {
    return `telnet ${this.host} ${this.port}`
  }
}
