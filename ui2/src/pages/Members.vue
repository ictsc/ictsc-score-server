<template>
  <div>
    <pre>
    </pre>
  </div>
</template>

<style scoped>

</style>

<script>
import { SET_TITLE } from '../store/'

export default {
  name: 'members',
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
    this.$store.dispatch(SET_TITLE, 'メンバー一覧');
  },
  destroyed () {
  },
  methods: {
  },
}
</script>

