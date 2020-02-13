<template>
  <v-card elevation="4">
    <v-card-title class="py-1 px-3">
      <v-row align="center" class="ml-0 flex-nowrap">
        <!-- タイトル -->
        <div class="subtitle-1 pr-2">
          {{ notice.title }}
        </div>

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

    <v-card-text class="px-3 py-2">
      <!-- 宛先 -->
      <v-chip v-if="notice.targetTeam" small label class="mb-2">
        宛先
        <v-divider vertical class="mx-1" />
        <div class="text-truncate">
          {{ notice.targetTeam.displayName }}
        </div>
      </v-chip>

      <!-- 投稿時刻, 削除ボタン -->
      <v-row align="center" class="pb-1 px-3">
        <div class="caption">{{ notice.createdAtShort }}</div>

        <v-spacer />

        <delete-button
          v-if="isStaff"
          :start-at-msec="Date.parse(notice.createdAt)"
          :disabled="sending"
          color="grey "
          class="ml-2"
          @click="destroy"
        />
      </v-row>

      <!-- 本文 -->
      <markdown :content="notice.text" dense />
    </v-card-text>
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
