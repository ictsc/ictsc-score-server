import Vue from 'vue'
import Vuex from 'vuex'

import { API } from '../utils/Api'

// ページのタイトルを設定する
export const SET_TITLE = 'SET_TITLE';
export const _SET_STATE_TITLE = '_SET_STATE_TITLE';
export const RELOAD_SESSION = 'RELOAD_SESSION'
export const SET_SESSION = 'SET_SESSION'
export const CLEAR_SESSION = 'CLEAR_SESSION'

Vue.use(Vuex)

export default new Vuex.Store({
  state: {
    title: '',
    session: {
      member: {}
    },
  },
  getters: {
    title: state => state.title,
    session: state => state.session,
    isAdmin: state => {
      return state.session != null &&
        state.session.member != null &&
        state.session.member.role_id === 2;
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
    }
  },
  modules: {},
})
