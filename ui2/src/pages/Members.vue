<template>
  <div>
    <pre>{{ members }}</pre>
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

