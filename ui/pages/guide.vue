<template>
  <v-container fluid>
    <v-row justify="center" align="center">
      <page-title title="ガイド">
        <pen-button
          v-if="isStaff"
          :loading="!configGuidePage"
          x-small
          absolute
          class="ml-2 mb-4"
          @click="showModal = true"
        />
      </page-title>
    </v-row>

    <config-modal
      v-if="isStaff && !!configGuidePage"
      v-model="showModal"
      :config="configGuidePage"
    />

    <markdown :content="guidePage" />
  </v-container>
</template>
<script>
import { mapGetters } from 'vuex'
import orm from '~/orm'
import ConfigModal from '~/components/misc/ConfigModal'
import Markdown from '~/components/commons/Markdown'
import PageTitle from '~/components/commons/PageTitle'
import PenButton from '~/components/commons/PenButton'

export default {
  name: 'Guide',
  components: {
    ConfigModal,
    Markdown,
    PageTitle,
    PenButton
  },
  data() {
    return {
      showModal: false
    }
  },
  computed: {
    ...mapGetters('contestInfo', ['guidePage']),
    configGuidePage() {
      // 無理やりリアクティブ
      // eslint-disable-next-line no-unused-expressions
      this.fetchConfigs
      return orm.Config.find('guide_page')
    },

    // eslint-disable-next-line vue/return-in-computed-property
    fetchConfigs() {
      // isStaffがセットされたらクエリを発行する
      // mountedなどだとセッションが未取得な可能性がある
      if (this.isStaff) {
        orm.Config.eagerFetch({}, [])
      }
    }
  }
}
</script>
