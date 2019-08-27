<template>
  <v-layout row align-end justify-space-between>
    <v-flex v-if="problemBody.modeIsTextbox">
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
                :disabled="!validPoint"
                :loading="sending"
                color="primary"
                @click="applyScore"
                v-on="on"
              >
                採点
              </v-btn>
            </template>
            <span v-if="hideAllScore">採点結果は参加者には非公開です</span>
            <span v-else>時間内の再採点は参加者に認知されません</span>
          </v-tooltip>
        </template>
      </v-slider>
    </v-flex>

    <v-flex
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
    </v-flex>

    <v-flex v-else>
      未実装の問題タイプです
    </v-flex>
  </v-layout>
</template>
<script>
import { mapGetters } from 'vuex'
import orm from '~/orm'
import NumberTextField from '~/components/atoms/NumberTextField'

export default {
  name: 'GradeForm',
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
    const point = this.$elvis(this.answer, 'score.point')

    return {
      sending: false,
      stepEnable: true,
      slider: point || -5,
      text: point ? String(point) : 'null'
    }
  },

  computed: {
    ...mapGetters('contestInfo', ['hideAllScore']),
    validPoint() {
      return this.text === 'null' || this.validPointNumberText(this.text)
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

      const point = this.text === 'null' ? null : parseInt(this.text)
      await orm.Score.applyScore({
        action: '採点',
        params: { answerId: this.answer.id, point }
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
