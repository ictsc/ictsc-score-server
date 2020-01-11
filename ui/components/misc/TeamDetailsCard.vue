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
        {{ team.name }}

        <template v-if="team.organization">
          <v-divider />
          {{ team.organization }}
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
  }
}
</script>
