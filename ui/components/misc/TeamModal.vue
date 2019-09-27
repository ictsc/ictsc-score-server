<template>
  <v-dialog
    v-model="internalValue"
    :persistent="sending"
    max-width="70em"
    scrollable
  >
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
  mixins: [ApplyModalFields],
  props: {
    // v-model
    value: {
      type: Boolean,
      required: true
    },
    team: {
      type: Object,
      default: null
    }
    // ApplyModalFieldsでisNewがmixinされる
  },
  data() {
    return {
      // ApplyModalFieldsでapplyTeamに必要な値がmixinされる
      internalValue: this.value,
      valid: false,
      sending: false,
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
    }, {}),

    internalValue() {
      this.$emit('input', this.internalValue)
    }
  },
  fetch() {
    orm.Team.eagerFetch({}, [])
  },
  mounted() {
    this.validate()
  },
  methods: {
    // ApplyModalFieldsに必要
    item() {
      return this.team
    },
    // ApplyModalFieldsに必要
    storageKeyPrefix() {
      return 'teamModal'
    },
    // ApplyModalFieldsに必要
    fields() {
      return fields
    },
    // ApplyModalFieldsに必要
    fieldKeys() {
      return fieldKeys
    },
    close() {
      this.internalValue = false
    },
    validate() {
      this.$refs.form.validate()
    },
    async submit() {
      if (!this.valid || this.sending) {
        return
      }

      this.sending = true

      await orm.Team.applyTeam({
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
