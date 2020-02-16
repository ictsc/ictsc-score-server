<template>
  <div>
    <expandable-button v-model="show" :togglable="isStaff">
      接続情報
    </expandable-button>
    <v-expand-transition>
      <environment-table
        v-show="show"
        :environments="environments"
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
