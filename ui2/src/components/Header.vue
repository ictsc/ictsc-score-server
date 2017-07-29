<template>
   <nav class="navbar fixed-top navbar-light navbar-toggleable flex-row">
    <router-link :to="{name: 'dashboard'}" class="navbar-brand">
      <img src="../assets/img/logo/ictsc-logo-white.svg" alt="ICTSC">
    </router-link>

    <div class="navbar-nav  mr-auto">
      <div class="nav-item">
        <router-link :to="{name: 'guide'}" active-class="active" class="nav-link">ガイド</router-link>
      </div>
      <div class="nav-item">
        <router-link :to="{name: 'members'}" active-class="active" class="nav-link">メンバー</router-link>
      </div>
      <div class="nav-item">
        <router-link :to="{name: 'teams'}" active-class="active" class="nav-link">チーム</router-link>
      </div>
    </div>
    <div class="navbar-nav">
      <div class="nav-item">
        <router-link :to="{name: 'dashboard'}" class="nav-link">トップ</router-link>
      </div>
      <div class="nav-item">
        <router-link :to="{ name: 'problems'}" active-class="active" class="nav-link">問題</router-link>
      </div>
      <div class="nav-item">
        <router-link :to="{ name: 'issues'}" active-class="active" class="nav-link">質問</router-link>
      </div>
      <div v-if="!isMember" class="nav-item">
        <router-link :to="{ name: 'answers'}" active-class="active" class="nav-link">解答</router-link>
      </div>
      <div class="nav-item">
        <a v-on:click="logout()" class="nav-link">ログアウト</a>
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
import * as d3 from 'd3';
import { API } from '../utils/Api'
import {
  Emit,
  PUSH_NOTIF,
  REMOVE_NOTIF,
} from '../utils/EventBus'
import { mapGetters } from 'vuex'
import { CLEAR_SESSION } from '../store/'

export default {
  name: 'header',
  data () {
    return {
    }
  },
  computed: {
    ...mapGetters([
      'isMember',
      'session',
    ]),
  },
  methods: {
    logout () {
      Emit(REMOVE_NOTIF, msg => msg.key === 'login');

      API.logout()
        .then(res => {
          this.$router.push({ name: 'login' })
          this.$store.commit(CLEAR_SESSION);
          Emit(PUSH_NOTIF, {
            type: 'success',
            title: 'ログアウトしました',
            key: 'login',
          });
        })
        .catch(err => {
          console.log(err)
          Emit(PUSH_NOTIF, {
            type: 'error',
            title: 'ログアウトに失敗しました',
            key: 'login',
          });
        })
    },
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
