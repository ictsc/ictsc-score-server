import BaseModel from '~/orm/BaseModel'

export default class ReportCard extends BaseModel {
  static entity = 'reportCards'
  static primaryKey = 'teamName'

  static fields() {
    return {
      rank: this.number().nullable(),
      score: this.number(),
      teamName: this.string(),
      teamOrganization: this.string(),
      eachScore: this.attr(),
      eachPercent: this.attr(),
      problemTitles: this.attr(),
      problemGenres: this.attr(),
    }
  }
}
