<template>
  <div>
    <div class="markdown-editor">
      <textarea></textarea>
    </div>
  </div>
</template>

<style>
.editor-toolbar.fullscreen {
  z-index: 1100;
}
</style>

<script>
require('simplemde/dist/simplemde.min.css');
import SimpleMDE from 'simplemde';

export default {
  name: 'simple-markdown-editor',
  props: {
    value: String,
    config: {
      type: Object,
      default () {
        return {
          spellChecker: false,
          showIcons: ['code', 'horizontal-rule', 'link', 'table'],
          guide: '/#/guide',
        };
      },
    }
  },
  data () {
    return {
      simplemde: undefined,
    }
  },
  asyncData: {
  },
  computed: {
  },
  watch: {
    value (val) {
      if (val === this.simplemde.value()) return;
      this.simplemde.value(val);
    },
  },
  mounted () {
    this.init();
  },
  destroyed () {
  },
  methods: {
    init () {
      this.simplemde = new SimpleMDE(this.config);
      this.simplemde.codemirror.on('change', () => {
        this.$emit('input', this.simplemde.value());
      });
    },
    stop () {
      this.simplemde.toTextArea();
      this.simplemde = undefined;
    },
  },
}
</script>

