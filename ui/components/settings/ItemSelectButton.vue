<template>
  <v-row align="center">
    <v-overflow-btn
      v-model="internalValue"
      :label="label"
      :loading="fetching"
      :items="items"
      :item-text="itemText"
      return-object
      auto-select-first
      clearable
      editable
      dense
      hide-details
      @focus="fetchItems"
      @input="updateItem"
    />

    <!--
      ApplyModal系などを想定
      v-ifで毎回強制再描画することで、モーダルの閉じ開きを再現する
    -->
    <slot
      v-if="item !== undefined"
      :item="item"
      :is-new="item.title === newItemTextValue"
    />
  </v-row>
</template>
<script>
export default {
  name: 'ItemSelectButton',
  props: {
    label: {
      type: String,
      required: true,
    },
    itemText: {
      type: String,
      required: true,
    },
    fetch: {
      type: Function,
      required: true,
    },
    prependNewItem: {
      type: Boolean,
      default: true,
    },
  },
  data() {
    return {
      fetching: false,
      internalValue: undefined,
      item: undefined,
      items: [],
      newItemTextValue: '新規作成',
    }
  },
  methods: {
    async fetchItems() {
      if (this.items.length !== 0) {
        return
      }

      this.fetching = true

      const items = await this.fetch()
      if (this.prependNewItem) {
        items.unshift({ [this.itemText]: this.newItemTextValue })
      }
      this.items = items

      this.fetching = false
    },
    updateItem() {
      // 同じものを再選択した場合にモーダルが再度開くようにする
      this.item = undefined
      this.$nextTick(() => (this.item = this.internalValue))
    },
  },
}
</script>
