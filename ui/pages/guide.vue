<template>
  <v-container>
    <v-layout column>
      <v-flex>
        <v-layout column align-center>
          <page-title title="ガイド" />
        </v-layout>
      </v-flex>
    </v-layout>
  </v-container>
</template>
<script>
import PageTitle from '~/components/atoms/PageTitle'

export default {
  name: 'Guide',
  components: {
    PageTitle
  }
}
</script>
