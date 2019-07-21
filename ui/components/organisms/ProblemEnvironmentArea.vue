<template>
  <div>
    <openable-button
      v-model="show"
      :togglable="!isPlayer"
      :maximum-open="isStaff"
      class="mb-1"
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
    </openable-button>
    <v-slide-y-transition>
      <problem-environment-table
        v-if="show"
        :environments="environments"
        :search="search"
      />
    </v-slide-y-transition>
  </div>
</template>
<script>
import OpenableButton from '~/components/atoms/OpenableButton'
import ProblemEnvironmentTable from '~/components/molecules/ProblemEnvironmentTable'

export default {
  name: 'ProblemEnvironmentArea',
  components: {
    OpenableButton,
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
  mounted() {
    this.show = this.isPlayer
  }
}
</script>
<style scoped lang="sass"></style>
