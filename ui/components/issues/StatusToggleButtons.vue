<template>
  <v-btn-toggle :value="value" multiple @change="$emit('change', $event)">
    <v-btn
      value="unsolved"
      active-class="error white--text elevation-4"
      :class="unsolvedClass"
    >
      未解決
    </v-btn>

    <v-btn
      v-if="isStaff"
      value="in_progress"
      active-class="warning white--text elevation-4"
      :class="inProgressClass"
    >
      対応中
    </v-btn>

    <v-btn
      value="solved"
      active-class="success white--text elevation-4"
      :class="solvedClass"
    >
      解決済
    </v-btn>
  </v-btn-toggle>
</template>
<script>
export default {
  name: 'StatusToggleButtons',
  model: {
    prop: 'value',
    event: 'change',
  },
  props: {
    value: {
      type: Array,
      required: true,
    },
  },
  computed: {
    unsolvedClass() {
      return this.value.includes('unsolved') ? '' : 'error--text'
    },
    inProgressClass() {
      return this.value.includes('in_progress') ? '' : 'warning--text'
    },
    solvedClass() {
      return this.value.includes('solved') ? '' : 'success--text'
    },
  },
}
</script>
