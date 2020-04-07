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

            <v-switch
              v-model="resettable"
              :readonly="sending"
              :label="`リセット${resettable ? '可能' : '不可能'}`"
              color="primary"
              class="mt-0"
            />

            <v-text-field
              v-model="genre"
              :readonly="sending"
              label="ジャンル"
              placeholder="コンテナ, ルーティング, ウェブ, etc..."
            />

            <label class="caption">カテゴリ</label>
            <v-overflow-btn
              v-model="categoryCode"
              :readonly="sending"
              :items="categories"
              :hint="categoryCode"
              persistent-hint
              item-text="displayTitle"
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
              title-param="displayTitle"
              label="順序"
            />

            <label class="caption">依存問題</label>
            <v-overflow-btn
              v-model="previousProblemCode"
              :readonly="sending"
              :items="previousProblemCandidates"
              :hint="previousProblemCode"
              persistent-hint
              item-text="displayTitle"
              item-value="code"
              auto-select-first
              editable
              dense
              class="mt-0 pb-3"
            />

            <label class="caption">依存問題: 開放状況</label>
            <v-switch
              v-model="teamIsolate"
              :readonly="sending"
              :label="`チーム間${teamIsolate ? '分離' : '共有'}`"
              color="primary"
              class="mt-0"
            />

            <v-switch
              :input-value="showOpenAtPickers"
              :readonly="sending"
              :label="`公開時間 ${showOpenAtPickers ? '制限' : '無制限'}`"
              color="primary"
              class="mt-0"
              @change="showOpenAtPickersClicked"
            />

            <date-time-picker
              v-if="openAtBegin"
              v-model="openAtBegin"
              :readonly="sending"
              label="開始時間"
            />

            <date-time-picker
              v-if="openAtEnd"
              v-model="openAtEnd"
              :readonly="sending"
              label="終了時間"
            />

            <number-text-field
              v-model="perfectPoint"
              :readonly="sending"
              :rules="perfectPointRules"
              label="満点"
              class="mt-4 mb-4"
              only-integer
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
              only-integer
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
import ConflictWarning from '~/components/misc/ApplyModal/ConflictWarning'

import CodeTextField from '~/components/misc/ApplyModal/CodeTextField'
import DateTimePicker from '~/components/commons/DateTimePicker'
import EditableSlider from '~/components/commons/EditableSlider'
import MarkdownTextArea from '~/components/commons/MarkdownTextArea'
import NewCandidates from '~/components/misc/ProblemModal/NewCandidates'
import NumberTextField from '~/components/commons/NumberTextField'
import OrderSlider from '~/components/misc/ApplyModal/OrderSlider'
import TitleTextField from '~/components/misc/ApplyModal/TitleTextField'

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
    TitleTextField,
  },
  mixins: [ApplyModalCommons, ApplyModalFields],
  data() {
    return {
      // mixinしたモジュールから必要な値がmixinされる
      requiredRules: [(v) => !!v || '必須'],
      perfectPointRules: [(v) => parseInt(v) >= 0 || '0以上'],
      solvedCriterionRules: [
        (v) => parseInt(v) >= 50 || '50%以上',
        (v) => parseInt(v) <= 100 || '100%以下',
      ],
      secretTextPlaceholder,
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
      return this.sortByOrder(orm.Problem.query().with('body').all())
    },
    selectedCategory() {
      if (!this.categoryCode) {
        return null
      }

      return this.categories.find((o) => o.code === this.categoryCode)
    },
    hasCategory() {
      return this.selectedCategory && this.selectedCategory.code !== null
    },
    problemsOnlySameCategory() {
      if (!this.hasCategory) {
        return this.problems
      }

      return this.problems.filter(
        (o) => o.categoryId === this.selectedCategory.id
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
        (v) => v.categoryId !== this.selectedCategory.id
      )

      // dividerで区切りを入れる
      return this.unshiftDummy(same.concat([{ divider: true }], diff))
    },
    showOpenAtPickers() {
      return this.openAtBegin !== null && this.openAtEnd !== null
    },
  },
  watch: {
    // ApplyModalFieldsに必要
    // 各フィールドの変更をトラッキング
    ...orm.Problem.mutationFieldKeys().reduce((obj, field) => {
      obj[field] = function (value) {
        this.setStorage(field, value)
      }
      return obj
    }, {}),
  },
  methods: {
    // -- ApplyModalFieldsに必要なメソッド郡 --
    storageKeyUniqueField() {
      return 'code'
    },
    fields() {
      return orm.Problem.mutationFields()
    },
    fieldKeys() {
      return orm.Problem.mutationFieldKeys()
    },
    // -- END --

    unshiftDummy(items) {
      items.unshift({ displayTitle: 'なし', code: null })
      return items
    },
    rejectSelf(problems) {
      return this.isNew
        ? problems
        : problems.filter((v) => v.id !== this.item.id)
    },
    showOpenAtPickersClicked(value) {
      const now = value ? $nuxt.formatDateTime($nuxt.$moment(0)) : null
      this.openAtBegin = now
      this.openAtEnd = now
    },
    // 最初に開いた時に実行される
    openedAtFirst() {
      // カテゴリに属していない問題や問題に属していないカテゴリも取得する
      orm.Queries.problems()
      orm.Queries.categories()
    },
    async submit(force) {
      this.sending = true

      if (!this.isNew && this.conflicted && !force) {
        this.sending = false
        return
      }

      // textboxなら空にしないとバリデーションエラーになる
      if (this.mode === 'textbox') {
        this.candidates = []
        this.corrects = []
      }

      await orm.Mutations.applyProblem({
        action: this.modalTitle,
        resolve: () => {
          this.reset()
          this.close()
        },
        // 無駄なパラメータを渡しても問題ない
        params: { ...this },
      })

      this.sending = false
    },
  },
}
</script>
