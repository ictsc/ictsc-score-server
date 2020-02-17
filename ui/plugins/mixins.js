import Vue from 'vue'
import { mapGetters, mapMutations } from 'vuex'

// 各コンポーネントで多用するメソッドをmixinする
// やりすぎ注意

Vue.mixin({
  filters: {
    tickDuration(sec, format) {
      if (sec >= 0) {
        return $nuxt.$moment.utc(sec * 1000).format(format)
      } else {
        return '-' + $nuxt.$moment.utc(-sec * 1000).format(format)
      }
    }
  },
  computed: {
    ...mapGetters('session', [
      'currentTeamId',
      'isLoggedIn',
      'isStaff',
      'isAudience',
      'isPlayer',
      'isNotLoggedIn',
      'isNotStaff',
      'isNotAudience',
      'isNotPlayer'
    ])
  },
  methods: {
    ...mapMutations('notification', [
      'addNotification',
      'notifySuccess',
      'notifyInfo',
      'notifyWarning',
      'notifyError'
    ]),

    isSame(item1, item2) {
      return JSON.stringify(item1) === JSON.stringify(item2)
    },

    stringSimplify(str) {
      return str.replace(/-|_/g, '').toLowerCase()
    },

    currentDateTimeString() {
      return this.$moment(new Date()).format('MM-DD HH:mm:ss')
    },
    formatDateTime(value) {
      // 2112-09-03T03:22:00+09:00 iso8601
      return this.$moment(value, this.$moment.ISO_8601).format()
    },
    isValidDateTime(value) {
      return this.$moment(value, this.$moment.ISO_8601).isValid()
    },
    timeSimpleStringJp(sec) {
      if (sec <= 60) {
        return `${sec}秒`
      } else if (sec % 60 === 0) {
        return `${Math.floor(sec / 60)}分`
      } else {
        return `${Math.floor(sec / 60)}分${sec % 60}秒`
      }
    },

    download(type, filename, data) {
      const blob = new Blob([data], { type })
      const link = document.createElement('a')
      link.href = window.URL.createObjectURL(blob)
      link.download = filename
      link.click()
    },

    // sort
    sortByCode(list) {
      return this.$_.sortBy(list, 'code')
    },
    sortByOrder(list) {
      return this.$_.sortBy(list, 'order')
    },
    sortByNumber(list) {
      return this.$_.sortBy(list, 'number')
    },
    // 古い順
    sortByCreatedAt(list) {
      return this.$_.sortBy(list, e => Date.parse(e.createdAt))
    },
    sortByUpdatedAt(list) {
      return this.$_.sortBy(list, e => Date.parse(e.updatedAt))
    },

    // filter
    findOlder(records) {
      // mixはrecordsが[]の場合Inifnityになる
      if (records.length === 0) {
        return null
      }

      return this.$_.min(records, record => new Date(record.createdAt))
    },
    findNewer(records) {
      // maxはrecordsが[]の場合-Inifnityになる
      if (records.length === 0) {
        return null
      }

      return this.$_.max(records, record => new Date(record.createdAt))
    }
  }
})
