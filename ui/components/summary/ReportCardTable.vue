<template>
  <div>
    <v-row justify="center" no-gutters>
      <v-data-table
        id="table"
        :items="reportCards"
        :headers="headers"
        :mobile-breakpoint="0"
        hide-default-footer
        disable-sort
        disable-pagination
        class="pa-2"
      >
        <!-- 各問題名 -->
        <template
          v-for="(headerName, i) in problemTitleHeaderValues"
          v-slot:[headerName]="{ header }"
        >
          <!-- eslint-disable-next-line vue/valid-v-for -->
          <div :key="header.text" class="problem-title">
            {{ problemGenres[i] }}<br />
            {{ header.text }}
          </div>
        </template>

        <!-- 各問題の得点 -->
        <template
          v-for="(itemName, i) in problemTitleItemValues"
          v-slot:[itemName]="{ item, value }"
        >
          <div
            :key="itemName"
            :style="{ 'background-color': scoreColor(item.eachPercent[i]) }"
            class="height-full negate-px"
          >
            <div class="text-right px-3 score">
              {{ value }}
            </div>
          </div>
        </template>

        <!-- チーム名 -->
        <template v-slot:item.teamName="{ item }">
          <div class="text-no-wrap">
            <div>{{ item.teamName }}</div>
            <div>{{ item.teamOrganization }}</div>
          </div>
        </template>

        <!-- 合計得点の値 -->
        <template v-slot:item.score="{ value }">
          <div class="text-right">
            {{ value }}
          </div>
        </template>
      </v-data-table>
    </v-row>

    <v-tooltip v-if="isStaff" bottom>
      <template v-slot:activator="{ on }">
        <v-btn class="hide-on-print" @click="capture" v-on="on">
          キャプチャ
        </v-btn>
      </template>

      <span>プリントダイアログでスケールとマージンを調整してください</span>
    </v-tooltip>
  </div>
</template>
<script>
import orm from '~/orm'

export default {
  name: 'ReportCardTable',
  computed: {
    reportCards() {
      return orm.ReportCard.all()
    },
    problemTitles() {
      if (this.reportCards.length === 0) {
        return []
      }

      return this.reportCards.find(e => e.teamName === '満点').problemTitles
    },
    problemGenres() {
      if (this.reportCards.length === 0) {
        return []
      }

      return this.reportCards.find(e => e.teamName === '満点').problemGenres
    },
    problemTitleHeaders() {
      return this.problemTitles.map((title, index) => ({
        text: title,
        value: `eachScore[${index}]`,
        divider: true,
        class: 'pa-2'
      }))
    },
    problemTitleItemValues() {
      return this.problemTitleHeaders.map(header => `item.${header.value}`)
    },
    problemTitleHeaderValues() {
      return this.problemTitleHeaders.map(header => `header.${header.value}`)
    },
    headers() {
      if (this.problemTitleHeaders.length === 0) {
        return []
      }

      return [
        { text: 'チーム', value: 'teamName', divider: true },
        {
          text: '順位',
          value: 'rank',
          divider: true,
          class: 'text-center text-no-wrap'
        },
        {
          text: '得点',
          value: 'score',
          divider: true,
          class: 'text-center text-no-wrap'
        },
        ...this.problemTitleHeaders
      ]
    }
  },
  beforeCreate() {
    orm.Queries.reportCards()
  },
  methods: {
    scoreColor(percent) {
      // alphaは0~100の20きざみ
      return `rgba(20, 230, 138, ${(Math.floor(percent / 20) * 20) / 100})`
    },
    capture() {
      const hideNodes = document.querySelectorAll('.hide-on-print')
      const vContent = document.querySelector('.v-content')
      const paddingTop = vContent.style.paddingTop

      vContent.style.paddingTop = ''
      hideNodes.forEach(node => (node.style.display = 'none'))

      window.print()

      hideNodes.forEach(node => (node.style.display = ''))
      vContent.style.paddingTop = paddingTop

      // TODO: writing-modeをサポートしてないためスタイルが崩れる
      // this.captureById('table', '成績表.png')
    }
  }
}
</script>
<style scoped lang="sass">
.problem-title
  height: 16em
  writing-mode: vertical-rl
  text-orientation: sideways
.negate-px
  margin: 0px -16px
.score
  padding-top: 24px
  line-height: 0px
</style>
