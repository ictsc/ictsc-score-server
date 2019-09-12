<template>
  <v-layout wrap>
    <v-flex
      v-for="(chips, index) in chipsLists"
      :key="index"
      shrink
      class="pa-0 ma-0"
    >
      <v-chip
        v-for="chip in chips"
        :key="chip.name"
        class="mb-1 mr-1 white elevation-2"
        small
      >
        {{ chip.name }}
        <v-divider vertical inset class="mx-1" />
        {{ chip.value }}
      </v-chip>
    </v-flex>
  </v-layout>
</template>
<script>
import { mapGetters } from 'vuex'

export default {
  name: 'ProblemInfoChipsArea',
  props: {
    problem: {
      type: Object,
      required: true
    }
  },
  computed: {
    ...mapGetters('contestInfo', ['realtimeGrading']),

    chipsLists() {
      const list = [[{ name: '満点', value: this.problem.body.perfectPoint }]]

      if (this.isStaff || this.realtimeGrading) {
        list[0].push({
          name: '基準',
          value: this.problem.body.solvedCriterion + '%'
        })
        list[0].push({ name: '突破チーム数', value: this.problem.solvedCount })
      }

      if (this.isStaff) {
        list.push(
          [
            { name: 'コード', value: this.problem.code },
            { name: '作問者', value: this.problem.writer }
          ],
          [{ name: '種類', value: this.problem.body.modeJp }],
          [{ name: '最終更新', value: this.problem.body.updatedAtShort }]
        )
      }

      return list
    }
  }
}
</script>
