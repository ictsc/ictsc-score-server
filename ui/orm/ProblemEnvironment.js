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
      updatedAt: this.string(),
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
      secretText: '',
    }
  }

  get teamNumber() {
    return this.team && this.team.number
  }

  get problemCode() {
    return this.problem && this.problem.code
  }

  get sshCommand() {
    return `ssh '${this.user}@${this.host}' -p ${this.port}`
  }

  get copyText() {
    if (/^SSH$/i.test(this.service)) {
      // return { text: this.sshCommand }
      return {
        text: `sshpass -p "${this.password}" ${this.sshCommand} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null`,
        display: 'sshpassコマンド',
        tooltip: 'sshpassコマンドを使うとpassword入力の手間が省けます',
      }
    } else if (/^SSH\(公開鍵\)$/i.test(this.service)) {
      return {
        text: this.sshCommand,
        display: 'sshコマンド',
      }
    } else if (/^Telnet$/i.test(this.service)) {
      return { text: `telnet ${this.host} ${this.port}` }
    } else if (/^VNC$/i.test(this.service)) {
      return { text: `${this.host}:${this.port}` }
    } else {
      // コピー対象無し
      return { text: '' }
    }
  }

  static get supportedServices() {
    return ['SSH', 'SSH(公開鍵)', 'Telnet', 'VNC']
  }
}
