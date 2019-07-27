<template>
  <!-- TODO: 色は未調整 -->
  <v-sheet class="error elevation-2 my-1">
    <v-layout column>
      <v-flex py-0>
        <markdown :content="supplement.text" color="error" />
      </v-flex>
      <v-flex v-if="isStaff" py-1 pr-2>
        <v-layout row align-center justify-end class="elevation-0">
          <span class="caption mr-2 mt-0">{{ supplement.createdAt }}</span>
          <!-- TODO: イベントとカウントダウンは未実装 -->
          <delete-button color="error" expire class="mb-1 mr-1" />
        </v-layout>
      </v-flex>
    </v-layout>
  </v-sheet>
</template>
<script>
import DeleteButton from '~/components/atoms/DeleteButton'
import Markdown from '~/components/atoms/Markdown'

export default {
  name: 'ProblemSupplementSheet',
  components: {
    DeleteButton,
    Markdown
  },
  props: {
    supplement: {
      type: Object,
      required: true
    }
  }
}
</script>
<style scoped lang="sass"></style>
