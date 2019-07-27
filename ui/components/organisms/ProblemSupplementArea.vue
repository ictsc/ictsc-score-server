<template>
  <v-layout column>
    <v-flex>
      <expandable-button v-model="show" :togglable="supplements.length !== 0">
        補足事項
      </expandable-button>
      <!-- TODO: 未実装 -->
      <v-btn v-if="isStaff" x-small fab color="white" elevation="2">
        <v-icon>mdi-pen</v-icon>
      </v-btn>
    </v-flex>
    <!-- v-forとv-showで上手くアニメーションさせるためにv-flexをネストする -->
    <v-flex
      v-for="supplement in sortedSupplements"
      :key="supplement.id"
      class="pa-0"
    >
      <v-expand-transition>
        <v-flex v-show="show" class="pt-0">
          <problem-supplement-sheet :supplement="supplement" />
        </v-flex>
      </v-expand-transition>
    </v-flex>
  </v-layout>
</template>
<script>
import ExpandableButton from '~/components/molecules/ExpandableButton'
import ProblemSupplementSheet from '~/components/molecules/ProblemSupplementSheet'

export default {
  name: 'ProblemSupplementArea',
  components: {
    ExpandableButton,
    ProblemSupplementSheet
  },
  props: {
    supplements: {
      type: Array,
      required: true
    }
  },
  data() {
    return {
      show: true
    }
  },
  computed: {
    sortedSupplements() {
      return this.sortByCreatedAt(this.supplements)
    }
  }
}
</script>
