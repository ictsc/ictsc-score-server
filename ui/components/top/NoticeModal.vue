<template>
  <markdown-editor-modal
    ref="modal"
    :value="value"
    storage-key="newNotice"
    title="お知らせ追加"
    submit-label="追加"
    label="テキスト"
    :edited="edited"
    @input="$emit('input', $event)"
    @submit="addNotice($event)"
    @reset="reset"
  >
    <!-- モーダル内容 -->
    <template v-slot:prepend>
      <!-- 宛先 -->
      <v-overflow-btn
        v-model="teamId"
        :readonly="sending"
        :items="teams"
        :rules="teamRuels"
        item-text="displayName"
        item-value="id"
        label="宛先"
        auto-select-first
        hide-defaults
        editable
        dense
      />

      <!-- タイトル -->
      <v-text-field
        v-model="title"
        label="タイトル"
        :readonly="sending"
        :rules="titleRules"
        class="mb-2"
      />

      <!-- ピン -->
      <div class="caption">ピン止め</div>
      <pin-button
        :value="pinned"
        :disabled="sending"
        class="mb-4"
        @click="pinned = !pinned"
      />
    </template>

    <!-- 確認モーダル -->
    <template v-slot:prepend-confirm>
      <div class="pa-2">
        <div>タイトル: {{ title }}</div>
        <v-divider />
        <div>対象: {{ team ? team.displayName : '全体' }}</div>
        <v-divider />
      </div>
    </template>
  </markdown-editor-modal>
</template>
<script>
import { JsonStroage } from '~/plugins/json-storage'
import orm from '~/orm'

import PinButton from '~/components/commons/PinButton'
import MarkdownEditorModal from '~/components/commons/MarkdownEditorModal'

// teamIdのデフォルトはnull(全体)じゃなくてundefined(未指定)
const defaultValues = {
  title: '',
  pinned: false,
  teamId: undefined,
}

export default {
  name: 'NoticeModal',
  components: {
    MarkdownEditorModal,
    PinButton,
  },
  mixins: [
    // 透過的にローカルストレージにアクセスできる
    // newNotice-titleなどのストレージにthis.titleでアクセスする
    ...Object.entries(defaultValues).map(([k, v]) =>
      JsonStroage.accessor('newNotice', k, v)
    ),
  ],
  props: {
    // v-model
    value: {
      type: Boolean,
      required: true,
    },
  },
  data() {
    return {
      sending: false,
      titleRules: [(v) => !!v || '必須'],
      teamRuels: [(v) => v !== undefined || '必須'],
    }
  },
  computed: {
    team() {
      return this.teamId ? orm.Team.find(this.teamId) : null
    },
    teams() {
      const teams = this.sortByNumber(orm.Team.query().all())
      teams.unshift({ displayName: '全体', id: null })
      return teams
    },
    edited() {
      return Object.entries(defaultValues).some(([k, v]) => this[k] !== v)
    },
  },
  watch: {
    value(value) {
      // 開いた時にfetchする
      if (value) {
        orm.Queries.teams()
      }
    },
  },
  methods: {
    reset() {
      Object.entries(defaultValues).map(([k, v]) => (this[k] = v))
    },
    // textだけMarkdownEditorModalから来る
    async addNotice(text) {
      this.sending = true

      await orm.Mutations.addNotice({
        action: 'お知らせ追加',
        resolve: () => this.$refs.modal.succeeded(),
        params: {
          title: this.title,
          text,
          pinned: this.pinned,
          teamId: this.teamId,
        },
      })

      this.sending = false
    },
  },
}
</script>
