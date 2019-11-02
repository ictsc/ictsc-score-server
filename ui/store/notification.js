// Vuexを通して通知を描画する
// timeoutが0なら永続
// mutationsは他のmutationsを呼び出せないため外部で関数化する必要がある
function addNotification(state, { message, details, timeout, type }) {
  if (timeout === undefined) {
    // デフォルトは7s
    timeout = 7000
  }

  if (details === undefined) {
    details = ''
  }

  state.list.push({ message, details, timeout, type, id: state.latestId++ })
}

export default {
  state() {
    return {
      list: [],
      latestId: 0
    }
  },
  mutations: {
    addNotification(state, { id, message, details, timeout, type }) {
      addNotification(state, { id, message, details, timeout, type })
    },
    notifySuccess(state, { id, message, details, timeout }) {
      addNotification(state, { id, message, details, timeout, type: 'success' })
    },
    notifyInfo(state, { id, message, details, timeout }) {
      addNotification(state, { id, message, details, timeout, type: 'info' })
    },
    notifyWarning(state, { id, message, details, timeout }) {
      addNotification(state, { id, message, details, timeout, type: 'warning' })
    },
    notifyError(state, { id, message, details, timeout }) {
      addNotification(state, { id, message, details, timeout, type: 'error' })
    },
    removeNotification(state, id) {
      const index = state.list.findIndex(n => n.id === id)
      if (index === -1) {
        throw new Error(`notification id(${id}) is not found`)
      }

      state.list.splice(index, 1)
    }
  },
  getters: {
    notifications: state => state.list
  }
}
