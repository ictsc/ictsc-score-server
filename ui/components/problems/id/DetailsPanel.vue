<template>
  <v-col class="pa-0">
    <problem-modal v-if="isStaff" v-model="showModal" :item="problem" />

    <!-- 編集ボタン, タイトル -->
    <v-container fluid py-0>
      <v-row align="center" justify="start">
        <pen-button
          v-if="isStaff"
          elevation="2"
          class="mr-2"
          @click.stop="showModal = true"
        />

        <div class="grey--text text--darken-3 display-1">
          {{ problem.title }}
        </div>
      </v-row>
    </v-container>
    <v-divider class="primary" />

    <!-- 問題情報 -->
    <info-chips-area :problem="problem" class="mt-2 ml-0" />

    <!-- 補足 -->
    <supplement-area
      v-if="problem.supplements.length !== 0 || isStaff"
      :supplements="problem.supplements"
      :problem-code="problem.code"
      class="pt-2"
    />

    <!-- 運営メモ -->
    <v-sheet v-if="!!problem.secretText" class="pa-2 elevation-2">
      <span class="pa-2 body-2">運営用メモ</span>
      <v-divider class="pb-1" />
      <markdown :content="problem.secretText" />
    </v-sheet>

    <!-- 環境 -->
    <environment-area
      v-if="problem.environments.length !== 0"
      :environments="problem.environments"
      class="py-2"
    />

    <!-- 本文 -->
    <v-sheet class="pa-2 elevation-2">
      <span class="pa-2 body-2">問題文</span>
      <v-divider class="pb-1" />
      <!-- TODO: 長文対応どうするか -->
      <markdown :content="problem.text" />
    </v-sheet>
  </v-col>
</template>
<script>
import Markdown from '~/components/commons/Markdown'
import PenButton from '~/components/commons/PenButton'
import EnvironmentArea from '~/components/problems/id/EnvironmentArea'
import ProblemModal from '~/components/misc/ProblemModal'
import InfoChipsArea from '~/components/problems/id/InfoChipsArea'
import SupplementArea from '~/components/problems/id/SupplementArea'

export default {
  name: 'DetailsPanel',
  components: {
    Markdown,
    PenButton,
    EnvironmentArea,
    ProblemModal,
    InfoChipsArea,
    SupplementArea
  },
  props: {
    problem: {
      type: Object,
      required: true
    }
  },
  data() {
    return {
      showModal: false
    }
  }
}
</script>
