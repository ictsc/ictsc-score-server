<template>
  <div v-loading="asyncLoading">
    <h1><small>Entry no. {{ team.id }} - {{ team.organization }}</small> {{ team.name }}</h1>
    <div class="members d-flex justify-content-around flex-wrap">
      <div v-for="member in team.members" class="item d-flex flex-column justify-content-center">
        <div class="name">{{ member.name }}</div>
        <div class="login">{{ member.login }}</div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.item {
  width: 10rem;
  height: 10rem;
  margin: 2rem;
  background: #ddd;
  text-align: center;
  border-radius: 50%;
  font-size: 1.2rem;
}
.item .name {
  font-size: 1.1em;
  font-weight: bold;
}
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

