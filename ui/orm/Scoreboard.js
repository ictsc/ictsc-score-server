import orm from '~/orm'
import BaseModel from '~/orm/BaseModel'

export default class Scoreboard extends BaseModel {
  static entity = 'scoreboards'
  static primaryKey = 'teamId'

  // このモデルだけはキャシュが残ってると面倒だから取得後に全消しする
  static fields() {
    return {
      teamId: this.string().nullable(),
      team: this.belongsTo(orm.Team, 'teamId'),
      rank: this.number().nullable(),
      score: this.number().nullable()
    }
  }

  get displayRank() {
    return String(this.rank !== null ? this.rank : '?').padStart(2) + '位'
  }

  get displayScore() {
    return String(this.score !== null ? this.score : '????').padStart(4) + '点'
  }

  get displayTeamName() {
    return this.team ? this.team.displayName : '????'
  }
}
