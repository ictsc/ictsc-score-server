<template>
  <v-dialog
    v-model="internalValue"
    :persistent="sending"
    max-width="70em"
    scrollable
  >
    <template v-slot:activator="{}">
      <slot name="activator" :on="open" />
    </template>

    <v-card>
      <v-card-title>
        <span>{{ modalTitle }}</span>
      </v-card-title>

      <v-divider />

      <v-card-text>
        <v-container class="pb-0">
          <v-form ref="form" v-model="valid">
            <v-text-field
              :value="problem.displayTitle"
              disabled
              label="問題"
              append-icon="mdi-lock"
            />

            <!--
            <v-overflow-btn
              v-model="problemCode"
              :readonly="sending"
              :disabled="!isNew"
              :items="problems"
              :rules="requiredRules"
              placeholder="問題"
              item-text="displayTitle"
              item-value="code"
              auto-select-first
              editable
              dense
              class="mt-0 pb-3"
            />
            -->

            <label class="caption">チーム</label>
            <v-overflow-btn
              v-model="teamNumber"
              :readonly="sending"
              :disabled="!isNew"
              :items="teams"
              :rules="teamUniqueRules"
              item-text="displayName"
              item-value="number"
              auto-select-first
              editable
              dense
              class="mt-0 pb-3"
            />

            <v-text-field
              v-model="name"
              :readonly="sending"
              :disabled="!isNew"
              :rules="uniqueRules"
              label="名前"
            />

            <v-text-field
              v-model="service"
              :readonly="sending"
              :disabled="!isNew"
              :rules="uniqueRules"
              placeholder="SSH, VNC, Telnet, etc..."
              label="種類"
            />

            <!-- 本戦用 一時的に固定 -->
            <v-text-field
              v-model="status"
              :readonly="sending"
              :rules="requiredRules"
              disabled
              label="状態"
              append-icon="mdi-lock"
            />

            <v-text-field
              v-model="host"
              :readonly="sending"
              label="ホスト名"
              placehoder="ホスト名, IPアドレス, etc..."
            />

            <number-text-field
              v-model="port"
              :readonly="sending"
              label="ポート番号"
              only-integer
              class="pt-4"
            />

            <v-text-field
              v-model="user"
              :readonly="sending"
              label="ユーザー名"
            />

            <v-text-field
              v-model="password"
              :readonly="sending"
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
import ApplyModalCommons from '~/components/misc/ApplyModal/ApplyModalCommons'
import ApplyModalFields from '~/components/misc/ApplyModal/ApplyModalFields'
import ConflictWarning from '~/components/misc/ApplyModal/ConflictWarning'

import MarkdownTextArea from '~/components/commons/MarkdownTextArea'
import NumberTextField from '~/components/commons/NumberTextField'

/*
  TODO: penvはteamNumberとproblemCodeを持たないからnullになる

  updatedでは問題とチームを変更できない
    削除して似たのを作り直すしかない
    編集できるのは
  unique name team problem
*/

export default {
  name: 'EnvironmentModal',
  components: {
    ActionButtons,
    ConflictWarning,
    MarkdownTextArea,
    NumberTextField
  },
  mixins: [ApplyModalCommons, ApplyModalFields],
  props: {
    problem: {
      type: Object,
      required: true
    }
  },
  data() {
    const requiredRule = v => !!v || '必須'
    return {
      // mixinしたモジュールから必要な値がmixinされる
      requiredRules: [requiredRule],
      uniqueRules: [
        requiredRule,
        _v => !this.isNew || this.isUnique() || '重複'
      ],
      teamUniqueRules: [
        v => v !== undefined || '必須',
        _v => !this.isNew || this.isUnique() || '重複'
      ]
    }
  },
  computed: {
    modalTitle() {
      return this.isNew ? '問題環境追加' : '問題環境編集'
    },
    teams() {
      return this.unshiftDummy(this.sortByNumber(orm.Team.all()))
    },
    problems() {
      return this.sortByOrder(
        orm.Problem.query()
          .with('body')
          .all()
      )
    },
    team() {
      return orm.Team.all().find(t => t.number === this.teamNumber)
    },
    teamId() {
      return this.team && this.team.id
    }
  },
  watch: {
    // ApplyModalFieldsに必要
    // 各フィールドの変更をトラッキング
    ...orm.ProblemEnvironment.mutationFieldKeys().reduce((obj, field) => {
      obj[field] = function(value) {
        this.setStorage(field, value)

        // composit unique keyのためにバリデーションを再発動させる必要がある
        this.validate()
      }
      return obj
    }, {})
  },
  methods: {
    // -- ApplyModalFieldsに必要なメソッド郡 --
    storageKeyPrefix() {
      return 'environmentModal'
    },
    storageKeyUniqueField() {
      return 'id'
    },
    fields() {
      return orm.ProblemEnvironment.mutationFields()
    },
    fieldKeys() {
      return orm.ProblemEnvironment.mutationFieldKeys()
    },
    async fetchSelf() {
      await orm.Queries.problemEnvironment(this.item.id)
    },
    // -- END --

    isUnique() {
      return (
        orm.ProblemEnvironment.all().filter(
          pe =>
            pe.problemId === this.problem.id &&
            pe.teamId === this.teamId &&
            pe.name === this.name &&
            pe.service === this.service
        ).length === 0
      )
    },
    unshiftDummy(items) {
      items.unshift({ displayName: '共通', number: null })
      return items
    },
    // 最初に開いた時に実行される
    openedAtFirst() {
      // チーム選択用
      orm.Queries.teams()
    },
    async submit(force) {
      this.sending = true

      if (!this.isNew && (await this.checkConflict()) && !force) {
        this.sending = false
        return
      }

      const params = { ...this }
      params.problemCode = this.problem.code

      await orm.Mutations.applyProblemEnvironment({
        action: this.modalTitle,
        resolve: () => {
          this.reset()
          this.close()
        },
        params
      })

      this.sending = false
    }
  }
}
</script>