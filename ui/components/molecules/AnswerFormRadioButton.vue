<template>
  <v-layout column>
    <v-flex
      v-for="(candidateGroup, groupIndex) in candidatesGroups"
      :key="groupIndex"
    >
      <v-layout column>
        <v-radio-group
          v-model="internalValue[groupIndex][0]"
          :label="'選択肢' + (groupIndex + 1)"
          :readonly="readonly"
          column
          hide-details
        >
          <v-radio
            v-for="(candidate, index) in candidateGroup"
            :key="index"
            :label="candidate"
            :value="candidate"
            color="primary"
          />
        </v-radio-group>
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
      console.log(this.internalValue)
      return (
        this.internalValue.filter(o => o.length !== 0).length !==
        this.candidatesGroups.length
      )
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
