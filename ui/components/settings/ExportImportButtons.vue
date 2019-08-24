<template>
  <div class="ma-1">
    <label>{{ label }}</label>

    <v-row class="ma-0">
      <!-- 毎回全取得し直すloading -->
      <v-btn :loading="loading" small @click="exportYAML">
        エクスポート
        <v-icon>mdi-file-export</v-icon>
      </v-btn>

      <div class="mx-1" />

      <!-- モーダルを開く -->
      <v-btn :disabled="loading" small @click.stop="showModal = true">
        インポート
        <v-icon>mdi-file-import</v-icon>
      </v-btn>
    </v-row>

    <!-- インポートモーダル -->
    <import-modal
      v-model="showModal"
      :label="label"
      :fields="fields"
      :apply="apply"
    />
  </div>
</template>
<script>
import YAML from 'js-yaml'
import ImportModal from '~/components/settings/ImportModal'

export default {
  name: 'ListExportImportButtons',
  components: {
    ImportModal
  },
  props: {
    label: {
      type: String,
      required: true
    },
    apply: {
      type: Function,
      required: true
    },
    fetch: {
      type: Function,
      required: true
    },
    fields: {
      type: Array,
      required: true
    }
  },
  data() {
    return {
      showModal: false,
      loading: false
    }
  },
  methods: {
    async exportYAML() {
      const items = await this.fetch()
      const filtered = items.map(o => this.filterField(o))
      const yaml = YAML.safeDump(filtered)
      this.download('text/yaml', `${this.label}.yml`, yaml)
    },
    filterField(item) {
      return this.fields.reduce((obj, key) => {
        // YAMLはundefinedを扱えない
        obj[key] = item[key] === undefined ? null : item[key]
        return obj
      }, {})
    }
  }
}
</script>
