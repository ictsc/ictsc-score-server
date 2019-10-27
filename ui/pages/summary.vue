<template>
  <v-container>
    <v-row justify="center" class="pt-0">
      <v-col cols="auto" align="center">
        <page-title title="状況" />
      </v-col>
    </v-row>
  </v-container>
</template>
<script>
import PageTitle from '~/components/commons/PageTitle'

export default {
  name: 'Summary',
  components: {
    PageTitle
  }
}
</script>
