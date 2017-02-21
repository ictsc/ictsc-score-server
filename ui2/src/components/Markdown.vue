<template>
  <div class="markdown-body" v-html="markdown"></div>
</template>

<style>
.markdown-body p {
  white-space: pre;
}
</style>

<script>
import marked from 'marked';
require('github-markdown-css/github-markdown.css');

export default {
  name: 'empty',
  props: {
    value: String,
  },
  data () {
    return {
      text: '',
    }
  },
  asyncData: {
  },
  computed: {
    markdown () {
      return marked(this.text, { sanitize: true })
    },
  },
  watch: {
    value (val) {
      if (val === this.text) return;
      this.text = val;
    },
  },
  mounted () {
    this.text = this.value;
  },
  destroyed () {
  },
  methods: {
  },
}
</script>
