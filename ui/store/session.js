export const state = () => ({
  session: {
    team: {}
  }
})

export const getters = {
  isStaff: (state, getters) =>
    !getters.isNoLogin && state.session.team.role_id === 10,
  isAudience: (state, getters) =>
    !getters.isNoLogin && state.session.team.role_id === 5,
  isPlayer: (state, getters) =>
    !getters.isNoLogin && state.session.team.role_id === 1,
  isNoLogin: state =>
    // eslint-disable-next-line no-undef
    $nuxt.$elvis(state, 'session.team.role_id') === undefined
}
