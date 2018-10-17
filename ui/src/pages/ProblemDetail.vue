<template>
  <div>
    <problem :id="id"></problem>
  </div>
</template>

<style scoped>
</style>

<script>
import { SET_TITLE } from '../store/'
import Problem from '../components/Problem'
import { mapGetters } from 'vuex'

export default {
  name: 'problem-detail',
  components: {
    Problem,
  },
  data () {
    return {
    }
  },
  asyncData: {
  },
  computed: {
    id () {
      return this.$route.params.id;
    },
    ...mapGetters([
      'session',
    ]),
  },
  watch: {
  },
  mounted () {
    this.$store.dispatch(SET_TITLE, '問題詳細');
    if (this.session.member && this.session.member.team_id) {
      this.$router.replace({
        name: 'problem-issues',
        params: {
          id: this.id,
          team: this.session.member.team_id,
        }
      });
    }
  },
  destroyed () {
  },
  methods: {
  },
}
</script>
