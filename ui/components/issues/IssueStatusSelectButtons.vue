<template>
  <v-btn-toggle :value="internalValue" multiple @change="emitChange($event)">
    <v-btn
      :value="noneValue()"
      active-class="elevation-4"
      @click.capture="selectAll"
    >
      全表示
    </v-btn>

    <v-btn :value="red" active-class="error elevation-4" :class="unsolvedClass">
      未解決
    </v-btn>

    <v-btn
      v-if="isStaff"
      :value="yellow"
      active-class="warning elevation-4"
      :class="inProgressClass"
    >
      対応中
    </v-btn>

    <v-btn
      :value="green"
      active-class="success elevation-4"
      :class="solvedClass"
    >
      解決済
    </v-btn>
  </v-btn-toggle>
</template>
<script>
export default {
  name: 'IssueStatusSelectButtons',
  model: {
    prop: 'value',
    event: 'change'
  },
  props: {
    value: {
      type: Array,
      required: true
    },
    red: {
      type: String,
      required: true
    },
    yellow: {
      type: String,
      required: true
    },
    green: {
      type: String,
      required: true
    }
  },
  data() {
    return {
      internalValue: this.convert(this.value)
    }
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
    }
  },
  methods: {
    allValues() {
      return [this.red, this.yellow, this.green]
    },
    noneValue() {
      return 'none'
    },
    selectAll() {
      this.emitChange(this.allValues())
    },
    convert(list) {
      if (this.allValues().every(v => list.includes(v))) {
        return [...this.allValues()]
      } else {
        return this.$_.uniq([this.noneValue(), ...list])
      }
    },
    emitChange(list) {
      this.internalValue = this.convert(list)
      this.$emit('change', this.internalValue)
    }
  }
}
</script>
