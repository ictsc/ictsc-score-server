import Vue from 'vue'
import Vuex from 'vuex'

// ページのタイトルを設定する
export const SET_TITLE = 'SET_TITLE';
export const _SET_STATE_TITLE = '_SET_STATE_TITLE';

Vue.use(Vuex)
export const DefaultStore = new Vuex.Store({
  state: {
    title: '',
  },
  getters: {
    title: state => state.title,
  },
  mutations: {
    [_SET_STATE_TITLE]: (state, title) => { state.title = title },
  },
  actions: {
    [SET_TITLE]: (context, val) => {
      window.document.title = `ICTSC - ${val}`;
      context.commit(_SET_STATE_TITLE, val);
    },
  },
  modules: {},
})
