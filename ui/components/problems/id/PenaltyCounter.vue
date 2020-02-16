<template>
  <v-row v-if="isDisplay" align="center" justify="center" class="flex-nowrap">
    <div>リセット</div>

    <v-btn v-if="isStaff" :disabled="sending" icon @click="submit(-1)">
      <v-icon>mdi-arrow-left-bold-box-outline</v-icon>
    </v-btn>

    <div class="text-center" style="width: 2.5em">{{ count }}回</div>

    <v-btn v-if="isStaff" :disabled="sending" icon @click="submit(1)">
      <v-icon>mdi-arrow-right-bold-box-outline</v-icon>
    </v-btn>
  </v-row>
</template>
<script>
import orm from '~/orm'

export default {
  name: 'PenaltyCounter',
  props: {
    problemId: {
      type: String,
      required: true
    },
    teamId: {
      type: String,
      required: true
    }
  },
  data() {
    return {
      sending: false
    }
  },
  computed: {
    penalty() {
      // primaryKey順
      return orm.Penalty.find([this.problemId, this.teamId])
    },
    count() {
      return this.penalty ? this.penalty.count : 0
    },
    isDisplay() {
      return this.isStaff || this.count !== 0
    }
  },
  methods: {
    async submit(num) {
      console.info('submit', num)
      this.sending = true

      await orm.Mutations.transitionPenalty({
        params: {
          problemId: this.problemId,
          teamId: this.teamId,
          from: this.count,
          to: this.count + num
        }
      })

      this.sending = false
    }
  }
}
</script>
