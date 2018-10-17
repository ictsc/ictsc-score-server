<template>
  <div>
    <div class="graph-container">
      <svg>
        <defs>
          <clipPath class="graph-clip">
            <rect></rect>
          </clipPath>
        </defs>
        <g class="graph-area">
          <path class="axis-background y"></path>
          <path class="axis-background x"></path>
          <g class="axis x"></g>
          <g class="axis y"></g>
          <g class="graph-body">
            <path class="graph-background"></path>
          </g>
          <path class="cursor"></path>
        </g>
      </svg>
    </div>
  </div>
</template>

<style scoped>
.graph-container .cursor {
  fill: none;
  stroke: #5C6171;
  stroke-width: 2px;
  opacity: 0.6;
}
</style>

<style>
.graph-container .axis-background.x {
  fill: #ddd;
}
.graph-container .axis-background.y {
  fill: #eee;
}
.graph-container .line {
  fill: none;
  stroke-width: 1px;
}
.graph-container {
  background-color: #222;
}
</style>

<script>
export default require('./GraphScripts').default
</script>
