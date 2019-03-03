<template>
  <div>
    <div class="row">
      <div
        v-loading="noticesLoading"
        class="col-4"
      >
        <h3>お知らせ</h3>
        <div class="item-box">
          <div
            v-for="item in notices.slice().reverse()"
            class="item"
          >
            <h4>{{ item.title }}</h4>
            <markdown :value="item.text" />
            <div class="tip">
              <button
                v-if="isAdmin || isWriter"
                v-on:click="deleteNotif(item.id)"
                class="btn btn-secondary"
              >
                削除
              </button>
              <small>{{ item.created_at }}</small>
            </div>
          </div>
        </div>

        <div
          v-if="isStaff"
          class="item-box"
        >
          <h4>お知らせ投稿</h4>
          <div class="form-group">
            <input
              id="checkbox-pinning"
              v-model="notifPinning"
              type="checkbox"
              class=""
            >
            <label
              class=""
              for="checkbox-pinning"
            >
              <i class="fa fa-fw fa-thumb-tack" />
              お知らせ固定
            </label>
          </div>
          <div class="form-group">
            <label for="input-title">タイトル</label>
            <input
              id="input-title"
              v-model="notifTitle"
              type="text"
              class="form-control"
            >
          </div>
          <div class="form-group">
            <label>本文</label>
            <simple-markdown-editor v-model="notifBody" />
            <!--<markdown :value="notifBody"></markdown>-->
          </div>
          <div class="form-group">
            <button
              v-on:click="submitNotif()"
              class="btn btn-success"
            >
              投稿
            </button>
          </div>
        </div>
      </div>
      <div
        v-loading="scoreboardLoading"
        v-if="scoreboardLoading || scoreboard.length"
        class="col-4 scoreboard"
      >
        <h3>順位</h3>
        <div class="item-box">
          <template v-for="item in scoreboard">
            <router-link
              :to="{name: 'team-detail', params: {id: item.team ? item.team.id : ''}}"
              class="item"
            >
              <h4>{{ item.rank }}位 <span class="score">{{ item.score }}点</span></h4>
              <div v-if="item.team">
                {{ item.team.name }}
              </div>
            </router-link>
          </template>
        </div>
      </div>
      <div
        v-loading="notificationsLoading"
        class="col-4"
      >
        <h3>質問・補足のアップデート</h3>
        <div class="item-box">
          <div
            v-for="item in lastiNotifications"
            class="item"
          >
            <p>type: {{ item.type }}</p>
            <p>{{ item.resource }}: {{ item.resource_id }} / {{ item.sub_resource_id }}. {{ item.text }}</p>
            <small>{{ item.created_at }}</small>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { SET_TITLE } from '../store/'
import { API } from '../utils/Api'
import { Emit, PUSH_NOTIF, REMOVE_NOTIF } from '../utils/EventBus'
import SimpleMarkdownEditor from '../components/SimpleMarkdownEditor'
import Markdown from '../components/Markdown'
import { mapGetters } from 'vuex'

let successNotif = (title, detail) => {
  Emit(PUSH_NOTIF, {
    type: 'success',
    title,
    detail,
    key: 'notif',
  });
}
let errorNotif = (title, detail) => {
  Emit(PUSH_NOTIF, {
    type: 'error',
    title,
    detail,
    key: 'notif',
  });
}


export default {
  name: 'Dashboard',
  components: {
    SimpleMarkdownEditor,
    Markdown,
  },
  data () {
    return {
      // new notif
      notifPinning: false,
      notifTitle: '',
      notifBody: '',
    }
  },
  asyncData: {
    noticesDefault: [],
    notices () {
      return API.getNotices();
    },
    notificationsDefault: [],
    notifications () {
      return API.getNotifications();
    },
    scoreboardDefault: [],
    scoreboard () {
      return API.getScoreboard();
    },
  },
  computed: {
    lastiNotifications () {
      return this.notifications.filter((v, i) => i < 15)
    },
    ...mapGetters([
      'session',
      'isStaff',
      'isAdmin',
      'isWriter',
    ]),
  },
  watch: {
  },
  mounted () {
    this.$store.dispatch(SET_TITLE, 'ダッシュボード');
  },
  destroyed () {
  },
  methods: {
    submitNotif () {
      Emit(REMOVE_NOTIF, msg => msg.key === 'notif');

      // TODO ピン留め
      API.postNotices(this.notifTitle, this.notifBody, this.notifPinning)
        .then(_res => {
          this.asyncReload('notices');
          successNotif('投稿しました。');
          this.notifTitle = '';
          this.notifBody = '';
          this.notifPinning = false;
        })
        .catch(err => {
          console.log(err);
          errorNotif('投稿に失敗しました。')
        })
    },
    deleteNotif (id) {
      API.deleteNotices(id)
        .then(_res => {
          this.asyncReload('notices');
          successNotif('削除しました。');
        })
        .catch(err => {
          console.log(err);
          errorNotif('削除に失敗しました。')
        })
    },
  },
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
h1, h2 {
  font-weight: normal;
}
.item-box {
  padding: 1.5rem;
  border: 1px solid #fdbbcc;
  margin-bottom: 2rem;
}
.item-box .item:not(:last-child) {
  padding-bottom: 1rem;
  margin-bottom: 1rem;
  border-bottom: 1px solid #fdbbcc;
}

.scoreboard .score {
  text-align: right;
  display: block;
  float: right;
}
.scoreboard .item {
  display: block;
  color: inherit;
}
</style>
