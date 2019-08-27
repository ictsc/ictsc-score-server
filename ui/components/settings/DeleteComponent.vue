<template>
  <div>
    <v-row align="center">
      <v-select
        v-model="selectedValue"
        :loading="fetching"
        :readonly="sending"
        :items="items"
        :rules="requiredRules"
        clearable
        hide-defaults
        item-text="title"
        :item-value="itemValue"
        :label="label"
        @focus="fetchItems"
      />
      <v-btn
        :disabled="!selectedValue || fetching"
        class="ml-8"
        @click.stop="showDialog = true"
      >
        削除
        <v-icon>mdi-delete</v-icon>
      </v-btn>
    </v-row>

    <v-dialog v-model="showDialog" max-width="20em">
      <v-card>
        <v-card-text class="title">
          本当に削除しますか?
        </v-card-text>

        <v-card-actions>
          <div class="flex-grow-1"></div>

          <v-btn
            color="error"
            :loading="sending"
            class="mr-4"
            @click="deleteStart"
          >
            削除
          </v-btn>

          <v-btn :disabled="sending" @click="showDialog = false">
            キャンセル
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </div>
</template>
<script>
export default {
  name: 'DeleteComponent',

  props: {
    label: {
      type: String,
      required: true
    },
    fetch: {
      type: Function,
      required: true
    },
    delete: {
      type: Function,
      required: true
    },
    itemValue: {
      type: String,
      required: true
    }
  },
  data() {
    return {
      showDialog: false,
      selectedValue: null,
      fetching: false,
      sending: false,
      items: []
    }
  },
  methods: {
    async fetchItems() {
      if (this.items.length !== 0) {
        return
      }

      this.fetching = true

      this.items = await this.fetch()
      this.fetching = false
    },
    async deleteStart() {
      this.sending = true

      if (await this.delete(this.selectedValue)) {
        this.showDialog = false
        this.selectedValue = null
      }

      this.sending = false
    }
  }
}
</script>
