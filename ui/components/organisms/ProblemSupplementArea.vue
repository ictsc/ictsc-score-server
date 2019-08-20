<template>
  <v-layout column>
    <v-flex>
      <expandable-button v-model="show" :togglable="supplements.length !== 0">
        補足事項
      </expandable-button>

      <pen-button v-if="isStaff" @click.stop="showModal = true" />
    </v-flex>
    <!-- v-forとv-showで上手くアニメーションさせるためにv-flexをネストする -->
    <v-flex
      v-for="supplement in sortedSupplements"
      :key="supplement.id"
      class="pa-0"
    >
      <v-expand-transition>
        <v-flex v-show="show" class="pt-0">
          <problem-supplement-sheet :supplement="supplement" />
        </v-flex>
      </v-expand-transition>
    </v-flex>

    <markdown-editor-modal
      ref="modal"
      v-model="showModal"
      autofocus
      storage-key="newProblemSupplement"
      title="補足追加"
      submit-label="追加"
      :supplement="`追加後${deleteTimeLimitString}間は削除可能です`"
      @submit="addSupplement($event)"
    />
  </v-layout>
</template>
<script>
import { mapGetters } from 'vuex'
import orm from '~/orm'
import PenButton from '~/components/atoms/PenButton'
import ExpandableButton from '~/components/molecules/ExpandableButton'
import ProblemSupplementSheet from '~/components/molecules/ProblemSupplementSheet'
import MarkdownEditorModal from '~/components/organisms/MarkdownEditorModal'

export default {
  name: 'ProblemSupplementArea',
  components: {
    PenButton,
    ExpandableButton,
    MarkdownEditorModal,
    ProblemSupplementSheet
  },
  props: {
    // 補足追加に必要
    // staff以外ではundefinedになる
    problemCode: {
      type: String,
      default: undefined
    },
    supplements: {
      type: Array,
      required: true
    }
  },
  data() {
    return {
      showModal: false,
      show: true
    }
  },
  computed: {
    ...mapGetters('contestInfo', ['deleteTimeLimitString']),
    sortedSupplements() {
      return this.sortByCreatedAt(this.supplements)
    }
  },
  methods: {
    async addSupplement(text) {
      await orm.ProblemSupplement.addProblemSupplement({
        action: '補足追加',
        resolve: () => this.$refs.modal.succeeded(),
        params: {
          problemCode: this.problemCode,
          text
        }
      })

      this.$refs.modal.finished()
    }
  }
}
</script>
