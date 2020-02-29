<template>
  <div>
    <!-- 開くボタン -->
    <expandable-button v-model="show" :togglable="!isEmpty">
      接続情報
    </expandable-button>

    <!-- ペンボタン -->
    <pen-button v-if="isStaff" elevation="2" @click.stop="showModal = true" />

    <!-- テーブル -->
    <v-expand-transition>
      <environment-table
        v-show="show"
        :environments="environments"
        :problem="problem"
        class="mt-1"
      />
    </v-expand-transition>

    <!-- 追加モーダル -->
    <environment-modal
      v-if="showModal"
      v-model="showModal"
      :problem="problem"
      is-new
    />
  </div>
</template>
<script>
import EnvironmentModal from '~/components/misc/EnvironmentModal'
import EnvironmentTable from '~/components/problems/id/EnvironmentTable'
import ExpandableButton from '~/components/commons/ExpandableButton'
import PenButton from '~/components/commons/PenButton'

export default {
  name: 'EnvironmentArea',
  components: {
    EnvironmentModal,
    EnvironmentTable,
    ExpandableButton,
    PenButton
  },
  props: {
    problem: {
      type: Object,
      required: true
    },
    environments: {
      type: Array,
      required: true
    }
  },
  data() {
    return {
      search: '',
      show: true,
      showModal: false
    }
  },
  computed: {
    isEmpty() {
      return this.environments.length === 0
    }
  },
  watch: {
    isPlayer: {
      immediate: true,
      handler(value) {
        this.show = value
      }
    }
  }
}
</script>
