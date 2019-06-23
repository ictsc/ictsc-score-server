<template>
  <nav class="navbar fixed-top navbar-light navbar-toggleable flex-row">
    <nuxt-link
      to="dashboard"
      class="navbar-brand"
      >
        <img
          src="~assets/ictsc-logo-white.svg"
          alt="ICTSC"
        >
    </nuxt-link>

    <div class="navbar-nav  mr-auto">
      <div class="nav-item">
        <router-link
          :to="{name: 'guide'}"
          active-class="active"
          class="nav-link"
        >
          ガイド
        </router-link>
      </div>
      <div class="nav-item">
        <router-link
          :to="{name: 'members'}"
          active-class="active"
          class="nav-link"
        >
          メンバー
        </router-link>
      </div>
      <div class="nav-item">
        <router-link
          :to="{name: 'teams'}"
          active-class="active"
          class="nav-link"
        >
          チーム
        </router-link>
      </div>
    </div>
    <div class="navbar-nav">
      <div class="nav-item">
        <router-link
          :to="{name: 'dashboard'}"
          class="nav-link"
        >
          トップ
        </router-link>
      </div>
      <div class="nav-item">
        <router-link
          :to="{ name: 'problems'}"
          active-class="active"
          class="nav-link"
        >
          問題
        </router-link>
      </div>
      <div class="nav-item">
        <router-link
          :to="{ name: 'issues'}"
          active-class="active"
          class="nav-link"
        >
          質問
        </router-link>
      </div>
      <div
        v-if="isStaff"
        class="nav-item"
      >
        <router-link
          :to="{ name: 'answers'}"
          active-class="active"
          class="nav-link"
        >
          解答
        </router-link>
      </div>
      <div class="nav-item">
        <router-link
          :to="{ name: 'summary'}"
          v-if="!(isNoLogin || isParticipant)"
          active-class="active"
          class="nav-link"
        >
          概要
        </router-link>
      </div>
      <div class="nav-item">
        <a
          v-on:click="logout()"
          v-if="!isNoLogin"
          href="#"
          class="nav-link"
        >ログアウト</a>
        <router-link
          :to="{ name: 'login' }"
          v-else
          class="nav-link"
        >
          ログイン
        </router-link>
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
  padding: .3rem 0.8rem;
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
  name: 'Header',
  data () {
    return {
    }
  },
}
</script>
