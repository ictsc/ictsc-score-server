import Vue from 'vue'
import Vuex from 'vuex'

import { API } from '../utils/Api'

export const SET_CONTEST = 'SET_CONTEST';
export const RELOAD_CONTEST = 'RELOAD_CONTEST';
// ページのタイトルを設定する
export const SET_TITLE = 'SET_TITLE';
export const _SET_STATE_TITLE = '_SET_STATE_TITLE';
export const RELOAD_SESSION = 'RELOAD_SESSION'
export const SET_SESSION = 'SET_SESSION'
export const CLEAR_SESSION = 'CLEAR_SESSION'

Vue.use(Vuex)

export default new Vuex.Store({
  state: {
    contest: {},
    title: '',
    session: {
      member: {}
    },
  },
  getters: {
    contest: state => state.contest,
    title: state => state.title,
    session: state => state.session,
    isNoLogin: state => {
      return state.session == null
        || state.session.member == null
        || state.session.member.role_id === 1;
    },
    isStaff: state => {
      return state.session != null &&
        state.session.member != null &&
        state.session.member.role_id === 2 ||
        state.session.member.role_id === 3 ||
        state.session.member.role_id === 5;
    },
    isAdmin: state => {
      return state.session != null &&
        state.session.member != null &&
        state.session.member.role_id === 2;
    },
    isViewer: state => {
      return state.session != null &&
        state.session.member != null &&
        state.session.member.role_id === 5;
    },
    isWriter: state => {
      return state.session != null &&
        state.session.member != null &&
        state.session.member.role_id === 3;
    },
    isMember: state => {
      return state.session != null &&
        state.session.member != null &&
        state.session.member.role_id === 4;
    },
    notificationChannels: state => {
      return state.session &&
             state.session.notification_channels &&
             Object.values(state.session.notification_channels) ||
             []
    },
  },
  mutations: {
    [SET_CONTEST]: (state, contest) => { state.contest = contest },
    [_SET_STATE_TITLE]: (state, title) => { state.title = title },
    [SET_SESSION]: (state, session) => { state.session = session },
    [CLEAR_SESSION]: (state) => { state.session = { member: {} } },
  },
  actions: {
    [SET_TITLE]: (context, val) => {
      window.document.title = `ICTSC - ${val}`;
      context.commit(_SET_STATE_TITLE, val);
    },
    [RELOAD_SESSION]: (ctx) => {
      API.getSession()
        .then(res => {
          ctx.commit(SET_SESSION, res)
        })
    },
    [RELOAD_CONTEST]: (ctx) => {
      API.getContest()
        .then(res => {
          ctx.commit(SET_CONTEST, res)
        })
    }
  },
  modules: {},
})
