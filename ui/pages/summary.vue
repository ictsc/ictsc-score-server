<template>
  <v-container>
    <v-row justify="center" class="pt-0 hide-on-print">
      <v-col cols="auto" align="center" class="py-0">
        <page-title title="状況" />
      </v-col>
    </v-row>

    <!-- 成績一覧テーブル -->
    <report-card-table />
  </v-container>
</template>
<script>
import PageTitle from '~/components/commons/PageTitle'
import ReportCardTable from '~/components/summary/ReportCardTable'

export default {
  name: 'Summary',
  components: {
    PageTitle,
    ReportCardTable,
  },
}
</script>
