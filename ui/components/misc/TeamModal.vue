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
        <v-container py-0>
          <v-form ref="form" v-model="valid">
            <div>
              Comming soon!!
            </div>
          </v-form>
        </v-container>
      </v-card-text>

      <template v-if="originDataChanged()">
        <v-divider />
        <origin-data-changed-warning :updated-at="team.updatedAt" />
      </template>

      <v-divider />
      <action-buttons
        :sending="sending"
        :valid="valid"
        :is-new="isNew"
        :edited="edited"
        @click-submit="submit"
        @click-cancel="close"
        @click-reset="reset"
      />
    </v-card>
  </v-dialog>
</template>
<script>
import orm from '~/orm'

import ApplyModalFields from '~/components/misc/ApplyModal/ApplyModalFields'
import ApplyModalCommons from '~/components/misc/ApplyModal/ApplyModalCommons'
import ActionButtons from '~/components/misc/ApplyModal/ActionButtons'

const fields = {
  role: '',
  name: '',
  organization: '',
  number: 0,
  color: null
}

const fieldKeys = Object.keys(fields)

export default {
  name: 'TeamModal',
  components: {
    ActionButtons
  },
  mixins: [ApplyModalCommons, ApplyModalFields],
  props: {
    // mixinしたモジュールから必要な値がmixinされる
    team: {
      type: Object,
      default: null
    }
  },
  data() {
    return {
      // mixinしたモジュールから必要な値がmixinされる
      descriptionPlaceholder: '記述可能\n\n空も可'
    }
  },
  computed: {
    modalTitle() {
      return this.isNew ? 'チーム追加' : 'チーム編集'
    },
    teams() {
      return this.sortByOrder(orm.Team.query().all())
    }
  },
  watch: {
    // ApplyModalFieldsに必要
    // 各フィールドの変更をトラッキング
    ...fieldKeys.reduce((obj, field) => {
      obj[field] = function(value) {
        this.setStorage(field, value)
      }
      return obj
    }, {})
  },
  fetch() {
    orm.Team.eagerFetch({}, [])
  },
  methods: {
    // -- ApplyModalFieldsに必要なメソッド郡 --
    item() {
      return this.team
    },
    storageKeyPrefix() {
      return 'teamModal'
    },
    storageKeyUniqueField() {
      return 'number'
    },
    fields() {
      return fields
    },
    fieldKeys() {
      return fieldKeys
    },
    // -- END --

    async submit() {
      if (!this.valid || this.sending) {
        return
      }

      this.sending = true

      await orm.Mutation.applyTeam({
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
