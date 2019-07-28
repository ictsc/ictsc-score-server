<template>
  <div class="item">
    <div class="subtitle-1">{{ title }}</div>
    <p class="caption">{{ body }}</p>
  </div>
</template>

<script>
export default {
  name: 'AnswerFlowItem',
  props: {
    title: {
      type: String,
      required: true
    },
    body: {
      type: String,
      required: true
    }
  }
}
</script>

<style scoped lang="sass">
.item
  flex-grow: 1
  min-width: 5rem
  padding: 1rem
  padding-right: 4rem
  background: #efefef
  position: relative
  background-image: url('~assets/img/arrow.svg')
  background-repeat: repeat-y
  background-position: right center

  &:last-child
    background-image: none
    padding-right: 1rem

  p
    margin: 0
</style>
