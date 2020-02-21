<template>
  <v-dialog
    :value="value"
    max-width="80%"
    :persistent="sending"
    scrollable
    @input="!$event && close()"
  >
    <v-card>
      <v-card-title> {{ label }} インポート </v-card-title>

      <v-card-text>
        <!-- 読み込みフォーム -->
        <v-form ref="form">
          <v-row align="center">
            <v-file-input v-model="file" label="YAML file input" clearable />
          </v-row>
        </v-form>

        <!-- フィールド一覧 -->
        <v-data-table
          v-model="selectedItems"
          :headers="headers"
          :items="items"
          :mobile-breakpoint="0"
          disable-pagination
          show-select
          item-key="__index"
          hide-default-footer
          dense
          multi-sort
          class="elevation-1 text-no-wrap"
        >
          <!-- インポート状態 -->
          <template v-slot:item.__applyStatus="{ value: statusValue }">
            <v-progress-circular
              v-if="statusValue === 'applying'"
              size="20"
              width="2"
              indeterminate
              color="cyan"
            />
            <v-icon v-else-if="statusValue === 'pending'" color="warning">
              mdi-clock-outline
            </v-icon>
            <v-icon v-else-if="statusValue === 'succeeded'" color="success">
              mdi-check
            </v-icon>
            <v-icon v-else-if="statusValue === 'failed'" color="error">
              mdi-alert-circle-outline
            </v-icon>
            <v-icon v-else-if="statusValue === 'none'" />
          </template>
        </v-data-table>
      </v-card-text>

      <v-card-actions>
        <v-btn :disabled="sending || !file" color="warning" @click="reset">
          リセット
        </v-btn>

        <v-spacer />
        <v-btn
          :disabled="!valid"
          :loading="sending"
          color="success"
          @click.stop="startApply"
        >
          インポート
        </v-btn>
        <v-btn :disabled="sending" @click="close">
          キャンセル
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>
<script>
import YAML from 'js-yaml'

export default {
  name: 'ImportModal',
  props: {
    // v-model
    value: {
      type: Boolean,
      required: true
    },
    label: {
      type: String,
      default: undefined
    },
    apply: {
      type: Function,
      required: true
    },
    fields: {
      type: Array,
      required: true
    },
    parallel: {
      type: Boolean,
      required: true
    }
  },
  data() {
    return {
      sending: false,
      file: null,
      items: [],
      selectedItems: []
    }
  },
  computed: {
    headers() {
      const applyHeader = {
        text: '',
        value: '__applyStatus',
        align: 'center',
        width: '5em'
      }
      const headers = this.fields.map(o => ({ text: o, value: o }))
      return [applyHeader, ...headers]
    },
    valid() {
      return this.selectedItems.length !== 0
    }
  },
  watch: {
    file(value) {
      // valueは[Observer]な可能性がある
      if (value instanceof File) {
        this.items = []
        this.selectedItems = []
        this.loadFile(value)
      } else {
        this.items = []
        this.selectedItems = []
      }
    }
  },
  methods: {
    importYAML(text) {
      const items = YAML.safeLoad(text)

      items.forEach((o, i) => {
        o.__applyStatus = 'none'
        o.__index = i
      })

      this.items = items
    },
    loadFile(file) {
      const reader = new FileReader()
      reader.onload = e => this.importYAML(e.target.result)
      reader.readAsText(file)
    },
    reset() {
      this.file = null
      this.items = []
      this.selectedItems = []
    },
    close() {
      this.$emit('input', false)
    },
    async applyItem(item) {
      item.__applyStatus = 'applying'
      item.__applyStatus = (await this.apply(item)) ? 'succeeded' : 'failed'
    },
    async startApply() {
      this.sending = true
      this.selectedItems.forEach(item => (item.__applyStatus = 'pending'))

      if (this.parallel) {
        await Promise.all(this.selectedItems.map(item => this.applyItem(item)))
      } else {
        // 直列実行のためにfor-of構文を使う
        for (const item of this.selectedItems) {
          await this.applyItem(item)
        }
      }

      let failCount = 0
      this.selectedItems.forEach(
        item => (failCount += item.__applyStatus === 'failed' ? 1 : 0)
      )

      if (failCount === 0) {
        this.notifySuccess({
          message: `全${this.selectedItems.length}件成功しました`
        })
      } else {
        this.notifyWarning({
          message: `${failCount}/${this.selectedItems.length}件失敗しました`
        })
      }

      this.selectedItems = []
      this.sending = false
    }
  }
}
</script>
