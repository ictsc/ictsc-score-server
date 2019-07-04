<template>
  <div>
    <h2>問題詳細 {{ problemId }}</h2>
    <h2>モード {{ mode }}</h2>
    <!-- problem-details をマウントする -->
    <!-- problem-issues,answers をマウントする -->

    <h2>チーム {{ teamId }}</h2>
    <nuxt-child />
  </div>
</template>

<script>
const MODE_REGEXP = /^#(issues|answers)(=(.*))?$/

export default {
  name: 'Problem',
  computed: {
    mode() {
      // URL末尾の #issues=:team_id からモードを判定する
      const match = MODE_REGEXP.exec(this.$route.hash)
      return match === null ? null : match[1]
    },
    problemId() {
      return this.$route.params.problem_id
    },
    teamId() {
      const match = MODE_REGEXP.exec(this.$route.hash)

      if (match !== null) {
        return match[3]
      } else if (this.isPlayer) {
        // TODO: storeから自分のチームIDを戻したい
        return ''
      } else {
        return null
      }
    }
  }
}
</script>
