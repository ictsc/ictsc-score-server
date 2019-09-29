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

import ActionButtons from '~/components/misc/ApplyModal/ActionButtons'
import ApplyModalCommons from '~/components/misc/ApplyModal/ApplyModalCommons'
import ApplyModalFields from '~/components/misc/ApplyModal/ApplyModalFields'
import CodeTextField from '~/components/misc/ApplyModal/CodeTextField'
import MarkdownTextArea from '~/components/commons/MarkdownTextArea'
import OrderSlider from '~/components/misc/ApplyModal/OrderSlider'
import OriginDataChangedWarning from '~/components/misc/ApplyModal/OriginDataChangedWarning'
import TitleTextField from '~/components/misc/ApplyModal/TitleTextField'

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
    OrderSlider,
    OriginDataChangedWarning,
    TitleTextField
  },
  mixins: [ApplyModalCommons, ApplyModalFields],
  props: {
    // mixinしたモジュールから必要な値がmixinされる
    category: {
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
  methods: {
    // -- ApplyModalFieldsに必要なメソッド郡 --
    item() {
      return this.category
    },
    storageKeyPrefix() {
      return 'categoryModal'
    },
    storageKeyUniqueField() {
      return 'code'
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

      await orm.Mutation.applyCategory({
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
