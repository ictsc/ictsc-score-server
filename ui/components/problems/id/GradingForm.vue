<template>
  <v-row align="end" justify="space-between">
    <template v-if="problemBody.modeIsTextbox">
      <v-slider
        v-model="slider"
        :step="stepEnable ? 5 : undefined"
        :readonly="sending"
        track-color="grey lighten-2"
        min="-5"
        max="100"
        hide-details
        @start="stepEnable = true"
      >
        <template v-slot:prepend>
          <number-text-field
            v-model="text"
            :readonly="sending"
            suffix="%"
            hide-details
            type="string"
            single-line
            @focus="stepEnable = false"
          />

          <!-- 基準突破チェック + 説明ツールチップ -->
          <v-tooltip open-delay="300" bottom>
            <template v-slot:activator="{ on }">
              <v-icon :color="solvedIconColor" class="ml-2" v-on="on">
                mdi-check-bold
              </v-icon>
            </template>
            <span>基準を超えるとチェックが付きます</span>
          </v-tooltip>
        </template>

        <template v-slot:append>
          <v-tooltip bottom>
            <template v-slot:activator="{ on }">
              <v-btn
                :disabled="!validPoint || !changed"
                :loading="sending"
                color="primary"
                @click="applyScore"
                v-on="on"
              >
                採点
              </v-btn>
            </template>

            <span v-if="hideAllScore">採点結果は参加者には非公開です</span>
            <span v-else-if="realtimeGrading">
              時間内の再採点は参加者に認知されません
            </span>
          </v-tooltip>
        </template>
      </v-slider>
    </template>

    <template
      v-else-if="problemBody.modeIsRadioButton || problemBody.modeIsCheckbox"
    >
      <!-- TODO: API側が未実装なので非表示 -->
      <v-btn
        v-if="false"
        :disabled="!validPoint"
        :loading="sending"
        color="primary"
        @click="regrade"
      >
        再採点
      </v-btn>
    </template>

    <template v-else>
      未実装の問題タイプです
    </template>
  </v-row>
</template>
<script>
import { mapGetters } from 'vuex'
import orm from '~/orm'
import NumberTextField from '~/components/commons/NumberTextField'

export default {
  name: 'GradingForm',
  components: {
    NumberTextField
  },
  props: {
    answer: {
      type: Object,
      required: true
    },
    problemBody: {
      type: Object,
      required: true
    }
  },

  data() {
    return {
      previous: this.answer.hasPoint ? this.answer.percent : -5,
      sending: false,
      stepEnable: false,
      slider: this.answer.hasPoint ? this.answer.percent : -5,
      text: this.answer.hasPoint ? String(this.answer.percent) : 'null'
    }
  },

  computed: {
    ...mapGetters('contestInfo', ['realtimeGrading', 'hideAllScore']),
    validPoint() {
      return this.text === 'null' || this.validPointNumberText(this.text)
    },
    changed() {
      return this.previous !== this.slider
    },
    solvedIconColor() {
      return this.problemBody.solvedCriterion <= this.slider
        ? 'primary'
        : 'grey lighten-2'
    }
  },
  watch: {
    slider(value) {
      this.text = value === -5 ? 'null' : String(value)
    },
    text(value) {
      if (value === 'null') {
        this.slider = -5
      } else if (this.validPointNumberText(value)) {
        this.slider = parseInt(value)
      } else {
        // 例え無効な値でもsliderを-5にすると挙動がおかしくなる
      }
    }
  },
  methods: {
    validPointNumberText(text) {
      const value = parseInt(text)

      if (isNaN(value)) {
        return false
      } else if (value >= 0 && value <= 100) {
        return true
      } else {
        return false
      }
    },
    async applyScore() {
      this.sending = true

      const percent = this.text === 'null' ? null : parseInt(this.text)
      await orm.Mutation.applyScore({
        action: '採点',
        resolve: () => {
          this.previous = this.slider
        },
        params: { answerId: this.answer.id, percent }
      })

      this.sending = false
    },
    regrade() {
      // TODO: 実装
      this.notifyWarning({ message: '未実装です' })
    }
  }
}
</script>
<style scoped lang="sass">
::v-deep
  .v-slider--horizontal
    margin-top: 7px
    margin-left: 0px
</style>
