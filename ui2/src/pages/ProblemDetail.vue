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
  },
  watch: {
  },
  mounted () {
    this.$store.dispatch(SET_TITLE, '問題詳細');
  },
  destroyed () {
  },
  methods: {
  },
}
</script>
