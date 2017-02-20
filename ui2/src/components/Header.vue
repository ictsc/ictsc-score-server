<template>
   <nav class="navbar fixed-top navbar-light navbar-toggleable flex-row">
    <a class="navbar-brand mr-auto" href="#">
      ICTSC
    </a>

    <div class="navbar-nav">
      <div class="nav-item">
        <a class="nav-link" href="#">利用手順</a>
      </div>
    </div>

    <div class="dropdown">
      <button class="btn btn-secondary dropdown-toggle" data-toggle="dropdown" type="button">
        displayName
      </button>
      <div class="dropdown-menu dropdown-menu-right">
        <a class="dropdown-item">ログアウト</a>
      </div>
    </div>
  </nav>
</template>

<style scoped>
.navbar {
  background: #7B90D2;
  right: initial;
  min-width: 100%;
  float: left;
  /*flex-direction: row;*/
  align-items: center;
  min-width: 900px;
  width: 100%;
  padding: .3rem 1rem;
}
/* from @media (min-width: 576px) .navbar-toggleable .navbar-nav */
.navbar .navbar-nav {
  -webkit-box-orient: horizontal;
  -webkit-box-direction: normal;
  -webkit-flex-direction: row;
  -ms-flex-direction: row;
  flex-direction: row;
}
/* from @media (min-width: 576px) .navbar-toggleable .navbar-nav .nav-link */
.navbar .navbar-nav .nav-link {
  padding-right: 1rem;
  padding-left: 1rem;
}

.navbar .navbar-brand,
.navbar .nav-link {
  color: #fff;
}
.navbar .navbar-brand:hover,
.navbar .nav-link:hover {
  color: #ddd;
}
</style>

<script>
import * as d3 from 'd3';

export default {
  name: 'header',
  data () {
    return {
    }
  },
  computed: {
  },
  methods: {
  },
  mounted: function () {
    var dropdown = d3
      .select(this.$el)
      .select('.dropdown');

    dropdown.on('click', () => {
      d3.event.stopPropagation();  // イベント伝達禁止
      dropdown.classed('show', !dropdown.classed('show'));
    });
    d3
      .select('body')
      .on('click', () => {
        dropdown.classed('show', false);
      })
  },
  destroyed: function () {
  }
}
</script>
