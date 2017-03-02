<template>
  <div>
    <h1>メンバー一覧</h1>
    <table class="table table-striped">
      <thead>
        <tr>
          <th>#</th>
          <th>Name</th>
          <th>Login</th>
          <th>TeamID</th>
          <th>Role</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="member in members">
          <th>{{ member.id }}</th>
          <td>{{ member.name }}</td>
          <td>{{ member.login }}</td>
          <td>{{ member.team_id }}</td>
          <td>{{ member.role_id }}</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<style scoped>

</style>

<script>
import { SET_TITLE } from '../store/'
import { API } from '../utils/Api'

export default {
  name: 'members',
  data () {
    return {
    }
  },
  asyncData: {
    members () {
      return API.getMembers();
    }
  },
  computed: {
  },
  watch: {
  },
  mounted () {
    this.$store.dispatch(SET_TITLE, 'メンバー一覧');
  },
  destroyed () {
  },
  methods: {
  },
}
</script>

