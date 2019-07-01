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
  async login({ commit, dispatch }, { name, password }) {
    const params = new URLSearchParams()
    params.append('name', name)
    params.append('password', password)

    // TODO: badrequestが帰ってきたときの処理
    const res = await this.$axios.$post('/api/sessions', params)

    commit('setSession', { teamId: res.id, role: res.role })
  },
  async logout({ state, commit, dispatch }) {
    const res = await this.$axios.$delete('/api/sessions')
    console.log(res)
    // TODO: unauthorizedが帰ってきたときの処理
    commit('unsetSession')
  }
}

export const getters = {
  isStaff: (state, getters) => !getters.isNoLogin && state.role === 'staff',
  isAudience: (state, getters) =>
    !getters.isNoLogin && state.role === 'audience',
  isPlayer: (state, getters) => !getters.isNoLogin && state.role === 'player',
  isNoLogin: state => state.role === null
}
