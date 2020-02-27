<template>
  <v-row align="center" justify="center" class="flex-nowrap" no-gutters>
    <v-dialog
      v-model="confirming"
      :persistent="sending"
      scrollable
      max-width="40em"
    >
      <template v-slot:activator="{ on }">
        <v-btn
          v-if="isPlayer"
          :disabled="sending || waitingSubmitSec !== 0"
          color="warning"
          block
          class="mb-4"
          v-on="on"
        >
          <template v-if="waitingSubmitSec === 0">
            リセット要求 {{ penalties.length + 1 }}回目
          </template>
          <template v-else>
            {{ penalties.length + 1 }}回目のリセット要求可能まで
            {{ $nuxt.timeSimpleStringJp(waitingSubmitSec) }}
          </template>
        </v-btn>

        <div v-else class="pt-1 pb-2">
          リセット回数{{ penalties.length }}回
          {{ latestPenaltyDelayFinishInSec }}
        </div>
      </template>

      <v-card>
        <v-card-title>
          <div>リセット要求</div>
        </v-card-title>

        <v-divider />

        <v-card-text class="py-2 warning lighten-2 black--text">
          <!-- 警告 -->
          <template v-if="resetDelaySec !== 0">
            <div>
              リセット依頼後
              {{ resetDelayString }}
              経過で新たな問題環境が展開されます<br />
              展開が完了するまで解答できなくなります
            </div>
          </template>
        </v-card-text>

        <v-divider />

        <v-card-actions>
          <v-btn :loading="sending" color="warning" @click="submit">
            リセット要求
          </v-btn>

          <v-spacer />

          <v-btn :disabled="sending" @click="confirming = false">
            キャンセル
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </v-row>
</template>
<script>
import { mapGetters } from 'vuex'
import orm from '~/orm'

export default {
  name: 'PenaltyCounter',
  props: {
    problemId: {
      type: String,
      required: true
    },
    penalties: {
      type: Array,
      required: true
    },
    waitingSubmitSec: {
      type: Number,
      required: true
    }
  },
  data() {
    return {
      confirming: false,
      sending: false
    }
  },
  computed: {
    ...mapGetters('contestInfo', ['resetDelaySec', 'resetDelayString']),

    latestPenaltyDelayFinishInSec() {
      const latestPenalty = this.findNewer(this.penalties)
      return latestPenalty && latestPenalty.delayFinishInSec > 0
        ? latestPenalty.delayTickDuration
        : ''
    }
  },
  methods: {
    async submit() {
      this.sending = true

      await orm.Mutations.addPenalty({
        action: 'リセット要求',
        params: { problemId: this.problemId },
        resolve: () => {
          this.confirming = false
        }
      })

      this.sending = false
    }
  }
}
</script>
