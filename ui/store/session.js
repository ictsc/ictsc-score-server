export const state = () => ({
  session: {
    team: {}
  }
})

export const getters = {
  isStaff: (state, getters) => {
    return !getters.isNoLogin && state.session.team.role_id === 10
  },
  isAudience: (state, getters) => {
    return !getters.isNoLogin && state.session.team.role_id === 5
  },
  isPlayer: (state, getters) => {
    return !getters.isNoLogin && state.session.team.role_id === 1
  },
  isNoLogin: state => {
    return state.session === null || Object.keys(state.session.team).length === 0
  }
}
