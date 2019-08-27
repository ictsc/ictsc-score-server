<template>
  <v-container>
    <v-layout column>
      <v-flex>
        <v-layout column align-center>
          <page-title title="チーム一覧" />
        </v-layout>
      </v-flex>
    </v-layout>
  </v-container>
</template>
<script>
import PageTitle from '~/components/atoms/PageTitle'

export default {
  name: 'Teams',
  components: {
    PageTitle
  }
}
</script>
<style scoped lang="sass"></style>
