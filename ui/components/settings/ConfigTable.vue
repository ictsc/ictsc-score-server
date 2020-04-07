<template>
  <v-data-table
    :items="configs"
    :headers="headers"
    :mobile-breakpoint="0"
    item-key="key"
    sort-by="key"
    hide-default-header
    hide-default-footer
    disable-pagination
    dense
    class="elevation-2 ma-0"
  >
    <template v-slot:item.action="{ item }">
      <config-modal :config="item">
        <template v-slot:activator="{ on }">
          <v-btn icon x-small @click="on">
            <v-icon small>mdi-pen</v-icon>
          </v-btn>
        </template>
      </config-modal>
    </template>

    <template v-slot:item.value="{ item }">
      <div class="text-truncate" style="width: 14em;">
        {{ item.displayValue }}
      </div>
    </template>
  </v-data-table>
</template>
<script>
import orm from '~/orm'
import ConfigModal from '~/components/misc/ConfigModal'

export default {
  name: 'ConfigTable',
  components: {
    ConfigModal,
  },
  data() {
    return {
      headers: [
        { text: 'action', value: 'action', sortable: false },
        { text: '名前', value: 'key' },
        { text: '値', value: 'value' },
      ],
    }
  },
  computed: {
    configs() {
      return orm.Config.all()
    },
  },
  beforeCreate() {
    orm.Queries.configs()
  },
}
</script>
