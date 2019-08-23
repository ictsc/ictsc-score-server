<template>
  <v-container>
    <v-row justify="center">
      <!-- TODO: 仮の幅 -->
      <v-col style="max-width: 40em">
        <notice-panel />
      </v-col>
    </v-row>
  </v-container>
</template>
<script>
import NoticePanel from '~/components/organisms/NoticePanel'

export default {
  name: 'Index',
  head() {
    return {
      // TODO: 一時しのぎ
      // title: 'ダッシュボード'
      title: 'お知らせ'
    }
  },
  components: {
    NoticePanel
  }
}
</script>
