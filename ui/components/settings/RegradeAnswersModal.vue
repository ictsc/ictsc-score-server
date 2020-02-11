<template>
  <v-dialog
    v-model="internalValue"
    :persistent="sending"
    max-width="16em"
    scrollable
  >
    <v-card>
      <v-card-title>
        再採点
      </v-card-title>

      <v-card-subtitle class="ml-2 text-truncate">
        {{ problem.title }}
      </v-card-subtitle>

      <v-card-text class="black--text">
        <v-row justify="start" class="pl-1">
          <v-col cols="3">
            <div>合計</div>
            <div>成功</div>
            <div>失敗</div>
          </v-col>

          <v-col cols="3">
            <div>{{ total }}</div>
            <div>{{ succeeded }}</div>
            <div>{{ failed }}</div>
          </v-col>
        </v-row>
      </v-card-text>

      <v-card-actions>
        <v-spacer />

        <v-btn :loading="sending" color="success" left @click="submit">
          実行
        </v-btn>

        <v-btn left :disabled="sending" @click="close">
          閉じる
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>
<script>
import orm from '~/orm'

export default {
  name: 'RegradeAnswersModal',
  props: {
    // v-model
    value: {
      type: Boolean,
      required: true
    },
    problem: {
      type: Object,
      required: true
    }
  },
  data() {
    return {
      internalValue: this.value,
      sending: false,
      total: 0,
      succeeded: 0,
      failed: 0
    }
  },
  watch: {
    internalValue(value) {
      this.$emit('input', value)
    },
    value(value) {
      this.internalValue = value
    }
  },
  methods: {
    async submit() {
      this.sending = true

      const response = await orm.Mutations.regradeAnswers({
        action: '採点再実行',
        params: { problemId: this.problem.id }
      })

      this.sending = false

      const results = response.regradeAnswers

      if (results) {
        this.total = results.total
        this.succeeded = results.succeeded
        this.failed = results.failed
      }
    },
    close() {
      this.internalValue = false
    }
  }
}
</script>
