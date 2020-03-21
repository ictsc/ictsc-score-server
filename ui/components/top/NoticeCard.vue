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
          class="mr-2"
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
      <v-chip v-if="notice.team" small label class="mb-2">
        宛先
        <v-divider vertical class="mx-1" />
        <div class="text-truncate">
          {{ notice.team.displayName }}
        </div>
      </v-chip>

      <!-- 投稿時刻 -->
      <div class="pb-1 caption">{{ notice.createdAtShort }}</div>

      <!-- 本文 -->
      <markdown :content="notice.text" dense />

      <!-- 削除ボタン -->
      <v-row v-if="isStaff" justify="end" class="pb-0 pr-2">
        <countdown-delete-button :item="notice" :submit="destroy" />
      </v-row>
    </v-card-text>
  </v-card>
</template>
<script>
import orm from '~/orm'
import CountdownDeleteButton from '~/components/commons/CountdownDeleteButton'
import PinButton from '~/components/commons/PinButton'
import Markdown from '~/components/commons/Markdown'

export default {
  name: 'NoticeCard',
  components: {
    CountdownDeleteButton,
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
