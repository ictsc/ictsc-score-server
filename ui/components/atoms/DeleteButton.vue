<template>
  <v-btn small fab :color="color" elevation="0">
    <v-progress-circular v-if="expire" :color="color" rotate="270" value="0" />
    <v-icon dense color="white" style="position: absolute">mdi-delete</v-icon>
  </v-btn>
</template>
<script>
export default {
  // TODO: イベントとカウントダウンは未実装
  // 削除猶予はcontestからとってくる
  name: 'DeleteButton',
  props: {
    color: {
      type: String,
      required: true
    },
    expire: {
      type: Boolean,
      default: false
    }
  }
}
</script>
