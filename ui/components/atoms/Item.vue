<template>
  <div class="item">
    <h4>{{ topic }}</h4>
    <p><slot /></p>
  </div>
</template>

<script>
export default {
  name: 'Item',
  props: {
    topic: {
      type: String,
      default: ''
    }
  }
}
</script>

<style scoped>
.item {
  flex-grow: 1;
  min-width: 5rem;
  padding: 1rem;
  padding-right: 4rem;
  background: #efefef;
  position: relative;
  background-image: url('~assets/arrow.svg');
  background-repeat: repeat-y;
  background-position: right center;
}
.item:last-child {
  background-image: none;
  padding-right: 1rem;
}
.item p {
  margin: 0;
}
</style>
