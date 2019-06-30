export const state = () => ({
  gradingDelaySec: 0
})

export const getters = {
  gradingDelayString: (state, getters) => {
    return getters.gradingDelaySec < 60
      ? getters.gradingDelaySecString
      : getters.gradingDelayMinString
  },
  gradingDelaySec: state => state.gradingDelaySec,
  gradingDelaySecString: (state, getters) => `${getters.gradingDelaySec}秒`,
  gradingDelayMin: (state, getters) => getters.gradingDelaySec / 60,
  gradingDelayMinString: (state, getters) => `${getters.gradingDelayMin}分`
}
