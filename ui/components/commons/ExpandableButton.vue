<template>
  <v-btn
    small
    :color="color"
    class="pl-2 pr-2"
    :width="volume"
    :height="volume"
    @click="click"
  >
    <template v-if="togglable">
      <up-down-arrow :opened="opened" />
    </template>
    <slot />
  </v-btn>
</template>
<script>
import UpDownArrow from '~/components/commons/UpDownArrow'

// クリックで開く・閉じるがトグルするボタン
export default {
  name: 'ExpandableButton',
  components: {
    UpDownArrow
  },
  model: {
    prop: 'opened',
    event: 'click'
  },
  props: {
    // v-model
    opened: {
      type: Boolean,
      required: false
    },
    // 矢印が消え、クリックイベントも停止する
    togglable: {
      type: Boolean,
      default: true
    },
    // trueなら最大化する
    maximum: {
      type: Boolean,
      default: false
    },
    // 展開時に最大化する
    maximumOpen: {
      type: Boolean,
      default: false
    },
    color: {
      type: String,
      default: 'white'
    }
  },
  computed: {
    volume() {
      if (this.maximum || (this.maximumOpen && this.opened)) {
        return '100%'
      } else {
        return ''
      }
    }
  },
  methods: {
    click() {
      if (this.togglable) {
        this.$emit('click', !this.opened)
      }
    }
  }
}
</script>
