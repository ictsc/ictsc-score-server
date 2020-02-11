<template>
  <v-card elevation="4">
    <v-card-title class="py-1 px-2">
      <v-row align="center" class="ml-0">
        <!-- タイトル -->
        <span class="subtitle-1">
          {{ notice.title }}
        </span>

        <v-spacer />

        <!-- ピン -->
        <pin-button
          v-if="isStaff"
          class="mr-1"
          :value="notice.pinned"
          @click="pinned"
        />
        <v-icon v-else-if="notice.pinned" class="mr-2">
          mdi-pin
        </v-icon>
      </v-row>
    </v-card-title>
    <v-divider />

    <v-card-text class="pa-1">
      <!-- 宛先 -->
      <v-chip v-if="notice.targetTeam" small label class="ml-2">
        宛先
        <v-divider vertical class="mx-1" />
        {{ notice.targetTeam.displayName }}
      </v-chip>

      <!-- 本文 -->
      <markdown :content="notice.text" />
    </v-card-text>

    <!-- 投稿時刻, 削除ボタン -->
    <v-row align="center" justify="end" class="pb-1 pr-5">
      <span class="caption">
        {{ notice.createdAtShort }}
      </span>
      <delete-button
        v-if="isStaff"
        :start-at-msec="Date.parse(notice.createdAt)"
        :disabled="sending"
        color="grey lighten-1"
        class="ml-2"
        @click="destroy"
      />
    </v-row>
  </v-card>
</template>
<script>
import orm from '~/orm'
import PinButton from '~/components/commons/PinButton'
import DeleteButton from '~/components/commons/DeleteButton'
import Markdown from '~/components/commons/Markdown'

export default {
  name: 'NoticeCard',
  components: {
    DeleteButton,
    Markdown,
    PinButton
  },
  props: {
    notice: {
      type: Object,
      required: true
    }
  },
  data() {
    return {
      sending: false
    }
  },
  methods: {
    async pinned() {
      this.sending = true

      await orm.Mutations.pinNotice({
        action: 'お知らせのピン変更',
        params: { noticeId: this.notice.id, pinned: !this.notice.pinned }
      })

      this.sending = false
    },

    async destroy() {
      this.sending = true

      await orm.Mutations.deleteNotice({
        action: 'お知らせ削除',
        params: { noticeId: this.notice.id }
      })

      this.sending = false
    }
  }
}
</script>
