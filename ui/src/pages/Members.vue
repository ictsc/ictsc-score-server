<template>
  <div>
    <h1>メンバー一覧</h1>
    <table class="table table-striped">
      <thead>
        <tr>
          <th v-if="isAdmin || isWriter">#</th>
          <th>Name</th>
          <th>Login</th>
          <th>TeamID</th>
          <th v-if="isAdmin || isWriter">Role</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="member in members">
          <td v-if="isAdmin || isWriter">{{ member.id }}</td>
          <td>{{ member.name }}</td>
          <td>{{ member.login }}</td>
          <td>{{ member.team ? member.team.name : '--- None ---' }}</td>
          <td v-if="isAdmin || isWriter">{{ member.role_id }}</td>
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
import { mapGetters } from 'vuex'

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
    ...mapGetters([
      'isAdmin',
      'isWriter',
    ]),
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

