<template>
  <v-card>
    <v-card-text class="px-4 py-2 black--text">
      <v-col class="pa-0 title font-weight-light">
        Team No.{{ team.number }}
        <v-icon v-if="isStaff && team.beginner" class="pb-1">
          mdi-face-agent
        </v-icon>
        <v-avatar v-if="team.color" :color="team.color" size="1em" tile />

        <v-divider />

        <v-row align="center" class="flex-nowrap pr-2" no-gutters>
          <v-btn
            v-if="isStaff"
            v-clipboard:copy="team.name"
            v-clipboard:success="onCopySuccess"
            v-clipboard:error="onCopyError"
            icon
            small
          >
            <v-icon>mdi-clipboard-text-outline</v-icon>
          </v-btn>

          <div>{{ team.name }}</div>
        </v-row>

        <template v-if="team.organization">
          <v-divider />
          {{ team.organization }}
        </template>

        <template v-if="team.secretText">
          <v-divider class="pb-2" />
          <div>運営用メモ</div>
          {{ team.secretText }}
        </template>
      </v-col>
    </v-card-text>
  </v-card>
</template>
<script>
export default {
  name: 'TeamDetailsCard',
  props: {
    team: {
      type: Object,
      required: true
    }
  },
  methods: {
    onCopySuccess(event) {
      this.notifyInfo({
        message: `コピーしました\n${event.text}`,
        timeout: 3000
      })
    },
    onCopyError(e) {
      this.notifyWarning({ message: 'コピーに失敗しました' })
    }
  }
}
</script>
