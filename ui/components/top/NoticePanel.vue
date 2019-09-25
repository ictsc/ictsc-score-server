<template>
  <!-- TODO: 一時的にelevationを消して背景と同一化させる -->
  <v-sheet elevation="0">
    <v-container fluid>
      <v-row justify="center">
        <div class="headline">お知らせ</div>

        <pen-button
          v-if="isStaff"
          class="ml-2"
          @click.stop="showModal = true"
        />
      </v-row>

      <v-divider class="mt-2 mb-4" />

      <!-- お知らせ一覧 -->
      <template v-if="notices.length !== 0">
        <notice-card
          v-for="notice in notices"
          :key="notice.id"
          :notice="notice"
          class="mb-3"
        />
      </template>

      <!-- お知らせなし -->
      <div v-else class="grey--text text-center title">
        <template v-if="fetching">
          読み込み中
        </template>
        <template v-else>
          お知らせはありません
        </template>
      </div>
    </v-container>

    <notice-modal v-if="isStaff" v-model="showModal" />
  </v-sheet>
</template>
<script>
import orm from '~/orm'
import PenButton from '~/components/commons/PenButton'
import NoticeCard from '~/components/top/NoticeCard'
import NoticeModal from '~/components/top/NoticeModal'

export default {
  name: 'NoticePanel',
  components: {
    NoticeCard,
    NoticeModal,
    PenButton
  },
  data() {
    return {
      showModal: false,
      fetching: false
    }
  },
  computed: {
    notices() {
      const sorted = this.sortByCreatedAt(
        orm.Notice.query()
          .with('targetTeam')
          .all()
      ).reverse()

      return sorted.filter(o => o.pinned).concat(sorted.filter(o => !o.pinned))
    }
  },
  // なぜかfetch()だと呼ばれない
  async created() {
    try {
      this.fetching = true
      await orm.Notice.eagerFetch({}, ['targetTeam'])
    } finally {
      this.fetching = false
    }
  }
}
</script>
