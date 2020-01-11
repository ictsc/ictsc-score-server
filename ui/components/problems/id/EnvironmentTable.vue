<template>
  <v-data-table
    :headers="headers"
    :items="environments"
    :search="!!search ? search : ''"
    :sort-by="sortBy"
    :items-per-page.sync="itemsPerPage"
    :hide-default-footer="environments.length <= itemsPerPage"
    :disable-sort="environments.length <= 1"
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

    <template v-slot:item.sshCommand="{ value }">
      <v-btn
        v-clipboard:copy="value"
        v-clipboard:success="sshCommandCopied"
        v-clipboard:error="onError"
        icon
        small
      >
        <v-icon>mdi-clipboard-text-outline</v-icon>
      </v-btn>
      {{ value }}
    </template>

    <template v-slot:item.sshpassCommand="{ value }">
      <v-tooltip top content-class="pa-0 elevation-8 opacity-1">
        <template v-slot:activator="{ on }">
          <v-btn
            v-clipboard:copy="value"
            v-clipboard:success="sshpassCommandCopied"
            v-clipboard:error="onError"
            icon
            small
            v-on="on"
          >
            <v-icon>mdi-clipboard-text-outline</v-icon>
          </v-btn>
        </template>

        <v-card>
          <v-card-text class="black--text">
            sshpassコマンドを使うとpassword入力の手間が省けます
          </v-card-text>
        </v-card>
      </v-tooltip>
    </template>

    <template v-slot:item.vncURL="{ value }">
      <v-btn
        v-clipboard:copy="value"
        v-clipboard:success="vncURLCommandCopied"
        v-clipboard:error="onError"
        icon
        small
      >
        <v-icon>mdi-clipboard-text-outline</v-icon>
      </v-btn>
      {{ value }}
    </template>

    <template v-slot:item.password="{ value }">
      <v-btn
        v-clipboard:copy="value"
        v-clipboard:success="passwordCopied"
        v-clipboard:error="onError"
        icon
        small
      >
        <v-icon>mdi-clipboard-text-outline</v-icon>
      </v-btn>
      {{ value }}
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
      if (this.isStaff) {
        return [
          { text: 'No.', value: 'team.number' },
          { text: 'チーム名', value: 'team.displayName' },
          { text: '状態', value: 'status' },
          { text: 'ホスト', value: 'host' },
          { text: 'ユーザー', value: 'user' },
          { text: 'パスワード', value: 'password' },
          { text: 'sshpass', value: 'sshpassCommand' },
          { text: '更新時刻', value: 'updatedAtSimple' },
          { text: 'メモ', value: 'note' }
        ]
      } else {
        return [
          { text: 'SSHコマンド', value: 'sshCommand' },
          { text: 'VNCアクセス先', value: 'vncURL' },
          { text: 'パスワード', value: 'password' },
          { text: 'sshpassコマンド', value: 'sshpassCommand' }
        ]
      }
    }
  },
  methods: {
    sshCommandCopied() {
      this.notifyInfo({ message: 'sshのコマンドをコピーしました' })
    },
    sshpassCommandCopied() {
      this.notifyInfo({ message: 'sshpassのコマンドをコピーしました' })
    },
    vncURLCommandCopied() {
      this.notifyInfo({ message: 'VNCアクセス先をコピーしました' })
    },
    passwordCopied() {
      this.notifyInfo({ message: 'パスワードをコピーしました' })
    },
    onError(e) {
      this.notifyError({ message: 'コピーに失敗しました' })
    }
  }
}
</script>
