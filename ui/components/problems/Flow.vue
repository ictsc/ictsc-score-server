<template>
  <v-container>
    <v-row justify="center" class="grey lighten-3 flex-nowrap">
      <v-col cols="3" class="py-0">
        <flow-item
          title="問題を選んで解答"
          body="問題を選択し解答を行ってください"
        />
      </v-col>

      <v-col cols="auto" class="arrow px-0" />

      <v-col cols="3" class="py-0">
        <flow-item
          :title="`運営が採点 (最速${gradingDelayString})`"
          :body="`解答後${gradingDelayString}間は再解答できません`"
        />
      </v-col>

      <v-col cols="auto" class="arrow px-0" />

      <v-col cols="3" class="py-0">
        <flow-item
          title="採点結果を確認"
          body="高得点を目指して追加の解答も可能です"
        />
      </v-col>
    </v-row>
  </v-container>
</template>
<script>
import { mapGetters } from 'vuex'
import FlowItem from '~/components/problems/FlowItem'

export default {
  name: 'Flow',
  components: {
    FlowItem
  },
  computed: {
    ...mapGetters('contestInfo', ['gradingDelayString'])
  }
}
</script>

<style scoped lang="sass">
.arrow
  min-width: 4rem
  background-image: url('~assets/img/arrow.svg')
</style>
