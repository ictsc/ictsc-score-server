<template>
  <v-container align-end justify-end column class="notification-area">
    <v-slide-x-reverse-transition group>
      <notification-sheet
        v-for="notification in reverseNotifications"
        :key="notification.id"
        :uid="notification.id"
        :type="notification.type"
        :timeout="notification.timeout"
        :message="notification.message"
      />
    </v-slide-x-reverse-transition>
  </v-container>
</template>
<script>
import { mapGetters } from 'vuex'
import NotificationSheet from '~/components/molecules/NotificationSheet'

export default {
  name: 'NotificationArea',
  components: {
    NotificationSheet
  },
  computed: {
    ...mapGetters('notification', ['notifications']),
    reverseNotifications() {
      return this.notifications.slice().reverse()
    }
  }
}
</script>
<style scoped lang="sass">
.notification-area
  position: fixed
  z-index: 1000
  bottom: 0
  right: 0
  width: 30em
</style>
