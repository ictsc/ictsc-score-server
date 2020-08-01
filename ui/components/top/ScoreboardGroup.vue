<template>
  <div>
    <scoreboard-card
      v-for="(scoreboard, index) in scoreboards"
      :key="index"
      :scoreboard="scoreboard"
      class="mb-3"
    >
    </scoreboard-card>
  </div>
</template>
<script>
import ScoreboardCard from '~/components/top/ScoreboardCard'

export default {
  name: 'ScoreboardGroup',
  components: {
    ScoreboardCard,
  },
  props: {
    scoreboards: {
      type: Array,
      required: true,
    },
  },
}
</script>
