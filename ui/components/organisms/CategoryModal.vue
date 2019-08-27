<template>
  <v-dialog
    :value="value"
    :persistent="sending"
    max-width="70em"
    scrollable
    @input="close"
  >
    <v-card>
      <v-card-title>
        <span>{{ modalTitle }}</span>
      </v-card-title>

      <v-divider />
      <v-card-text>
        <v-container py-0>
          <v-form ref="form" v-model="valid">
            <title-text-field v-model="title" :readonly="sending" />

            <code-text-field
              v-model="code"
              :readonly="sending"
              :is-new="isNew"
              :items="categories"
            />

            <order-slider
              v-model="order"
              :readonly="sending"
              :items="categories"
              :self-id="isNew ? null : category.id"
              title-param="title"
              label="順序"
              class="mt-2"
            />

            <markdown-text-area
              v-model="description"
              :readonly="sending"
              :placeholder="descriptionPlaceholder"
              label="説明"
              preview-width="70em"
              allow-empty
              @submit="submit"
            />
          </v-form>
        </v-container>
      </v-card-text>

      <template v-if="originDataChanged()">
        <v-divider />
        <origin-data-changed-warning :updated-at="category.updatedAt" />
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
import MarkdownTextArea from '~/components/molecules/MarkdownTextArea'

import ApplyModalFields from '~/components/molecules/ApplyModal/ApplyModalFields'
import ActionButtons from '~/components/molecules/ApplyModal/ActionButtons'
import OrderSlider from '~/components/molecules/ApplyModal/OrderSlider'
import OriginDataChangedWarning from '~/components/molecules/ApplyModal/OriginDataChangedWarning'
import TitleTextField from '~/components/molecules/ApplyModal/TitleTextField'
import CodeTextField from '~/components/molecules/ApplyModal/CodeTextField'

const fields = {
  code: '',
  title: '',
  description: '',
  order: 0
}

const fieldKeys = Object.keys(fields)

export default {
  name: 'CategoryModal',
  components: {
    ActionButtons,
    CodeTextField,
    MarkdownTextArea,
    OriginDataChangedWarning,
    OrderSlider,
    TitleTextField
  },
  mixins: [ApplyModalFields],
  props: {
    // v-model
    value: {
      type: Boolean,
      required: true
    },
    category: {
      type: Object,
      default: null
    }
    // ApplyModalFieldsでisNewがmixinされる
  },
  data() {
    return {
      // ApplyModalFieldsでapplyCategoryに必要な値がmixinされる
      valid: false,
      sending: false,
      descriptionPlaceholder: '記述可能\n\n空も可'
    }
  },
  computed: {
    modalTitle() {
      return this.isNew ? 'カテゴリ追加' : 'カテゴリ編集'
    },
    categories() {
      return this.sortByOrder(orm.Category.query().all())
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
    orm.Category.eagerFetch({}, [])
  },
  mounted() {
    this.validate()
  },
  methods: {
    // ApplyModalFieldsに必要
    item() {
      return this.category
    },
    // ApplyModalFieldsに必要
    storageKeyPrefix() {
      return 'categoryModal'
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
      this.$emit('input', false)
    },
    validate() {
      this.$refs.form.validate()
    },
    async submit() {
      if (!this.valid || this.sending) {
        return
      }

      this.sending = true

      await orm.Category.applyCategory({
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
