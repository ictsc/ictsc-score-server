<template>
  <v-dialog
    v-model="internalValue"
    :persistent="sending"
    max-width="70em"
    scrollable
  >
    <template v-slot:activator="{ on }">
      <slot name="activator" :on="on" />
    </template>

    <v-card>
      <v-card-title>
        <span>{{ modalTitle }}</span>
      </v-card-title>

      <v-divider />
      <v-card-text>
        <v-container pb-0>
          <v-form ref="form" v-model="valid">
            <!-- lock -->
            <label class="caption">権限</label>
            <v-overflow-btn
              v-model="role"
              :readonly="sending"
              :items="roles"
              :disabled="!isNew"
              label="権限"
              :rules="requiredRules"
              return-object
              auto-select-first
              editable
              dense
              class="mt-0 pb-2"
            />

            <number-text-field
              v-model="number"
              :readonly="sending"
              :disabled="!isNew"
              :rules="isNew ? numberRules : []"
              label="チーム番号"
              only-integer
              class="pt-4"
            />

            <v-text-field
              v-model="name"
              :readonly="sending"
              :rules="nameRules"
              label="チーム名"
            />

            <v-text-field
              v-model="organization"
              :readonly="sending"
              label="組織"
            />

            <v-color-picker v-model="color" hide-mode-switch flat />

            <v-switch
              v-model="beginner"
              :readonly="sending"
              label="解答サポート"
              color="primary"
              class="mt-0"
            />

            <v-text-field
              v-model="password"
              :readonly="sending"
              :rules="isNew ? requiredRules : []"
              :placeholder="isNew ? '' : '空なら現状維持'"
              label="パスワード"
            />

            <markdown-text-area
              v-model="secretText"
              :readonly="sending"
              placeholder="Markdown"
              label="運営用メモ"
              class="pt-4"
              allow-empty
            />
          </v-form>
        </v-container>
      </v-card-text>

      <template v-if="conflicted">
        <v-divider />
        <conflict-warning
          :latest-updated-at="item.updatedAtSimple"
          :conflict-fields="conflictFields"
        />
      </template>

      <v-divider />
      <action-buttons
        :sending="sending"
        :valid="valid"
        :is-new="isNew"
        :edited="edited"
        :conflicted="conflicted"
        @click-submit="submit"
        @click-cancel="close"
        @click-reset="reset"
      />
    </v-card>
  </v-dialog>
</template>
<script>
import orm from '~/orm'

import ActionButtons from '~/components/misc/ApplyModal/ActionButtons'
import ApplyModalFields from '~/components/misc/ApplyModal/ApplyModalFields'
import ApplyModalCommons from '~/components/misc/ApplyModal/ApplyModalCommons'
import ConflictWarning from '~/components/misc/ApplyModal/ConflictWarning'

import MarkdownTextArea from '~/components/commons/MarkdownTextArea'
import NumberTextField from '~/components/commons/NumberTextField'

export default {
  name: 'TeamModal',
  components: {
    ActionButtons,
    ConflictWarning,
    MarkdownTextArea,
    NumberTextField
  },
  mixins: [ApplyModalCommons, ApplyModalFields],
  data() {
    const requiredRule = v => !!v || '必須'

    return {
      // mixinしたモジュールから必要な値がmixinされる
      sending: false,
      roles: ['staff', 'audience', 'player'],
      requiredRules: [requiredRule],
      nameRules: [requiredRule, v => this.isUniqueName(v) || '重複'],
      numberRules: [v => this.isUniqueNumber(v) || '重複']
    }
  },
  computed: {
    modalTitle() {
      return this.isNew ? 'チーム追加' : 'チーム編集'
    }
  },
  watch: {
    // ApplyModalFieldsに必要
    // 各フィールドの変更をトラッキング
    ...orm.Team.mutationFieldKeys().reduce((obj, field) => {
      obj[field] = function(value) {
        this.setStorage(field, value)
      }
      return obj
    }, {})
  },
  methods: {
    // -- ApplyModalFieldsに必要なメソッド郡 --
    storageKeyPrefix() {
      return 'teamModal'
    },
    storageKeyUniqueField() {
      return 'number'
    },
    fields() {
      return orm.Team.mutationFields()
    },
    fieldKeys() {
      return orm.Team.mutationFieldKeys()
    },
    async fetchSelf() {
      await orm.Queries.team(this.item.id)
    },
    // -- END --

    // 既に全チームがfetchされている必要がある
    isUniqueName(name) {
      const sameNameTeams = orm.Team.query()
        .where('name', name)
        .get()

      switch (sameNameTeams.length) {
        case 0:
          return true
        case 1:
          return this.isNew ? false : sameNameTeams[0].number === this.number
        default:
          // そもそもユニーク制約かかっているので2以上はありえない
          console.error('same name teams count is over 2', sameNameTeams)
      }
    },
    isUniqueNumber(number) {
      return (
        orm.Team.query()
          .where('number', number)
          .get().length === 0
      )
    },
    async submit(force) {
      this.sending = true

      if (!this.isNew && (await this.checkConflict()) && !force) {
        this.sending = false
        return
      }

      // 空ならnullにして現状維持にする
      if (this.password === '') {
        this.password = null
      }

      await orm.Mutations.applyTeam({
        action: this.modalTitle,
        resolve: () => {
          this.reset()
          this.close()
        },
        // 無駄なパラメータを渡しても問題ない
        params: { ...this }
      })

      this.sending = false
    }
  }
}
</script>
