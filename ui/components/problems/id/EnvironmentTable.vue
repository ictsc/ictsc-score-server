<template>
  <v-data-table
    :headers="headers"
    :items="environments"
    :search="!!search ? search : ''"
    :sort-by="sortBy"
    :items-per-page.sync="itemsPerPage"
    :hide-default-footer="environments.length <= itemsPerPage"
    :mobile-breakpoint="0"
    dense
    multi-sort
    class="elevation-2 text-no-wrap"
  >
    <template v-slot:top>
      <v-text-field
        v-if="isStaff"
        v-model="search"
        label="Search"
        append-icon="mdi-table-search"
        autofocus
        clearable
        single-line
        hide-details
        class="mt-0 py-1 px-2"
      />
    </template>

    <template v-slot:item.note="{ value }">
      <markdown v-if="!!value" :content="value" />
    </template>
  </v-data-table>
</template>
<script>
import Markdown from '~/components/commons/Markdown'

export default {
  name: 'EnvironmentTable',
  components: {
    Markdown
  },
  props: {
    environments: {
      type: Array,
      required: true
    }
  },
  data() {
    return {
      itemsPerPage: 10,
      search: undefined
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
        { text: 'パスワード', value: 'password' }
      ]

      if (this.isStaff) {
        headers.unshift(
          { text: 'No.', value: 'team.number' },
          { text: 'チーム名', value: 'team.name' },
          { text: '状態', value: 'status' }
        )

        headers.push(
          { text: '更新時刻', value: 'updatedAtSimple' },
          { text: 'メモ', value: 'note' }
        )
      }

      return headers
    }
  }
}
</script>
