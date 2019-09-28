<template>
  <div>
    <expandable-button
      v-model="show"
      :togglable="!isPlayer"
      :maximum-open="isStaff"
    >
      問題環境
      <v-text-field
        v-if="isStaff && show"
        v-model="search"
        autofocus
        clearable
        class="pb-1 pl-4"
        label="Search"
        append-icon="mdi-table-search"
        single-line
        hide-details
        @click.stop=""
        @keyup.space.prevent=""
      />
    </expandable-button>
    <v-expand-transition>
      <!-- :searchは文字列な必要がある、searchはtextareaで文字列のみ入るため!!で判定できる -->
      <environment-table
        v-show="show"
        :environments="environments"
        :search="!!search ? search : ''"
        class="mt-1"
      />
    </v-expand-transition>
  </div>
</template>
<script>
import ExpandableButton from '~/components/commons/ExpandableButton'
import EnvironmentTable from '~/components/problems/id/EnvironmentTable'

export default {
  name: 'EnvironmentArea',
  components: {
    ExpandableButton,
    EnvironmentTable
  },
  props: {
    environments: {
      type: Array,
      required: true
    }
  },
  data() {
    return {
      search: '',
      show: true
    }
  },
  created() {
    this.show = this.isPlayer
  }
}
</script>
