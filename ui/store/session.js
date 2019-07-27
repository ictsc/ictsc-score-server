const ENDPOINT = 'sessions'

export const state = () => ({
  teamId: null,
  role: null
})

export const mutations = {
  setSession(state, { teamId, role }) {
    state.teamId = teamId
    state.role = role
  },
  unsetSession(state) {
    state.teamId = null
    state.role = null
  }
}

export const actions = {
  async login({ commit }, { name, password }) {
    const res = await this.$axios.post(ENDPOINT, { name, password })

    switch (res.status) {
      case 200:
        commit('setSession', { teamId: res.data.id, role: res.data.role })
        return true
      case 400:
        return false
      default:
        throw new Error(res)
    }
  },

  async logout({ commit }) {
    const res = await this.$axios.delete(ENDPOINT)
    console.log(res)

    switch (res.status) {
      case 204:
        commit('unsetSession')
        return true
      case 401:
        return false
      default:
        throw new Error(res)
    }
  },

  async fetchCurrentSession({ commit }) {
    const res = await this.$axios.get(ENDPOINT)

    switch (res.status) {
      case 200:
        commit('setSession', { teamId: res.data.id, role: res.data.role })
        return true
      case 401:
        return false
      default:
        throw new Error(res)
    }
  }
}

export const getters = {
  currentTeamId: state => state.teamId,
  isStaff: (state, getters) => !getters.isNoLogin && state.role === 'staff',
  isAudience: (state, getters) =>
    !getters.isNoLogin && state.role === 'audience',
  isPlayer: (state, getters) => !getters.isNoLogin && state.role === 'player',
  isNoLogin: state => state.role === null
}
