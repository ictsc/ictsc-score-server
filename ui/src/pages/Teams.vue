<template>
  <div v-loading="asyncLoading">
    <h1>参加チーム</h1>
    <div class="row">
      <div
        v-for="item in teams"
        class="col-4"
      >
        <router-link
          :to="{name: 'team-detail', params: {id: item.id}}"
          class="team d-flex align-items-center"
        >
          <div class="detail">
            <h3>{{ item.name }}</h3>
            <hr>
            <div class="org">
              {{ item.organization }}
            </div>
            <!--<div class="score">総スコア</div>-->
          </div>
        </router-link>
      </div>
    </div>
    <div
      v-if="isAdmin || isWriter"
      class="row justify-content-center"
    >
      <div class="col-4">
        <div class="team d-flex align-items-center">
          <div class="detail">
            <input
              v-model="teamName"
              type="text"
              class="form-control"
              placeholder="チーム名"
            >
            <hr>
            <input
              v-model="teamOrg"
              type="text"
              class="form-control"
              placeholder="組織名"
            >
            <input
              v-model="teamRegCode"
              type="text"
              class="form-control"
              placeholder="登録コード"
            >
          </div>
        </div>
        <button
          v-on:click="addTeams()"
          class="btn btn-success btn-lg btn-block"
        >
          追加
        </button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.team {
  color: #393b3c;
  text-decoration: none;
  background: #ebebeb;
  padding: 1.5rem 0 1rem;
  border-radius: 10px;
  display: block;
  margin-bottom: 1rem;
}
.team .entry-no {
  flex-basis: 5rem;
  text-align: right;
  flex-grow: 1;
  flex-shrink: 0;
  font-size: 2rem;
}
.team .entry-no input {
  display: inline;
  width: 3rem;
  padding: .5rem 0 .5rem .2rem;
}
.team .entry-no small {
  font-size: .5em;
  color: #95989a;
}
.team .detail {
  margin: 0 1.5rem 0 1rem;
  flex-basis: 10rem;
  flex-grow: 1;
}
.team .detail h3 {
  font-weight: normal;
  margin: 0;
}
.team .detail hr {
  border-top: 1px solid white;
  margin: .5rem 0;
}
.team .detail .org {
  color: #95989a;
}
.team .detail .score {
  color: #95989a;
  font-size: .8em;
  text-align: right;
  margin-right: 2rem;
}
</style>

<script>
import { SET_TITLE } from '../store/'
import { API } from '../utils/Api'
import { Emit, PUSH_NOTIF, REMOVE_NOTIF } from '../utils/EventBus'
import { mapGetters } from 'vuex'

export default {
  name: 'Teams',
  data () {
    return {
      teamName: '',
      teamOrg: '',
      teamRegCode: '',
    }
  },
  asyncData: {
    teamsDefault: [],
    teams () {
      return API.getTeams();
    },
  },
  computed: {
    ...mapGetters([
      'isAdmin',
      'isWriter',
    ]),
  },
  watch: {
  },
  mounted () {
    this.$store.dispatch(SET_TITLE, 'チーム一覧');
  },
  destroyed () {
  },
  methods: {
    addTeams () {
      Emit(REMOVE_NOTIF, msg => msg.key === 'teams');
      API.addTeams(this.teamName, this.teamOrg, this.teamRegCode)
        .then(_res => {
          this.asyncReload();
          Emit(PUSH_NOTIF, {
            type: 'success',
            title: '追加しました。',
            detail: '',
            key: 'teams',
          })
        })
        .catch(err => {
          console.warn(err);
          Emit(PUSH_NOTIF, {
            type: 'error',
            title: '追加に失敗しました。',
            detail: '',
            key: 'teams',
          });
        })
    }
  },
}
</script>

