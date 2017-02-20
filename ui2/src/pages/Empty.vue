<template>
  <div>
    <pre>
    </pre>
  </div>
</template>

<style>

</style>

<script>
import { SET_TITLE } from '../store/'

export default {
  name: 'empty',
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
    this.$store.dispatch(SET_TITLE, 'サイト一覧');
  },
  destroyed () {
  },
  methods: {
  },
}
</script>

