<template>
  <div>
    <pre />
  </div>
</template>

<style scoped>

</style>

<script>
import { SET_TITLE } from '../store/'

export default {
  name: 'Empty',
  data () {
    return {
    }
  },
  computed: {
  },
  watch: {
  },
  asyncData: {
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

