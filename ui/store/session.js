const EndPoint = 'sessions'

function buildState(response) {
  return {
    teamId: response.data.id,
    role: response.data.role
  }
}

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
    const res = await this.$axios.post(EndPoint, { name, password })

    switch (res.status) {
      case 200:
        commit('setSession', buildState(res))
        return true
      case 400:
        return false
      default:
        throw new Error(res)
    }
  },

  async logout({ commit }) {
    const res = await this.$axios.delete(EndPoint)

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
    const res = await this.$axios.get(EndPoint)

    switch (res.status) {
      case 200:
        commit('setSession', buildState(res))
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
  isLoggedIn: state => state.role !== null && state.role !== undefined,
  isStaff: state => state.role === 'staff',
  isAudience: state => state.role === 'audience',
  isPlayer: state => state.role === 'player',
  isNotLoggedIn: (state, getters) => !getters.isLoggedIn,
  isNotStaff: (state, getters) => getters.isLoggedIn && !getters.isStaff,
  isNotAudience: (state, getters) => getters.isLoggedIn && !getters.isAudience,
  isNotPlayer: (state, getters) => getters.isLoggedIn && !getters.isPlayer
}
