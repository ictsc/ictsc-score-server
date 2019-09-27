<template>
  <v-row align="center">
    <v-select
      v-model="internalValue"
      :loading="fetching"
      :label="label"
      :items="items"
      :item-text="itemText"
      return-object
      clearable
      hide-defaults
      class="ml-4"
      @focus="fetchItems"
      @input="updateItem"
    />

    <!--
      ApplyModal系を想定
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
  name: 'ApplyButton',
  props: {
    label: {
      type: String,
      required: true
    },
    itemText: {
      type: String,
      required: true
    },
    fetch: {
      type: Function,
      required: true
    }
  },
  data() {
    return {
      modal: true,
      fetching: false,
      internalValue: undefined,
      item: undefined,
      items: [],
      newItemTextValue: '新規作成'
    }
  },
  methods: {
    async fetchItems() {
      if (this.items.length !== 0) {
        return
      }

      this.fetching = true

      const items = await this.fetch()
      items.unshift({ [this.itemText]: this.newItemTextValue })
      this.items = items

      this.fetching = false
    },
    updateItem() {
      // 同じものを再選択した場合にモーダルが再度開くようにする
      this.item = undefined
      this.$nextTick(() => (this.item = this.internalValue))
    }
  }
}
</script>
