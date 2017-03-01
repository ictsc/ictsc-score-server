<template>
  <div>
    <h2>ページが見つかりません</h2>
  </div>
</template>

<style>

</style>

<script>
import { SET_TITLE } from '../store/'

export default {
  name: 'not-found',
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
    this.$store.dispatch(SET_TITLE, 'NotFound');
  },
  destroyed () {
  },
  methods: {
  },
}
</script>
