<template>
  <!-- TODO: 色は未調整 -->
  <v-sheet class="error elevation-2 pa-2">
    <v-layout column>
      <v-flex>
        <markdown :content="supplement.text" />
      </v-flex>
      <v-flex v-if="isStaff">
        <v-layout align-center justify-end class="elevation-0">
          <div class="caption mr-2 mt-2">{{ supplement.createdAt }}</div>
          <!-- TODO: イベントとカウントダウンは未実装 -->
          <delete-button color="error" expire />
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
