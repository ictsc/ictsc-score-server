export const state = () => ({
  gradingDelaySec: 0
})

export const getters = {
  gradingDelayString: (state, getters) => {
    return getters.gradingDelaySec < 60
      ? getters.gradingDelaySecString
      : getters.gradingDelayMinString
  },
  gradingDelaySec: state => {
    return state.gradingDelaySec
  },
  gradingDelaySecString: (state, getters) => {
    return `${getters.gradingDelaySec}秒`
  },
  gradingDelayMin: (state, getters) => {
    return getters.gradingDelaySec / 60
  },
  gradingDelayMinString: (state, getters) => {
    return `${getters.gradingDelayMin}分`
  }
}