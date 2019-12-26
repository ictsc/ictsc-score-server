<template>
  <v-menu
    open-on-hover
    offset-y
    allow-overflow
    open-delay="300"
    max-width="40em"
  >
    <template v-slot:activator="{ on }">
      <!-- 一覧に表示されるカード -->
      <v-card :color="team.color" :ripple="false" tile height="100%" v-on="on">
        <v-row align="center" class="height-full">
          <v-col>
            <div class="subtitle-1 px-2 truncate-clamp2">
              <template v-if="showNumber">
                {{ team.displayName }}
              </template>
              <template v-else>
                {{ team.name }}
              </template>
            </div>
          </v-col>
        </v-row>
      </v-card>
    </template>

    <!-- 詳細情報 -->
    <v-card>
      <v-card-text class="px-4 py-2 black--text">
        <v-col class="pa-0 title font-weight-light">
          No.{{ team.number }}
          <v-avatar v-if="team.color" :color="team.color" size="1em" tile />

          <v-divider />

          {{ team.name }}

          <v-divider />

          <template v-if="team.organization">
            {{ team.organization }}
          </template>
        </v-col>
      </v-card-text>
    </v-card>
  </v-menu>
</template>
<script>
export default {
  name: 'TeamCard',
  props: {
    team: {
      type: Object,
      required: true
    },
    showNumber: {
      type: Boolean,
      default: true
    }
  }
}
</script>
