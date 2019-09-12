<template>
  <v-container>
    <v-layout column>
      <v-flex>
        <v-layout column align-center>
          <page-title title="ガイド" />
          <markdown :content="guidePage" />
        </v-layout>
      </v-flex>
    </v-layout>
  </v-container>
</template>
<script>
import { mapGetters } from 'vuex'
import Markdown from '~/components/commons/Markdown'
import PageTitle from '~/components/commons/PageTitle'

export default {
  name: 'Guide',
  components: {
    Markdown,
    PageTitle
  },
  computed: {
    ...mapGetters('contestInfo', ['guidePage'])
  }
}
</script>
