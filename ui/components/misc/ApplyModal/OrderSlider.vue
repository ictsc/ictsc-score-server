<template>
  <editable-slider
    :value="value"
    :readonly="readonly"
    :rules="rules"
    :max="500"
    :step="10"
    label="順序(昇順)"
    @input="$emit('input', $event)"
  >
    <template v-slot:bottom>
      <v-row dense justify="space-around" class="mb-1">
        <v-col cols="3" class="text-truncate">
          {{ ItemToString(prevItem) }}
        </v-col>

        <v-col cols="3" class="text-truncate">
          {{ ItemToString(sameItem) }}
        </v-col>

        <v-col cols="3" class="text-truncate">
          {{ ItemToString(nextItem) }}
        </v-col>
      </v-row>
    </template>
  </editable-slider>
</template>
<script>
import EditableSlider from '~/components/commons/EditableSlider'

export default {
  name: 'OrderSlider',
  components: {
    EditableSlider
  },
  props: {
    // v-model
    value: {
      type: Number,
      required: true
    },
    readonly: {
      type: Boolean,
      default: false
    },
    items: {
      type: Array,
      required: true
    },
    titleParam: {
      type: String,
      required: true
    },
    selfId: {
      type: String,
      default: null
    }
  },
  data() {
    return {
      rules: [v => !Number.isNaN(parseInt(v)) || '必須']
    }
  },
  computed: {
    prevItem() {
      const index = this.$_.findLastIndex(
        this.items,
        v => v.order < this.value && this.selfId !== v.id
      )
      return this.items[index]
    },
    sameItem() {
      return this.items.find(
        v => v.order === this.value && this.selfId !== v.id
      )
    },
    nextItem() {
      return this.items.find(v => this.value < v.order && this.selfId !== v.id)
    }
  },
  methods: {
    ItemToString(item) {
      if (!item) {
        return 'なし'
      }

      return `(${item.order}) ${this.$elvis(item, this.titleParam)}`
    }
  }
}
</script>
