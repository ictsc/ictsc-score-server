<template>
  <div v-loading="asyncLoading">
    <h1>Entry no. {{ team.id }}</h1>
    <pre>{{ team }}</pre>
  </div>
</template>

<style scoped>

</style>

<script>
import { SET_TITLE } from '../store/'
import { API } from '../utils/Api'

export default {
  name: 'team-detail',
  data () {
    return {
    }
  },
  asyncData: {
    teamDefault: {},
    team () {
      return API.getTeam(this.id);
    }
  },
  computed: {
    id () {
      return this.$route.params.id;
    },
  },
  watch: {
  },
  mounted () {
    this.$store.dispatch(SET_TITLE, 'チーム詳細');
  },
  destroyed () {
  },
  methods: {
  },
}
</script>

