<template>
  <v-layout column>
    <v-flex
      v-for="(candidateGroup, groupIndex) in candidatesGroups"
      :key="groupIndex"
    >
      <v-layout column justify-start pt-4 pb-0>
        <span>{{ '選択肢' + (groupIndex + 1) }}</span>
        <v-flex v-for="(candidate, index) in candidateGroup" :key="index" py-0>
          <v-checkbox
            v-model="internalValue[groupIndex]"
            hide-details
            :label="candidate"
            :value="candidate"
            :readonly="readonly"
            color="primary"
            class="my-0"
          />
        </v-flex>
      </v-layout>
    </v-flex>
  </v-layout>
</template>
<script>
export default {
  name: 'AnswerFormRadioButton',
  props: {
    // v-modelでバインドされ、親での変更を検知できる
    value: {
      type: Array,
      required: true
    },
    // v-bind:error.sync
    error: {
      type: Boolean,
      default: false
    },
    candidatesGroups: {
      type: Array,
      required: true
    },
    readonly: {
      type: Boolean,
      required: true
    }
  },
  data() {
    return {
      internalValue: this.value
    }
  },
  computed: {
    checkError() {
      // 未選択も解答の1つなため常にfalse
      return false
    }
  },
  watch: {
    internalValue() {
      this.$emit('input', this.internalValue)
      this.$emit('update:error', this.checkError)
    },
    value() {
      this.internalValue = this.value
    }
  },
  created() {
    // バリデーションの初期状態を同期する
    this.$emit('update:error', this.checkError)
  }
}
</script>
