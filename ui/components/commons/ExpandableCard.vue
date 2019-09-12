<template>
  <v-card>
    <v-card-title class="pa-0">
      <v-btn block depressed :color="color" @click="$emit('click', !opened)">
        <up-down-chevron :opened="opened" />
        <slot name="button" />
      </v-btn>
    </v-card-title>
    <v-divider />

    <v-expand-transition>
      <v-card-text v-show="opened" class="py-1">
        <slot />
      </v-card-text>
    </v-expand-transition>
  </v-card>
</template>
<script>
import UpDownChevron from '~/components/commons/UpDownChevron'

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
