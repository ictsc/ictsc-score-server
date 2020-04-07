<template>
  <div>
    <div
      v-for="(candidateGroup, groupIndex) in candidatesGroups"
      :key="groupIndex"
      class="pt-4 pb-0"
    >
      <div>{{ '選択肢' + (groupIndex + 1) }}</div>
      <v-checkbox
        v-for="(candidate, index) in candidateGroup"
        :key="index"
        v-model="internalValue[groupIndex]"
        :label="candidate"
        :value="candidate"
        :readonly="readonly"
        hide-details
        color="primary"
        class="my-0"
      />
    </div>
  </div>
</template>
<script>
export default {
  name: 'AnswerFormRadioButton',
  props: {
    // v-modelでバインドされ、親での変更を検知できる
    value: {
      type: Array,
      required: true,
    },
    candidatesGroups: {
      type: Array,
      required: true,
    },
    readonly: {
      type: Boolean,
      required: true,
    },
  },
  data() {
    return {
      internalValue: this.value,
    }
  },
  watch: {
    internalValue() {
      this.$emit('input', this.internalValue)
    },
    value() {
      this.internalValue = this.value
    },
  },
}
</script>
