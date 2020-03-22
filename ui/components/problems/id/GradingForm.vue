<template>
  <v-col>
    <v-row justify="space-between">
      <template v-if="problem.modeIsTextbox">
        <grading-slider v-model="percent" :sending="sending">
          <template v-slot:prepend>
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
                  :disabled="!wasChanged"
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
        </grading-slider>
      </template>
    </v-row>

    <v-row align="center" justify="end" no-guters>
      <v-tooltip open-delay="300" bottom>
        採点者間の連携用<br />
        後で確認するなど

        <template v-slot:activator="{ on }">
          <v-switch
            :input-value="answer.confirming"
            :readonly="sending"
            inset
            hide-details
            color="primary"
            class="mt-0"
            @change="confirmingAnswer($event)"
            v-on="on"
          >
            <template v-slot:prepend>
              <div class="py-1" style="width: 3.2em">
                {{ answer.confirming ? '対応中' : '未対応' }}
              </div>
            </template>
          </v-switch>
        </template>
      </v-tooltip>
    </v-row>
  </v-col>
</template>
<script>
import { mapGetters } from 'vuex'
import orm from '~/orm'
import GradingSlider from '~/components/problems/id/GradingSlider'

export default {
  name: 'GradingForm',
  components: {
    GradingSlider
  },
  props: {
    answer: {
      type: Object,
      required: true
    },
    problem: {
      type: Object,
      required: true
    }
  },
  data() {
    return {
      sending: false,
      percent: this.answer.hasPoint ? this.answer.percent : null,
      previousPercent: this.answer.hasPoint ? this.answer.percent : null
    }
  },
  computed: {
    ...mapGetters('contestInfo', ['realtimeGrading', 'hideAllScore']),

    wasChanged() {
      return this.previousPercent !== this.percent
    },
    solvedIconColor() {
      return this.problem.solvedCriterion <= this.percent
        ? 'primary'
        : 'grey lighten-2'
    }
  },
  methods: {
    async applyScore() {
      this.sending = true

      await orm.Mutations.applyScore({
        action: '採点',
        resolve: () => {
          this.previousPercent = this.percent
        },
        params: { answerId: this.answer.id, percent: this.percent }
      })

      this.sending = false
    },
    async confirmingAnswer(confirming) {
      this.sending = true

      await orm.Mutations.confirmingAnswer({
        action: '対応状況の遷移',
        resolve: () => {},
        params: { answerId: this.answer.id, confirming }
      })

      this.sending = false
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
