<template>
  <v-card-actions>
    <v-btn
      right
      :disabled="sending || !edited"
      color="warning"
      @click="$emit('click-reset')"
    >
      リセット
    </v-btn>

    <v-spacer />

    <v-btn
      left
      :disabled="!valid"
      :loading="sending"
      color="success"
      @click="$emit('click-submit')"
    >
      {{ isNew ? '追加' : '更新' }}
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
  }
}
</script>
