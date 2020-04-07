<template>
  <v-row no-gutters>
    <narrow-text-field
      :value="value"
      :readonly="readonly"
      @input="$emit('input', $event)"
      @keyup.up="$emit('order-up')"
      @keyup.down="$emit('order-down')"
      @keyup.enter="!value && $emit('delete')"
    />

    <icon-button
      :disabled="readonly"
      icon="mdi-arrow-up"
      @click="$emit('order-up')"
    />
    <icon-button
      :disabled="readonly"
      icon="mdi-arrow-down"
      @click="$emit('order-down')"
    />
    <icon-button
      :disabled="readonly"
      icon="mdi-delete"
      @click="$emit('delete')"
    />
  </v-row>
</template>
<script>
import IconButton from '~/components/misc/ProblemModal/NewCandidatesIconButton'
import NarrowTextField from '~/components/misc/ProblemModal/NewCandidatesNarrowTextField'

export default {
  name: 'NewCandidatesItemField',
  components: {
    NarrowTextField,
    IconButton,
  },
  props: {
    value: {
      type: String,
      required: true,
    },
    readonly: {
      type: Boolean,
      required: true,
    },
  },
}
</script>
