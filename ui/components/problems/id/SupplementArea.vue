<template>
  <v-col align="start" class="pa-0">
    <div>
      <plus-button
        v-if="isStaff"
        color="primary"
        elevation="2"
        class="mr-1"
        @click.stop="showModal = true"
      />

      <expandable-button v-model="show" :togglable="supplements.length !== 0">
        補足事項
      </expandable-button>
    </div>

    <template v-for="supplement in sortedSupplements">
      <v-expand-transition :key="supplement.id">
        <supplement-card v-show="show" :supplement="supplement" class="mt-1" />
      </v-expand-transition>
    </template>

    <markdown-editor-modal
      ref="modal"
      v-model="showModal"
      autofocus
      storage-key="newProblemSupplement"
      title="補足追加"
      submit-label="追加"
      @submit="addSupplement($event)"
    />
  </v-col>
</template>
<script>
import orm from '~/orm'
import PlusButton from '~/components/commons/PlusButton'
import ExpandableButton from '~/components/commons/ExpandableButton'
import SupplementCard from '~/components/problems/id/SupplementCard'
import MarkdownEditorModal from '~/components/commons/MarkdownEditorModal'

export default {
  name: 'SupplementArea',
  components: {
    PlusButton,
    ExpandableButton,
    MarkdownEditorModal,
    SupplementCard,
  },
  props: {
    // 補足追加に必要
    // staff以外ではundefinedになる
    problemCode: {
      type: String,
      default: undefined,
    },
    supplements: {
      type: Array,
      required: true,
    },
  },
  data() {
    return {
      showModal: false,
      show: true,
    }
  },
  computed: {
    sortedSupplements() {
      return this.sortByCreatedAt(this.supplements)
    },
  },
  methods: {
    async addSupplement(text) {
      await orm.Mutations.addProblemSupplement({
        action: '補足追加',
        resolve: () => this.$refs.modal.succeeded(),
        params: {
          problemCode: this.problemCode,
          text,
        },
      })
    },
  },
}
</script>
