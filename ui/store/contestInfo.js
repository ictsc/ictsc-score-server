export default {
  state() {
    return {
      competitionTime: [],
      gradingDelaySec: 0,
      hideAllScore: false,
      realtimeGrading: false,
      textSizeLimit: 0,
      deleteTimeLimitSec: 0,
      guidePage: ''
    }
  },
  mutations: {
    // GraphQLでまとも手取得したContestInfoをstateに割り振る
    setContestInfo(state, contestInfo) {
      state.competitionTime = contestInfo.competitionTime.map(daterange =>
        daterange.map(date => new Date(date))
      )
      state.gradingDelaySec = contestInfo.gradingDelaySec
      state.hideAllScore = contestInfo.hideAllScore
      state.realtimeGrading = contestInfo.realtimeGrading
      state.textSizeLimit = contestInfo.textSizeLimit
      state.deleteTimeLimitSec = contestInfo.deleteTimeLimitSec
      state.guidePage = contestInfo.guidePage
    }
  },
  actions: {
    async fetchContestInfo({ commit, dispatch }) {
      const query = `
        query ContestInfo {
          contestInfo {
            competitionTime
            gradingDelaySec
            hideAllScore
            realtimeGrading
            textSizeLimit
            deleteTimeLimitSec
            guidePage
          }
        }
      `

      const res = await dispatch(
        'entities/simpleQuery',
        { query, bypassCache: true },
        { root: true }
      )

      commit('setContestInfo', res.contestInfo)
    }
  },
  getters: {
    gradingDelayString: (state, getters) => {
      return getters.gradingDelaySec < 60
        ? getters.gradingDelaySecString
        : getters.gradingDelayMinString
    },
    gradingDelaySec: state => state.gradingDelaySec,
    gradingDelaySecString: (state, getters) => `${getters.gradingDelaySec}秒`,
    gradingDelayMin: (state, getters) =>
      Math.floor(getters.gradingDelaySec / 60),
    gradingDelayMinString: (state, getters) => `${getters.gradingDelayMin}分`,

    deleteTimeLimitSec: state => state.deleteTimeLimitSec,
    deleteTimeLimitMsec: state => state.deleteTimeLimitSec * 1000,
    deleteTimeLimitString: (state, getters) => {
      return getters.deleteTimeLimitSec < 60
        ? `${getters.deleteTimeLimitSec}秒`
        : `${Math.floor(getters.deleteTimeLimitSec / 60)}分`
    },

    competitionTime: state => state.competitionTime,
    competitionTimeString: (state, getters) => {
      return JSON.stringify(getters.competitionTime)
    },

    hideAllScore: state => state.hideAllScore,
    realtimeGrading: state => state.realtimeGrading,
    textSizeLimit: state => state.textSizeLimit,
    guidePage: state => state.guidePage
  }
}
