<template>
  <v-data-table
    :headers="headers"
    :items="environments"
    :search="search"
    :sort-by="sortBy"
    :items-per-page="itemsPerPage"
    :hide-default-footer="environments.length <= itemsPerPage"
    dense
    multi-sort
    class="elevation-2 text-no-wrap"
  >
  </v-data-table>
</template>
<script>
// TODO: チーム名クリックでチーム詳細ページ
// TODO: チーム詳細ページには問題環境一覧
// TODO: 削除編集新規ボタンを作る
export default {
  name: 'ProblemEnvironmentTable',
  props: {
    environments: {
      type: Array,
      required: true
    },
    search: {
      type: String,
      required: true
    }
  },
  data() {
    return {
      itemsPerPage: 10
    }
  },
  computed: {
    sortBy() {
      return this.isStaff ? ['team.number'] : []
    },
    headers() {
      const headers = [
        { text: 'ホスト', value: 'host' },
        { text: 'ユーザー', value: 'user' },
        { text: 'パスワード', value: 'password' },
        // 必要無さそうなので幅節約
        // { text: '作成時刻', value: 'createdAt' },
        { text: '更新時刻', value: 'updatedAt' }
      ]

      if (this.isStaff) {
        headers.unshift(
          { text: 'No.', value: 'team.number' },
          { text: 'チーム名', value: 'team.name' },
          { text: '状態', value: 'status' }
        )
      }

      return headers
    }
  }
}
</script>
