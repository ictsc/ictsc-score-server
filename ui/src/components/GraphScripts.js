import * as d3 from 'd3';
import * as _ from 'underscore';

export default {
  name: 'graph',
  data () {
    return {
      width: 100,
    }
  },
  props: {
    height: {
      type: Number,
      default: 250,
    },
    margin: {
      type: Object,
      default: () => ({
        top: 0,
        left: 40,
        bottom: 20,
        right: 0,
      }),
    },
    graphData: {
      type: Array,
      default: () => ([]),
    },
    notfound: {
      type: Boolean,
      default: false,
    },
    title: {
      type: String,
      default: '',
    },
    valueType: {
      type: String,
    }
  },
  asyncData: {
  },
  computed: {
    innerWidth () {
      return this.width - this.margin.right - this.margin.left;
    },
    innerHeight () {
      return this.height - this.margin.top - this.margin.bottom;
    },
  },
  watch: {
    width () {
      this.updateGraph();
    },
    height () {
      this.updateGraph();
    },
    margin () {
      this.updateGraph();
    },
    graphData () {
      this.updateGraph();
    },
    valueType () {
      this.updateGraph();
    },
  },
  mounted () {
    this.updateGraph();

    // ウインドウのリサイズ対応
    this.width = this.$el.clientWidth;
    let resizeHandler = _.debounce(() => {
      this.width = this.$el.clientWidth;
    }, 150)

    window.addEventListener('resize', () => { resizeHandler() });
  },
  destroyed () {
  },
  methods: {
    updateGraph () {
      // if (window) return;

      let data = this.graphData;
      let allAnswers = data.reduce((p, n) => [].concat(p, n.answers ? n.answers : []), []);

      /* ******* utils ******* */
      let x = d3.scaleTime()
        .range([0, this.innerWidth])
        .domain(d3.extent(allAnswers, d => d.date));
      let y = d3.scaleLinear()
        .range([this.innerHeight, 0])
        .domain([0, d3.max(allAnswers, d => d.total)])
        .nice();
      /* ******* end utils ******* */
      console.log('d3.extent(allAnswers, d => d.date)', d3.extent(allAnswers, d => d.date))
      console.log('d3.extent(allAnswers, d => d.date)', allAnswers.filter(d => d.date.toString().indexOf('2017') === -1))

      let svg = d3
        .select(this.$el)
        .select('svg')
        .attr('width', this.width)
        .attr('height', this.height)

      let graphArea = svg
        .selectAll('.graph-area')
        .attr('transform', 'translate(' + this.margin.left + ',' + this.margin.top + ')');


      // 罫線・軸
      let axisBottom = d3
        .axisBottom(x)
        .tickSizeInner(-this.innerHeight)
        .tickSizeOuter(0)
        .tickFormat(d3.timeFormat('%H:%M'))
        .ticks(7);
      graphArea
        .select('.axis.x')
        .attr('transform', 'translate(0,' + this.innerHeight + ')')
        .call(axisBottom);

      let axisLeft = d3
        .axisLeft(y)
        .tickSizeInner(-this.innerWidth)
        .tickSizeOuter(0)
        .ticks(5);
      // 単位設定
      // axisLeft.tickFormat(this.valueTypeSettings().tickFormat);
      graphArea
        .select('.axis.y')
        .call(axisLeft);

      // 軸背景
      graphArea
        .select('.axis-background.y')
        .attr('d', `M0 0v${this.height} h${-this.margin.left} v${-this.height} Z`)
      graphArea
        .select('.axis-background.x')
        .attr('d', `M${-this.margin.left} ${this.height - this.margin.bottom}h${this.width} v${this.margin.bottom} h${-this.width} z`);


      // 折れ線グラフのマスクを定義
      svg
        .select('defs .graph-clip rect')
        .attr('x', 0)
        .attr('y', 0)
        .attr('height', this.innerHeight)
        .attr('width', this.innerWidth)

      d3.select(this.$el)
        .select('.graph-container')
        .on('mousemove', () => {
        })
        .on('mouseout', function () {
        });

      let graphBody = graphArea
        .select('.graph-body')
        .attr('clip-path', 'url(.graph-clip)')

      // グラフ本体の描写
      let writeGraph = d => {
        let teamData = () => graphBody
          .selectAll('.line')
          .data(d)
        let line = d3.line()
          .curve(d3.curveStepAfter)
          .x(d => x(d.date))
          .y(d => y(d.total));
        teamData()
          .enter()
            .append('path')
            .attr('class', 'line')
          .exit()
            .remove()
        teamData()
          .attr('d', d => line(d.answers))
          .attr('stroke', d => {
            console.log(d)
            return d.color;
          })
      }

      if (data && data.length !== 0) {
        writeGraph(data);
      } else {
        writeGraph([]);
      }
    },
  },
}
