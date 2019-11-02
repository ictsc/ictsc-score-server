<template>
  <div>
    <div
      v-for="(candidateGroup, groupIndex) in candidatesGroups"
      :key="groupIndex"
      class="pt-4 pb-0"
    >
      <div>{{ '選択肢' + (groupIndex + 1) }}</div>
      <v-radio-group
        v-model="internalValue[groupIndex][0]"
        :readonly="readonly"
        :rules="rules"
        column
        hide-details
        class="my-0"
      >
        <v-radio
          v-for="(candidate, index) in candidateGroup"
          :key="index"
          :label="candidate"
          :value="candidate"
          color="primary"
          class="mb-1"
        />
      </v-radio-group>
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
      required: true
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
      internalValue: this.value,
      rules: [v => !!v || '必須']
    }
  },
  watch: {
    internalValue() {
      this.$emit('input', this.internalValue)
    },
    value() {
      this.internalValue = this.value
    }
  }
}
</script>
