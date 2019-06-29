<template>
  <nuxt-link
    :to="problem.body === null ? '' : problem.id"
    append
    class="column is-one-fifth is-narrow"
  >
    <div class="card">
      <p class="card-header-title has-text-grey">
        <!-- TODO: bodyはundef|null|emptyの可能性がある -->
        {{ elvis(problem, 'body.title') }}
      </p>

      <div class="card-content">
        <div class="content has-text-centered"></div>
      </div>

      <div class="card-footer-item">
        <span>
          <slot />
        </span>
      </div>
    </div>
  </nuxt-link>
</template>

<script>
export default {
  name: 'ProblemCard',
  props: {
    problem: {
      type: Object,
      default: () => ({})
    }
  }
}
</script>

<style scoped lang="sass"></style>
