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
              :items="problems"
            />

            <v-text-field v-model="writer" :readonly="sending" label="作問者" />

            <label class="caption">カテゴリ</label>
            <v-overflow-btn
              v-model="categoryCode"
              :readonly="sending"
              :items="categories"
              :hint="categoryCode"
              persistent-hint
              item-text="title"
              item-value="code"
              auto-select-first
              editable
              dense
              class="mt-0 pb-3"
            />

            <order-slider
              v-model="order"
              :readonly="sending"
              :items="problemsOnlySameCategory"
              :self-id="isNew ? null : item.id"
              title-param="title"
              label="順序"
            />

            <label class="caption">依存問題</label>
            <v-overflow-btn
              v-model="previousProblemCode"
              :readonly="sending"
              :items="previousProblemCandidates"
              :hint="previousProblemCode"
              persistent-hint
              item-text="title"
              item-value="code"
              auto-select-first
              editable
              dense
              class="mt-0 pb-3"
            />

            <label class="caption">開放状況</label>
            <v-switch
              v-model="teamIsolate"
              :readonly="sending"
              :label="`チーム間${teamIsolate ? '分離' : '共有'}`"
              color="primary"
              class="mt-0"
            />

            <v-switch
              v-model="enableOpenAt"
              :readonly="sending"
              label="公開時間指定"
              color="primary"
              class="mt-0"
            />

            <date-time-picker
              v-if="enableOpenAt"
              v-model="openAtBegin"
              :readonly="sending"
            />
            <date-time-picker
              v-if="enableOpenAt"
              v-model="openAtEnd"
              :readonly="sending"
            />

            <number-text-field
              v-model="perfectPoint"
              :readonly="sending"
              :rules="perfectPointRules"
              label="満点"
              class="mb-4"
            />

            <editable-slider
              v-model="solvedCriterion"
              :readonly="sending"
              :max="100"
              :min="50"
              :step="5"
              :rules="solvedCriterionRules"
              suffix="%"
              label="突破基準"
            />

            <label class="caption">解答方法</label>
            <v-radio-group
              v-model="mode"
              :readonly="sending"
              mandatory
              row
              class="mt-0"
            >
              <v-radio
                label="テキストボックス"
                value="textbox"
                color="primary"
              />
              <v-radio
                label="ラジオボタン"
                value="radio_button"
                color="primary"
              />
              <v-radio
                label="チェックボックス"
                value="checkbox"
                color="primary"
              />
            </v-radio-group>

            <template v-if="mode !== 'textbox'">
              <label class="caption">選択肢</label>
              <new-candidates
                :mode="mode"
                :readonly="sending"
                :candidates.sync="candidates"
                :corrects.sync="corrects"
                class="ml-8 pt-0 mb-4"
              />
            </template>

            <markdown-text-area
              v-model="secretText"
              :readonly="sending"
              :placeholder="secretTextPlaceholder"
              label="運営用メモ"
              class="pt-4"
              allow-empty
            />

            <markdown-text-area
              v-model="text"
              :readonly="sending"
              placeholder="Markdownで記述可能"
              label="問題文"
              class="pt-4"
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
import DateTimePicker from '~/components/commons/DateTimePicker'
import EditableSlider from '~/components/commons/EditableSlider'
import MarkdownTextArea from '~/components/commons/MarkdownTextArea'
import NewCandidates from '~/components/misc/ProblemModal/NewCandidates'
import NumberTextField from '~/components/commons/NumberTextField'
import OrderSlider from '~/components/misc/ApplyModal/OrderSlider'
import ConflictWarning from '~/components/misc/ApplyModal/ConflictWarning'
import TitleTextField from '~/components/misc/ApplyModal/TitleTextField'

const fields = {
  title: '',
  code: '',
  writer: null,
  categoryCode: null,
  order: 0,
  previousProblemCode: null,
  teamIsolate: false,
  openAtBegin: null,
  openAtEnd: null,
  perfectPoint: 0,
  solvedCriterion: 100,
  secretText: '',
  mode: 'textbox',
  candidates: [],
  corrects: [],
  text: ''
}

const fieldKeys = Object.keys(fields)

const secretTextPlaceholder = `Markdownで記述可能
採点基準などを記載`

export default {
  name: 'ProblemModal',
  components: {
    ActionButtons,
    CodeTextField,
    DateTimePicker,
    EditableSlider,
    MarkdownTextArea,
    NewCandidates,
    NumberTextField,
    OrderSlider,
    ConflictWarning,
    TitleTextField
  },
  mixins: [ApplyModalCommons, ApplyModalFields],
  data() {
    return {
      // mixinしたモジュールから必要な値がmixinされる
      requiredRules: [v => !!v || '必須'],
      perfectPointRules: [
        v => !['', null, undefined].includes(v) || '必須',
        v => !Number.isNaN(parseInt(v)) || '数値',
        v => parseInt(v) >= 0 || '0以上'
      ],
      solvedCriterionRules: [
        v => !['', null, undefined].includes(v) || '必須',
        v => !Number.isNaN(parseInt(v)) || '数値',
        v => parseInt(v) >= 50 || '50%以上',
        v => parseInt(v) <= 100 || '100%以下'
      ],
      secretTextPlaceholder,
      enableOpenAt: !!this.openAtBegin || !!this.openAtEnd
    }
  },
  computed: {
    modalTitle() {
      return this.isNew ? '問題追加' : '問題編集'
    },
    categories() {
      return this.unshiftDummy(this.sortByOrder(orm.Category.all()))
    },
    problems() {
      return this.sortByOrder(
        orm.Problem.query()
          .with('body')
          .all()
      )
    },
    selectedCategory() {
      if (!this.categoryCode) {
        return null
      }

      return this.categories.find(o => o.code === this.categoryCode)
    },
    hasCategory() {
      return this.selectedCategory && this.selectedCategory.code !== null
    },
    problemsOnlySameCategory() {
      if (!this.hasCategory) {
        return this.problems
      }

      return this.problems.filter(
        o => o.categoryId === this.selectedCategory.id
      )
    },
    // 同一カテゴリを上に持ってくる
    previousProblemCandidates() {
      // 自分以外の問題
      const otherProblems = this.rejectSelf(this.problems)

      if (!this.hasCategory) {
        return this.unshiftDummy(otherProblems)
      }

      // 同一カテゴリの自分以外
      const same = this.rejectSelf(this.problemsOnlySameCategory)

      // 他のカテゴリの自分以外
      const diff = otherProblems.filter(
        v => v.categoryId !== this.selectedCategory.id
      )

      // dividerで区切りを入れる
      return this.unshiftDummy(same.concat([{ divider: true }], diff))
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

    // openAtだけ特殊
    openAtBegin: {
      immediate: true,
      handler(value) {
        this.setStorage('openAtBegin', value)
        this.enableOpenAt = !!value || this.openAtEnd
      }
    },
    openAtEnd: {
      immediate: true,
      handler(value) {
        this.setStorage('openAtEnd', value)
        this.enableOpenAt = !!value || this.openAtBegin
      }
    },

    enableOpenAt(value) {
      if (!value) {
        this.openAtBegin = null
        this.openAtEnd = null
      }
    }
  },
  methods: {
    // -- ApplyModalFieldsに必要なメソッド郡 --
    storageKeyPrefix() {
      return 'problemModal'
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
      await orm.Queries.problemCategory(this.item.id)
    },
    // -- END --

    unshiftDummy(items) {
      items.unshift({ title: 'なし', code: null })
      return items
    },
    rejectSelf(problems) {
      return this.isNew ? problems : problems.filter(v => v.id !== this.item.id)
    },
    // 最初に開いた時に実行される
    opendAtFirst() {
      // カテゴリに属していない問題や問題に属していないカテゴリも取得する
      orm.Queries.problems()
      orm.Queries.categories()
    },
    async submit(force) {
      this.sending = true

      if (!this.isNew && (await this.checkConflict()) && !force) {
        this.sending = false
        return
      }

      // textboxなら空にしないとバリデーションエラーになる
      if (this.mode === 'textbox') {
        this.candidates = []
        this.corrects = []
      }

      // nullは可だが空は不可
      if (this.writer === '') {
        this.writer = null
      }

      await orm.Mutations.applyProblem({
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
