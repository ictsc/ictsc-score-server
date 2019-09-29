<template>
  <v-card-actions>
    <v-btn
      :disabled="sending || !edited"
      right
      color="warning"
      @click="$emit('click-reset')"
    >
      リセット
    </v-btn>

    <v-spacer />

    <v-btn
      :disabled="!valid || !edited"
      :loading="sending"
      :color="conflicted ? 'error' : 'success'"
      left
      @click="$emit('click-submit', conflicted)"
    >
      {{ submitText }}
    </v-btn>

    <v-btn left :disabled="sending" @click="$emit('click-cancel')">
      キャンセル
    </v-btn>
  </v-card-actions>
</template>
<script>
export default {
  name: 'ActionButtons',
  props: {
    isNew: {
      type: Boolean,
      default: false
    },
    conflicted: {
      type: Boolean,
      required: true
    },
    edited: {
      type: Boolean,
      required: true
    },
    sending: {
      type: Boolean,
      required: true
    },
    valid: {
      type: Boolean,
      required: true
    }
  },
  computed: {
    submitText() {
      if (this.isNew) {
        return '追加'
      }

      return this.conflicted ? '強制更新' : '更新'
    }
  }
}
</script>
