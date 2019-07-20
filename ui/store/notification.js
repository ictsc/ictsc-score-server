// Vuexを通して通知を描画する
// timeoutが0なら永続
// mutationsは他のmutationsを呼び出せないため外部で関数化する必要がある
function addNotification(state, { message, timeout, type }) {
  if (timeout === undefined) {
    // デフォルトは7s
    timeout = 7000
  }

  state.list.push({ message, timeout, type, id: state.latestId++ })
}

export default {
  state() {
    return {
      list: [],
      latestId: 0
    }
  },
  mutations: {
    addNotification(state, { id, message, timeout, type }) {
      addNotification(state, { id, message, timeout, type })
    },
    notifySuccess(state, { id, message, timeout }) {
      addNotification(state, { id, message, timeout, type: 'success' })
    },
    notifyInfo(state, { id, message, timeout }) {
      addNotification(state, { id, message, timeout, type: 'info' })
    },
    notifyWarning(state, { id, message, timeout }) {
      addNotification(state, { id, message, timeout, type: 'warning' })
    },
    notifyError(state, { id, message, timeout }) {
      addNotification(state, { id, message, timeout, type: 'error' })
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
