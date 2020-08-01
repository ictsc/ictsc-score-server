<template>
  <v-card class="elevation-2">
    <v-card-text class="px-1 py-0">
      <markdown :content="supplement.text" class="pb-0" />

      <v-row align="center" justify="end" class="py-0 pr-2">
        <span class="caption mr-2">{{ supplement.createdAtShort }}</span>

        <countdown-delete-button
          v-if="isStaff"
          :item="supplement"
          :submit="destroy"
        />
      </v-row>
    </v-card-text>
  </v-card>
</template>
<script>
import orm from '~/orm'
import CountdownDeleteButton from '~/components/commons/CountdownDeleteButton'
import Markdown from '~/components/commons/Markdown'

export default {
  name: 'SupplementCard',
  components: {
    CountdownDeleteButton,
    Markdown,
  },
  props: {
    supplement: {
      type: Object,
      required: true,
    },
  },
  methods: {
    async destroy() {
      await orm.Mutations.deleteProblemSupplement({
        action: '補足削除',
        params: { problemSupplementId: this.supplement.id },
      })
    },
  },
}
</script>
