<template>
  <nav class="navbar fixed-top navbar-light navbar-toggleable flex-row">
    <nuxt-link to="/" class="navbar-brand">
      <img src="~assets/img/ictsc-logo-white.svg" alt="ICTSC" />
    </nuxt-link>

    <div class="navbar-nav  mr-auto">
      <div class="nav-item">
        <nuxt-link to="/guide" active-class="active" class="nav-link">
          ガイド
        </nuxt-link>
      </div>
      <div class="nav-item">
        <nuxt-link to="/teams" active-class="active" class="nav-link">
          チーム
        </nuxt-link>
      </div>
    </div>
    <div class="navbar-nav">
      <div class="nav-item">
        <nuxt-link to="/" class="nav-link">
          トップ
        </nuxt-link>
      </div>
      <div class="nav-item">
        <nuxt-link to="/problems" active-class="active" class="nav-link">
          問題
        </nuxt-link>
      </div>
      <div class="nav-item">
        <nuxt-link to="/issues" active-class="active" class="nav-link">
          質問
        </nuxt-link>
      </div>
      <div v-if="isStaff" class="nav-item">
        <nuxt-link to="/answers" active-class="active" class="nav-link">
          解答
        </nuxt-link>
      </div>
      <div class="nav-item">
        <nuxt-link
          v-if="isStaff || isAudience"
          to="/summary"
          active-class="active"
          class="nav-link"
        >
          概要
        </nuxt-link>
      </div>
      <div class="nav-item">
        <a v-if="!isNoLogin" href="#" class="nav-link" @click="logout()">
          ログアウト
        </a>
        <nuxt-link v-else to="/login" class="nav-link">
          ログイン
        </nuxt-link>
      </div>
    </div>
  </nav>
</template>

<style scoped>
.navbar {
  background: #ed1848;
  right: initial;
  min-width: 100%;
  float: left;
  /*flex-direction: row;*/
  align-items: center;
  min-width: 700px;
  width: 100%;
  padding: 0.3rem 0.8rem;
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
  padding-right: 0.8rem;
  padding-left: 0.8rem;
}

.navbar .navbar-brand img {
  height: 2rem;
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
export default {
  name: 'Navigation'
}
</script>
