<template>
  <v-layout column class="pb-1">
    <v-flex class="pb-0">
      <openable-button v-model="show" :togglable="supplements.length !== 0">
        補足事項
      </openable-button>
      <!-- TODO: 未実装 -->
      <v-btn v-if="isStaff" small fab>
        <v-icon small>mdi-pen</v-icon>
      </v-btn>
    </v-flex>
    <v-slide-x-reverse-transition group>
      <!-- v-ifだとアニメーションが無いため[]にする -->
      <v-flex
        v-for="supplement in show ? supplements : []"
        :key="supplement.id"
        class="pb-0"
      >
        <problem-supplement-sheet :supplement="supplement" />
      </v-flex>
    </v-slide-x-reverse-transition>
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
