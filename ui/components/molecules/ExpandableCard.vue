<template>
  <v-card>
    <v-btn block :color="color" @click="$emit('click', !opened)">
      <up-down-chevron :opened="opened" />
      <slot name="button" />
    </v-btn>

    <v-expand-transition>
      <v-card-text v-show="opened">
        <slot />
      </v-card-text>
    </v-expand-transition>
  </v-card>
</template>
<script>
import UpDownChevron from '~/components/atoms/UpDownChevron'

export default {
  name: 'ExpandableCard',
  components: {
    UpDownChevron
  },
  model: {
    prop: 'opened',
    event: 'click'
  },
  props: {
    opened: {
      type: Boolean,
      required: true
    },
    color: {
      type: String,
      default: 'white'
    }
  }
}
</script>
