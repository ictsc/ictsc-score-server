<template>
  <div>
    <ul class="nav nav-tabs">
      <li class="nav-item">
        <router-link :to="{name: 'problem-issues', params: {id: problemId, team: teamId}}" class="nav-link" active-class="active">
          質問
        </router-link>
      </li>
      <li class="nav-item">
        <router-link :to="{name: 'problem-answers', params: {id: problemId, team: teamId}}" class="nav-link"  active-class="active">
          解答
        </router-link>
      </li>
    </ul>
  </div>
</template>

<style scoped>
.nav {
  margin: 1rem 0 3rem;
}
</style>

<script>
import { SET_TITLE } from '../store/'

export default {
  name: 'problem-mode-switch',
  props: {
    problemId: String,
    teamId: String,
  },
  data () {
    return {
    }
  },
  asyncData: {
  },
  computed: {
  },
  watch: {
  },
  mounted () {
    this.$store.dispatch(SET_TITLE, 'ページ名');
  },
  destroyed () {
  },
  methods: {
  },
}
</script>

