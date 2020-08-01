<template>
  <v-data-table
    v-model="selectedItems"
    :items="sessions"
    :headers="headers"
    :mobile-breakpoint="0"
    :search="!!search ? search : ''"
    :disable-sort="sessions.length <= 1"
    sort-by="updatedAtSimple"
    sort-desc
    multi-sort
    show-select
    dense
    class="elevation-2 text-no-wrap ma-0"
  >
    <template v-slot:top>
      <v-row no-gutters>
        <v-col cols="6">
          <v-btn :loading="loading" block elevation="1" @click="fetch">
            <v-icon>mdi-rotate-3d-variant</v-icon>
            {{ hasSessions ? '更新' : '読み込み' }}
          </v-btn>
        </v-col>

        <v-col cols="6">
          <v-dialog
            v-model="showDialog"
            :persistent="sending"
            scrollable
            max-width="16em"
          >
            <v-card>
              <v-card-title>
                強制切断しますか?
              </v-card-title>

              <v-card-text class="black--text">
                <div v-for="role in selectedRoles" :key="role[0]">
                  {{ role[0] }} {{ role[1] }}セッション
                </div>
              </v-card-text>

              <v-card-actions>
                <v-btn :loading="sending" color="error" @click="deleteSessions">
                  切断
                </v-btn>

                <v-spacer />

                <v-btn :disabled="sending" @click="close">
                  キャンセル
                </v-btn>
              </v-card-actions>
            </v-card>
            <template v-slot:activator="{ on }">
              <v-btn :disabled="!selected" block color="error" v-on="on">
                <v-icon>mdi-content-cut</v-icon>切断
              </v-btn>
            </template>
          </v-dialog>
        </v-col>
      </v-row>

      <v-text-field
        v-if="hasSessions"
        v-model="search"
        label="Search"
        append-icon="mdi-table-search"
        clearable
        single-line
        hide-details
        class="py-1 px-2"
      />
    </template>
  </v-data-table>
</template>
<script>
import orm from '~/orm'

// 自身は赤くする
// roleによって色を付ける

export default {
  name: 'SessionTable',
  data() {
    return {
      showDialog: false,
      selectedItems: [],
      search: '',
      sending: false,
      loading: false,
      headers: [
        { text: '権限', value: 'team.role' },
        { text: 'チーム', value: 'team.displayName' },
        { text: '最終アクセス時刻', value: 'updatedAtSimple' },
        { text: '最終アクセスIP', value: 'latestIp' },
        { text: 'ログイン時刻', value: 'createdAtSimple' },
        { text: 'セッションID', value: 'id' },
      ],
    }
  },
  computed: {
    sessions() {
      return orm.Session.query().with(['team']).all()
      // 存在しないチームIDを持つレコードは表示しない
    },
    hasSessions() {
      return this.sessions.length !== 0
    },
    selected() {
      return this.selectedItems.length !== 0
    },
    selectedRoles() {
      const collect = Object.entries(
        this.$_.groupBy(
          this.selectedItems,
          (session) => session.team && session.team.role
        )
      )
      return collect.map((o) => [o[0], o[1].length])
    },
  },
  mounted() {
    this.fetch()
  },
  methods: {
    async fetch() {
      this.selectedItems = []
      this.loading = true
      await orm.Queries.sessionsTeam()
      this.loading = false
    },
    async deleteSessions() {
      this.sending = true
      let succeededCount = 0

      for (const session of this.selectedItems) {
        await orm.Mutations.deleteSession({
          action: '',
          resolve: () => {
            ++succeededCount
          },
          params: { sessionId: session.id },
        })
      }

      this.sending = false

      if (succeededCount === this.selectedItems.length) {
        this.notifySuccess({
          message: `${succeededCount}セッション切断しました`,
        })
      } else {
        this.notifyWarning({
          message: `${succeededCount}/${this.selectedItems.length}セッション切断しました`,
        })
      }

      this.fetch()
      this.close()
    },
    close() {
      this.showDialog = false
    },
  },
}
</script>
