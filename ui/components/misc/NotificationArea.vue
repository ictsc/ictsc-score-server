<template>
  <v-col
    align="right"
    class="py-0 px-0 mx-2 floating-area-1000 bottom-right area-width"
  >
    <v-slide-x-reverse-transition group>
      <notification-card
        v-for="notification in reverseNotifications"
        :key="notification.id"
        :uid="notification.id"
        :type="notification.type"
        :timeout="notification.timeout"
        :message="notification.message"
        :details="notification.details"
      />
    </v-slide-x-reverse-transition>
  </v-col>
</template>
<script>
import { mapGetters } from 'vuex'
import NotificationCard from '~/components/misc/NotificationCard'

export default {
  name: 'NotificationArea',
  components: {
    NotificationCard,
  },
  computed: {
    ...mapGetters('notification', ['notifications']),
    reverseNotifications() {
      return this.notifications.slice().reverse()
    },
  },
}
</script>
<style scoped lang="sass">
.bottom-right
  bottom: 0
  right: 0

.area-width
  width: 36em
</style>
