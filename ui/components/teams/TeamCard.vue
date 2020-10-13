<template>
  <v-menu
    v-model="showMenu"
    open-on-hover
    offset-y
    allow-overflow
    open-delay="400"
    :close-delay="closeDelay"
    :close-on-content-click="false"
    :open-on-click="false"
    max-width="40em"
    z-index="50"
  >
    <template v-slot:activator="{ on }">
      <!-- 一覧に表示されるカード -->
      <v-card
        :ripple="false"
        tile
        height="100%"
        class="disable-click-effect"
        v-on="on"
      >
        <v-row align="center" class="height-full" no-gutters>
          <v-avatar
            :color="team.color"
            size="0.4em"
            height="100%"
            class="py-6"
            tile
          />

          <team-modal v-if="isStaff" v-model="showModal" :item="team">
            <template v-slot:activator="{ on: modalOn }">
              <pen-button v-if="isStaff" elevation="0" x-small v-on="modalOn" />
            </template>
          </team-modal>

          <v-col class="subtitle-1 px-2 truncate-clamp2">
            {{ showNumber ? team.displayName : team.name }}
          </v-col>

          <v-icon v-if="team.beginner" class="pr-2"> mdi-face-agent </v-icon>
        </v-row>
      </v-card>
    </template>

    <team-details-card :team="team" />
  </v-menu>
</template>
<script>
import PenButton from '~/components/commons/PenButton'
import TeamDetailsCard from '~/components/misc/TeamDetailsCard'
import TeamModal from '~/components/misc/TeamModal'

export default {
  name: 'TeamCard',
  components: {
    PenButton,
    TeamDetailsCard,
    TeamModal,
  },
  props: {
    team: {
      type: Object,
      required: true,
    },
    showNumber: {
      type: Boolean,
      default: true,
    },
  },
  data() {
    return {
      showMenu: false,
      showModal: false,
    }
  },
  computed: {
    closeDelay() {
      // v-menuが閉じると何故かdialogも閉じるので適当に600分閉じないようにする
      return this.showModal ? 36000000 : 0
    },
  },
  watch: {
    showModal(value) {
      // 一定時間開きっぱになることがあるので手動で閉じる
      if (!value) {
        this.showMenu = false
      }
    },
  },
}
</script>
