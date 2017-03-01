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
    this.$store.dispatch(SET_TITLE, 'ページ名');
  },
  destroyed () {
  },
  methods: {
  },
}
</script>

