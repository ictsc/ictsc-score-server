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
              :self-id="isNew ? null : item.id"
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
import CodeTextField from '~/components/misc/ApplyModal/CodeTextField'
import MarkdownTextArea from '~/components/commons/MarkdownTextArea'
import OrderSlider from '~/components/misc/ApplyModal/OrderSlider'
import ConflictWarning from '~/components/misc/ApplyModal/ConflictWarning'
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
    ConflictWarning,
    TitleTextField
  },
  mixins: [ApplyModalCommons, ApplyModalFields],
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
    orm.Queries.categories()
  },
  methods: {
    // -- ApplyModalFieldsに必要なメソッド郡 --
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
    async fetchSelf() {
      await orm.Queries.category(this.item.id)
    },
    // -- END --

    async submit(force) {
      this.sending = true

      if (!this.isNew && (await this.checkConlict()) && !force) {
        this.sending = false
        return
      }

      await orm.Mutations.applyCategory({
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
