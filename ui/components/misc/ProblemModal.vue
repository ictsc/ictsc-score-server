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
            <title-text-field v-model="title" :readonly="sending" />

            <code-text-field
              v-model="code"
              :readonly="sending"
              :is-new="isNew"
              :items="problems"
            />

            <v-text-field v-model="writer" :readonly="sending" label="作問者" />

            <v-select
              v-model="categoryCode"
              :readonly="sending"
              :items="categories"
              :hint="categoryCode"
              clearable
              persistent-hint
              item-text="title"
              item-value="code"
              label="カテゴリ"
              class="pb-3"
            />

            <order-slider
              v-model="order"
              :readonly="sending"
              :items="problemsOnlySameCategory"
              :self-id="isNew ? null : problem.id"
              title-param="title"
              label="順序"
            />

            <v-select
              v-model="previousProblemCode"
              :readonly="sending"
              :items="problemsSortForPreviousProblem"
              :hint="previousProblemCode"
              clearable
              persistent-hint
              item-text="title"
              item-value="code"
              label="依存問題"
              class="pb-3"
            />

            <!-- TODO: tooltip: ctf方式の説明 -->
            <label class="caption">開放状況</label>
            <v-switch
              v-model="teamIsolate"
              :readonly="sending"
              :label="`チーム間${teamIsolate ? '分離' : '共有'}`"
              color="primary"
              class="mt-0"
            />

            <!-- TODO: datetime picker openAtBegin openAtEnd -->

            <number-text-field
              v-model="perfectPoint"
              :readonly="sending"
              :rules="perfectPointRules"
              label="満点"
              class="mb-4"
            />

            <!-- TODO: tooltips 突破基準の説明 -->
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

            <!-- TODO: tooltips: これの説明 -->
            <markdown-text-area
              v-model="secretText"
              :readonly="sending"
              placeholder="Markdownで記述可能"
              label="運営用メモ"
              preview-width="70em"
              class="pt-4"
              allow-empty
              @submit="submit"
            />

            <markdown-text-area
              v-model="text"
              :readonly="sending"
              placeholder="Markdownで記述可能"
              label="問題文"
              preview-width="70em"
              class="pt-4"
              @submit="submit"
            />
          </v-form>
        </v-container>
      </v-card-text>

      <template v-if="originDataChanged()">
        <v-divider />
        <origin-data-changed-warning :updated-at="problem.updatedAt" />
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
import MarkdownTextArea from '~/components/commons/MarkdownTextArea'
import EditableSlider from '~/components/commons/EditableSlider'
import NewCandidates from '~/components/misc/ProblemModal/NewCandidates'

import ApplyModalFields from '~/components/misc/ApplyModal/ApplyModalFields'
import ActionButtons from '~/components/misc/ApplyModal/ActionButtons'
import NumberTextField from '~/components/commons/NumberTextField'
import OrderSlider from '~/components/misc/ApplyModal/OrderSlider'
import OriginDataChangedWarning from '~/components/misc/ApplyModal/OriginDataChangedWarning'
import TitleTextField from '~/components/misc/ApplyModal/TitleTextField'
import CodeTextField from '~/components/misc/ApplyModal/CodeTextField'

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

export default {
  name: 'ProblemModal',
  components: {
    ActionButtons,
    CodeTextField,
    EditableSlider,
    MarkdownTextArea,
    NumberTextField,
    NewCandidates,
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
    problem: {
      type: Object,
      default: null
    }
    // ApplyModalFieldsでisNewがmixinされる
  },
  data() {
    return {
      // ApplyModalFieldsでapplyproblemに必要な値がmixinされる
      internalValue: this.value,
      valid: false,
      sending: false,
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
      ]
    }
  },
  computed: {
    modalTitle() {
      return this.isNew ? '問題追加' : '問題編集'
    },
    categories() {
      return this.sortByOrder(orm.Category.query().all())
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
    problemsOnlySameCategory() {
      if (!this.categoryCode) {
        return this.problems
      }

      return this.problems.filter(
        o => o.categoryId === this.selectedCategory.id
      )
    },
    // 同一カテゴリを上に持ってくる
    problemsSortForPreviousProblem() {
      if (!this.categoryCode) {
        return this.problems
      }

      // 同一カテゴリの自分以外
      const same = this.problemsOnlySameCategory.filter(
        v => this.isNew || v.id !== this.problem.id
      )

      // 違うカテゴリの自分以外
      const diff = this.problems.filter(
        v =>
          v.categoryId !== this.selectedCategory.id &&
          (this.isNew || v.id !== this.problem.id)
      )

      // dividerで区切りを入れる
      return same.concat([{ divider: true }], diff)
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
  mounted() {
    // 最初に開いた時に読み直す
    // カテゴリに所属していない問題も取得できる
    orm.Problem.eagerFetch({}, [])
    orm.Category.eagerFetch({}, [])
    this.validate()
  },
  methods: {
    // ApplyModalFieldsに必要
    item() {
      return this.problem
    },
    // ApplyModalFieldsに必要
    storageKeyPrefix() {
      return 'problemModal'
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

      // textboxなら空にしないとバリデーションエラーになる
      if (this.mode === 'textbox') {
        this.candidates = []
        this.corrects = []
      }

      // nullは可だが空は不可
      if (this.writer === '') {
        this.writer = null
      }

      this.perfectPoint = parseInt(this.perfectPoint)

      await orm.Mutation.applyProblem({
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
