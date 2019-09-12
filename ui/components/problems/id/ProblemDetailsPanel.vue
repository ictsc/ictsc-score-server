<template>
  <v-layout column>
    <!-- エラー防止のためにモーダルをレンダリングしない -->
    <problem-modal v-if="showModal" v-model="showModal" :problem="problem" />

    <!-- 編集ボタン, タイトル -->
    <v-flex>
      <v-container fluid py-0>
        <v-row align="center" justify="start">
          <pen-button
            v-if="isStaff"
            class="mr-2"
            @click.stop="showModal = true"
          />

          <div class="grey--text text--darken-3 display-1">
            {{ problem.body.title }}
          </div>
        </v-row>
      </v-container>
      <v-divider class="primary" />
    </v-flex>

    <!-- 問題情報 -->
    <v-flex class="my-1">
      <problem-info-chips-area :problem="problem" class="ml-0" />
    </v-flex>

    <!-- 運営メモ -->
    <v-flex v-if="!!problem.secretText">
      <v-sheet class="pa-2 elevation-2">
        <span class="pa-2 body-2">運営用メモ</span>
        <v-divider class="pb-1" />
        <markdown :content="problem.secretText" />
      </v-sheet>
    </v-flex>

    <!-- 補足 -->
    <v-flex v-if="problem.supplements.length !== 0 || isStaff">
      <problem-supplement-area
        :supplements="problem.supplements"
        :problem-code="problem.code"
      />
    </v-flex>

    <!-- 環境 -->
    <v-flex v-if="problem.environments.length !== 0">
      <problem-environment-area :environments="problem.environments" />
    </v-flex>

    <!-- 本文 -->
    <v-flex>
      <v-sheet class="pa-2 elevation-2">
        <span class="pa-2 body-2">問題文</span>
        <v-divider class="pb-1" />
        <!-- TODO: 長文対応どうするか -->
        <markdown :content="problem.body.text" />
      </v-sheet>
    </v-flex>
  </v-layout>
</template>
<script>
import Markdown from '~/components/commons/Markdown'
import PenButton from '~/components/commons/PenButton'
import ProblemEnvironmentArea from '~/components/problems/id/ProblemEnvironmentArea'
import ProblemModal from '~/components/misc/ProblemModal'
import ProblemInfoChipsArea from '~/components/problems/id/ProblemInfoChipsArea'
import ProblemSupplementArea from '~/components/problems/id/ProblemSupplementArea'

// TODO: 現在の得点が見たい

export default {
  name: 'ProblemDetailsPanel',
  components: {
    Markdown,
    PenButton,
    ProblemEnvironmentArea,
    ProblemModal,
    ProblemInfoChipsArea,
    ProblemSupplementArea
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
<style scoped lang="sass"></style>
