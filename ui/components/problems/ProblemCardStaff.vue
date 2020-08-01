<!-- とりま staff audience共用 -->
<template>
  <v-card-text class="py-0 black--text">
    <div class="subtitle-1 text-truncate">
      {{ problem.title }}
    </div>

    <v-row no-gutters>
      <v-col>
        <div v-if="isStaff">コード {{ problem.code }}</div>
        <div v-if="isStaff" class="text-truncate">
          作問者 {{ problem.writer }}
        </div>
        <div class="body-2">満点 {{ problem.perfectPoint }}</div>
      </v-col>
    </v-row>
  </v-card-text>
</template>
<script>
export default {
  name: 'ProblemCardStaff',
  props: {
    hover: {
      type: Boolean,
      default: false,
    },
    problem: {
      type: Object,
      required: true,
    },
  },
}
</script>
