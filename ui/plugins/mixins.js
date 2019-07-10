import Vue from 'vue'
import { mapGetters } from 'vuex'

// 各コンポーネントで多用するメソッドをmixinする
// やりすぎ注意

Vue.mixin({
  computed: {
    ...mapGetters('session', [
      'currentTeamId',
      'isStaff',
      'isAudience',
      'isPlayer',
      'isNoLogin'
    ])
  }
})
