export default {
  state() {
    const now = new Date()

    return {
      currentTime: now,
      currentTimeMsec: Number(now),
      interval: null
    }
  },
  mutations: {
    updateCurrentTime(state) {
      state.currentTime = new Date()
      state.currentTimeMsec = Number(state.currentTime)
    },
    setInterval(state, interval) {
      state.interval = interval
    },
    unsetInterval(state) {
      state.interval = null
    }
  },
  actions: {
    startInterval({ commit }) {
      const interval = setInterval(() => {
        commit('updateCurrentTime')
      }, 1000)
      commit('setInterval', interval)
    },
    stopInterval({ state, commit }) {
      if (state.interval) {
        clearInterval(state.interval)
        commit('unsetInterval')
      }
    }
  },
  getters: {
    currentTime: state => state.currentTime,
    currentTimeMsec: state => state.currentTimeMsec
  }
}
