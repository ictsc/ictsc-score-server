<template>
  <div
    v-html="markdown"
    class="markdown-body"
  />
</template>

<style>
.markdown-body p {
  white-space: pre-line;
}
</style>

<script>
import marked from 'marked';
import 'github-markdown-css/github-markdown.css';

export default {
  name: 'Markdown',
  props: {
    value: String,
  },
  data () {
    return {
      text: '',
    }
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
  asyncData: {
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
