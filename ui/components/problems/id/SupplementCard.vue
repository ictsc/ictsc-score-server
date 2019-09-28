<template>
  <v-card class="elevation-2">
    <v-card-text class="pa-1">
      <markdown :content="supplement.text" />

      <v-row align="center" justify="end" class="py-1 pr-2">
        <span class="caption mr-2 mt-0">{{ supplement.createdAtShort }}</span>

        <delete-button
          v-if="isStaff"
          :start-at-msec="Date.parse(supplement.createdAt)"
          :disabled="deleteButtonDisabled"
          color="error"
          class="mb-0 mr-1"
          @click="destroy"
        />
      </v-row>
    </v-card-text>
  </v-card>
</template>
<script>
import orm from '~/orm'
import DeleteButton from '~/components/commons/DeleteButton'
import Markdown from '~/components/commons/Markdown'

export default {
  name: 'SupplementCard',
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

      await orm.Mutation.deleteProblemSupplement({
        action: '補足削除',
        params: { problemSupplementId: this.supplement.id }
      })

      this.deleteButtonDisabled = false
    }
  }
}
</script>
