<template>
  <v-container>
    <!-- 選択肢Nとその要素 -->
    <div
      v-for="(candidateGroup, groupIndex) in candidates"
      :key="groupIndex"
      class="mb-4 ml-4"
    >
      <!-- 選択肢Nと上下削除ボタン -->
      <v-row align="center">
        <label class="mr-1" :class="{ 'error--text': hasError(groupIndex) }">
          {{ '選択肢' + (groupIndex + 1) }}
        </label>

        <icon-button
          :disabled="readonly"
          icon="mdi-shuffle-variant"
          @click="shuffleCandidateItem(groupIndex)"
        />
        <icon-button
          :disabled="readonly"
          icon="mdi-arrow-up"
          class="mb-1"
          @click="reorderCandidates(groupIndex, true)"
        />
        <icon-button
          :disabled="readonly"
          icon="mdi-arrow-down"
          class="mb-1"
          @click="reorderCandidates(groupIndex, false)"
        />
        <icon-button
          :disabled="readonly"
          icon="mdi-delete"
          class="mb-1"
          @click="removeCandidate(groupIndex)"
        />

        <span v-show="hasError(groupIndex)" class="ml-2 caption error--text">
          {{ errorMessages[groupIndex][0] }}
        </span>
      </v-row>

      <!-- radio_button -->
      <v-radio-group
        v-if="mode === 'radio_button'"
        :value="corrects[groupIndex][0]"
        :readonly="readonly"
        :error="hasError(groupIndex)"
        hide-details
        column
        class="mt-0 width-maximize"
        @change="updateCorrectsAt(groupIndex, [$event])"
      >
        <v-row
          v-for="(candidate, index) in candidateGroup"
          :key="index"
          class="ml-0"
        >
          <v-radio :value="candidate" color="primary" class="mt-0 mb-1 mr-0" />

          <item-field
            :value="candidate"
            :readonly="readonly"
            class="bottom-4"
            @input="updateCandidatesAt(groupIndex, index, $event)"
            @order-up="reorderCandidateItem(groupIndex, index, true)"
            @order-down="reorderCandidateItem(groupIndex, index, false)"
            @delete="removeCandidateItem(groupIndex, index)"
          />
        </v-row>
      </v-radio-group>

      <!-- checkbox -->
      <div v-else-if="mode === 'checkbox'" class="pb-1">
        <v-flex v-for="(candidate, index) in candidateGroup" :key="index">
          <v-row class="ml-0">
            <v-checkbox
              :input-value="corrects[groupIndex]"
              :value="candidate"
              :readonly="readonly"
              :error="hasError(groupIndex)"
              hide-details
              color="primary"
              class="my-0"
              @change="updateCorrectsAt(groupIndex, $event)"
            />

            <item-field
              :value="candidate"
              :readonly="readonly"
              class="ml-0"
              @input="updateCandidatesAt(groupIndex, index, $event)"
              @order-up="reorderCandidateItem(groupIndex, index, true)"
              @order-down="reorderCandidateItem(groupIndex, index, false)"
              @delete="removeCandidateItem(groupIndex, index)"
            />
          </v-row>
        </v-flex>
      </div>

      <!-- 新しい要素 -->
      <v-row class="ml-8">
        <narrow-text-field
          v-model="newItems[groupIndex]"
          :readonly="readonly"
          class="mt-0"
          placeholder="要素を追加"
          @keyup.enter="addItem(groupIndex)"
        />

        <icon-button
          :disabled="readonly"
          icon="mdi-plus"
          @click="addItem(groupIndex)"
        />
      </v-row>
    </div>

    <!-- 新しい選択肢を追加 -->
    <label>{{ '選択肢' + (candidates.length + 1) }}</label>
    <v-row class="ml-12">
      <narrow-text-field
        v-model="newCandidate"
        :readonly="readonly"
        placeholder="新たな選択肢を追加"
        @keyup.enter="addCandidate"
      />

      <icon-button :disabled="readonly" icon="mdi-plus" @click="addCandidate" />
    </v-row>
  </v-container>
</template>
<script>
import IconButton from '~/components/misc/ProblemModal/NewCandidatesIconButton'
import NarrowTextField from '~/components/misc/ProblemModal/NewCandidatesNarrowTextField'
import ItemField from '~/components/misc/ProblemModal/NewCandidatesItemField'

// 内部でcandidatesとcorrectsのコピー持ち、watchでemitする方針の方がシンプルだったかもしれない
export default {
  name: 'NewCandidates',
  components: {
    NarrowTextField,
    IconButton,
    ItemField
  },
  props: {
    mode: {
      type: String,
      required: true
    },
    readonly: {
      type: Boolean,
      required: true
    },
    // candidates.sync
    candidates: {
      type: Array,
      required: true
    },
    // candidates.sync
    corrects: {
      type: Array,
      required: true
    }
  },
  data() {
    return {
      newCandidate: '',
      newItems: [],
      errorMessages: []
    }
  },
  watch: {
    candidates() {
      this.validate()
    },
    corrects() {
      this.validate()
    }
  },
  created() {
    this.validate()
  },
  methods: {
    // rulesではcandidatesとcorrectsの変更が上手く検知できなかったため自前で行う
    validate() {
      this.errorMessages = this.candidates.map((group, index) => {
        const message = []

        if (group.length < 2) {
          message.push('要素は2つ以上必要です')
        }

        if (!this.isUnique(group)) {
          message.push('重複した要素があります')
        }

        const correctList = this.corrects[index]

        switch (this.mode) {
          case 'radio_button':
            if (correctList.length < 1) {
              message.push('正解が未選択です')
            }
            break
          case 'checkbox':
            break
          default:
            throw new Error(`unsupported problem mode ${this.mode}`)
        }

        return message
      })
    },
    // radio_buttonやcheckboxのerrorをtrueにするとformに検知される
    hasError(index) {
      const messages = this.errorMessages[index]
      return !(
        messages === null ||
        messages === undefined ||
        messages.length === 0
      )
    },
    addCandidate() {
      if (!this.newCandidate) {
        return
      }

      const candidates = this.deepCopy(this.candidates)
      candidates.push([this.newCandidate])

      const corrects = this.deepCopy(this.corrects)
      corrects.push([])

      this.updateCandidates(candidates)
      this.updateCorrects(corrects)
      this.newCandidate = ''
    },
    addItem(index) {
      if (!this.newItems[index]) {
        return
      }

      const candidates = this.deepCopy(this.candidates)
      candidates[index].push(this.newItems[index])
      this.updateCandidates(candidates)
      this.newItems[index] = ''
    },
    removeCandidate(index) {
      const candidates = this.deepCopy(this.candidates)
      candidates.splice(index, 1)
      this.updateCandidates(candidates)

      const corrects = this.deepCopy(this.corrects)
      corrects.splice(index, 1)
      this.updateCorrects(corrects)
    },
    removeCandidateItem(index1, index2) {
      const item = this.candidates[index1][index2]

      // 該当する要素を削除
      const candidates = this.deepCopy(this.candidates)
      candidates[index1].splice(index2, 1)
      this.updateCandidates(candidates)

      // correctsから消す
      const corrects = this.deepCopy(this.corrects)
      const correctIndex = corrects[index1].indexOf(item)

      if (correctIndex !== -1) {
        corrects[index1].splice(correctIndex, 1)
      }

      // updateCandidatesAtと同様の症状
      // なぜか勝手にチェックが付く問題を回避
      this.updateCorrects(corrects)
    },
    reorderCandidates(index, up) {
      if (this.candidates.length <= 1) {
        return
      }

      const candidates = this.deepCopy(this.candidates)
      const corrects = this.deepCopy(this.corrects)

      if (up && index === 0) {
        // 上移動で一番上ならrotate
        this.rotate(candidates, false)
        this.rotate(corrects, false)
      } else if (!up && index === candidates.length - 1) {
        // 下移動で一番下ならrotate
        this.rotate(candidates, true)
        this.rotate(corrects, true)
      } else {
        // それ以外なら値を交換する
        const to = index + (up ? -1 : 1)
        this.swapByIndex(candidates, index, to)
        this.swapByIndex(corrects, index, to)
      }

      this.updateCandidates(candidates)
      this.updateCorrects(corrects)
    },
    reorderCandidateItem(index1, index2, up) {
      if (this.candidates[index1].length <= 1) {
        return
      }

      const candidates = this.deepCopy(this.candidates)
      const items = candidates[index1]

      if (up && index2 === 0) {
        // 上移動で一番上ならrotate
        this.rotate(items, false)
      } else if (!up && index2 === items.length - 1) {
        // 下移動で一番下ならrotate
        this.rotate(items, true)
      } else {
        // それ以外なら値を交換する
        const to = index2 + (up ? -1 : 1)
        this.swapByIndex(items, index2, to)
      }

      this.updateCandidates(candidates)
      this.refreshCorrects()
    },
    shuffleCandidateItem(index) {
      if (this.candidates[index].length <= 1) {
        return
      }

      const candidates = this.deepCopy(this.candidates)
      candidates[index] = this.$_.shuffle(candidates[index])

      this.updateCandidates(candidates)
      this.refreshCorrects()
    },

    // candidatesやcorrectsを更新するための関数郡
    updateCandidates(value) {
      this.$emit('update:candidates', value)
    },
    updateCorrects(value) {
      this.$emit('update:corrects', value)
    },
    updateCandidatesAt(index1, index2, value) {
      const oldValue = this.candidates[index1][index2]
      const oldIndex = this.corrects[index1].indexOf(oldValue)

      const candidates = this.deepCopy(this.candidates)
      candidates[index1][index2] = value
      this.$emit('update:candidates', candidates)

      const corrects = this.deepCopy(this.corrects)

      // correctsに含まれるフィールドを編集しているなら、correctsも更新する
      if (oldIndex !== -1) {
        corrects[index1][oldIndex] = value
      }

      // チェックボックスのフィールドを編集すると見た目上だけチェックが入るバグがある
      // correctsを更新することで、チェックを正しい状態にする
      this.updateCorrects(corrects)
    },
    updateCorrectsAt(index1, value) {
      const corrects = this.deepCopy(this.corrects)
      corrects[index1] = value || []
      this.updateCorrects(corrects)
    },
    // candidatesを入れ替えた後にcorrectsの表示を追従させる
    refreshCorrects() {
      // 一旦空にして無理やり再描画
      const tmp = this.deepCopy(this.corrects)
      this.updateCorrects(this.corrects.map(e => []))
      this.$nextTick(() => this.updateCorrects(tmp))
    },

    // 基本的な配列操作の関数郡
    deepCopy(array2d) {
      return array2d.map(o => Array.from(o))
    },
    swapByIndex(array, index1, index2) {
      const tmp = array[index1]
      array[index1] = array[index2]
      array[index2] = tmp
    },
    rotate(array, reverse) {
      if (reverse) {
        array.unshift(array.pop())
      } else {
        array.push(array.shift())
      }
    },
    isUnique(array) {
      return array.length === this.$_.uniq(array).length
    }
  }
}
</script>
<style scoped lang="sass">
// radio_buttonだけwidth: autoになるので上書き
.width-maximize
  ::v-deep
    .v-input__control
      width: 100%
.bottom-4
  position: relative
  bottom: 4px
</style>
