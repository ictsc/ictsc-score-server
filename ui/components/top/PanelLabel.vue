<template>
  <div>
    <v-row justify="center">
      <div class="headline">{{ label }}</div>
      <slot />
    </v-row>

    <v-divider class="mt-2 mb-4" />
  </div>
</template>
<script>
export default {
  name: 'PanelLabel',
  props: {
    label: {
      type: String,
      required: true
    }
  }
}
</script>
