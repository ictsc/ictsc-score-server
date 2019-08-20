<template>
  <v-sheet class="error elevation-2 my-1">
    <v-layout column>
      <v-flex py-0>
        <markdown :content="supplement.text" color="error" />
      </v-flex>
      <v-flex py-1 pr-2>
        <v-layout row align-center justify-end class="elevation-0">
          <span class="caption mr-2 mt-0">{{ supplement.createdAtShort }}</span>
          <delete-button
            v-if="isStaff"
            :start-at-msec="Date.parse(supplement.createdAt)"
            :disabled="deleteButtonDisabled"
            color="error"
            class="mb-1 mr-1"
            @click="destroy"
          />
        </v-layout>
      </v-flex>
    </v-layout>
  </v-sheet>
</template>
<script>
import orm from '~/orm'
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
  },
  data() {
    return {
      deleteButtonDisabled: false
    }
  },
  methods: {
    async destroy() {
      this.deleteButtonDisabled = true

      await orm.ProblemSupplement.deleteProblemSupplement({
        action: '補足削除',
        params: { problemSupplementId: this.supplement.id }
      })

      this.deleteButtonDisabled = false
    }
  }
}
</script>
<style scoped lang="sass"></style>
