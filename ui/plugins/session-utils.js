import Vue from 'vue'
import { mapGetters } from 'vuex'

Vue.mixin({
  computed: {
    ...mapGetters('session', ['isStaff', 'isAudience', 'isPlayer', 'isNoLogin'])
  }
})
