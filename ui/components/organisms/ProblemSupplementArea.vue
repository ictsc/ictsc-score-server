<template>
  <v-layout column>
    <v-flex>
      <openable-button v-model="show" :togglable="supplements.length !== 0">
        補足事項
      </openable-button>
      <!-- TODO: 未実装 -->
      <v-btn v-if="isStaff" small fab color="white" elevation="2">
        <v-icon small>mdi-pen</v-icon>
      </v-btn>
    </v-flex>
    <!-- v-forとv-showで上手くアニメーションさせるためにv-flexをネストする -->
    <v-flex v-for="supplement in supplements" :key="supplement.id" class="pa-0">
      <v-slide-y-transition>
        <v-flex v-show="show" class="pt-0">
          <problem-supplement-sheet :supplement="supplement" />
        </v-flex>
      </v-slide-y-transition>
    </v-flex>
  </v-layout>
</template>
<script>
import OpenableButton from '~/components/atoms/OpenableButton'
import ProblemSupplementSheet from '~/components/molecules/ProblemSupplementSheet'

export default {
  name: 'ProblemSupplementArea',
  components: {
    OpenableButton,
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
  }
}
</script>
