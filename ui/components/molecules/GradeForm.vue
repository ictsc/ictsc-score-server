<template>
  <v-layout row align-end justify-space-between>
    <v-flex v-if="problemBody.modeIsTextbox">
      <v-slider
        v-model="slider"
        @start="stepEnable = true"
        :step="stepEnable ? 5 : undefined"
        :readonly="sending"
        track-color="grey lighten-2"
        min="-5"
        max="100"
        hide-details
      >
        <template v-slot:prepend>
          <v-text-field
            v-model="text"
            @focus="stepEnable = false"
            :readonly="sending"
            suffix="%"
            hide-details
            flat
            maxlength="4"
            single-line
            height="1em"
            class="score-field"
          >
          </v-text-field>

          <v-icon :color="solvedIconColor" class="ml-2">
            mdi-check-bold
          </v-icon>
        </template>

        <template v-slot:append>
          <v-tooltip top>
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

export default {
  name: 'GradeForm',
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

      try {
        const point = this.text === 'null' ? null : parseInt(this.text)
        const res = await orm.Score.applyScore({
          answerId: this.answer.id,
          point
        })

        if (res.errors) {
          this.notifyWarning({ message: '採点の反映に失敗しました' })
        } else {
          this.notifySuccess({ message: '採点を反映しました' })
        }
      } catch (error) {
        console.error(error)
        this.notifyError({
          message: '想定外のエラーにより採点の反映に失敗しました'
        })
      } finally {
        this.sending = false
      }
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

.score-field
  width: 3em
  ::v-deep
    input
      text-align: right
</style>
