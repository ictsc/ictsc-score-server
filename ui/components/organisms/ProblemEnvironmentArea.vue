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
      <problem-environment-table
        v-show="show"
        :environments="environments"
        :search="search"
        class="mt-1"
      />
    </v-expand-transition>
  </div>
</template>
<script>
import ExpandableButton from '~/components/molecules/ExpandableButton'
import ProblemEnvironmentTable from '~/components/molecules/ProblemEnvironmentTable'

export default {
  name: 'ProblemEnvironmentArea',
  components: {
    ExpandableButton,
    ProblemEnvironmentTable
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
<style scoped lang="sass"></style>
