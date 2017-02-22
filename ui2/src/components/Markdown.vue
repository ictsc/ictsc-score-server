<template>
  <div class="markdown-body" v-html="markdown"></div>
</template>

<style>
.markdown-body p {
  white-space: pre-line;
}
</style>

<script>
import marked from 'marked';
require('github-markdown-css/github-markdown.css');

export default {
  name: 'markdown',
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
      var text = this.text === undefined ? '' : this.text;
      return marked(text, { sanitize: true });
    },
  },
  watch: {
    value (val) {
      console.log('watch', this.text)
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
