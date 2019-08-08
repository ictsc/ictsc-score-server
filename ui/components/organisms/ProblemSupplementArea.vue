<template>
  <v-layout column>
    <v-flex>
      <expandable-button v-model="show" :togglable="supplements.length !== 0">
        補足事項
      </expandable-button>
      <v-btn
        v-if="isStaff"
        x-small
        fab
        color="white"
        elevation="2"
        @click.stop="newSupplementShow = true"
      >
        <v-icon>mdi-pen</v-icon>
      </v-btn>
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
      :open.sync="newSupplementShow"
      :succeeded.sync="newSupplementSucceeded"
      :sending="newSupplementSending"
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
import ExpandableButton from '~/components/molecules/ExpandableButton'
import ProblemSupplementSheet from '~/components/molecules/ProblemSupplementSheet'
import MarkdownEditorModal from '~/components/organisms/MarkdownEditorModal'

export default {
  name: 'ProblemSupplementArea',
  components: {
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
      newSupplementShow: false,
      newSupplementSending: false,
      newSupplementSucceeded: false,
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
      this.newSupplementSending = true

      await orm.ProblemSupplement.addProblemSupplement({
        action: '補足追加',
        resolve: () => (this.newSupplementSucceeded = true),
        params: {
          problemCode: this.problemCode,
          text
        }
      })

      this.newSupplementSending = false
    }
  }
}
</script>
