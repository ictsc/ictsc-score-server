<template>
  <v-col>
    <v-row justify="start">
      <label>成績出力</label>
    </v-row>

    <v-row justify="start">
      <v-btn :loading="loading" small @click="click">
        エクスポート
        <v-icon>mdi-file-export</v-icon>
      </v-btn>
    </v-row>
  </v-col>
</template>
<script>
import orm from '~/orm'

export default {
  name: 'ExportImportButtons',
  data() {
    return {
      loading: false,
    }
  },
  methods: {
    async getReportCards() {
      await orm.Queries.reportCards()

      const list = orm.ReportCard.all()
      list.forEach((report) => delete report.$id)
      return list
    },
    async click() {
      this.loading = true

      this.download(
        'text/json',
        `scores ${this.currentDateTimeString()}.json`,
        JSON.stringify(await this.getReportCards())
      )

      this.loading = false
    },
  },
}
</script>
