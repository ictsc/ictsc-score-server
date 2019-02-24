<template>
  <div>
    <div class="graph-container">
      <svg>
        <defs>
          <clipPath class="graph-clip">
            <rect />
          </clipPath>
        </defs>
        <g class="graph-area">
          <path class="axis-background y" />
          <path class="axis-background x" />
          <g class="axis x" />
          <g class="axis y" />
          <g class="graph-body">
            <path class="graph-background" />
          </g>
          <path class="cursor" />
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
export { default } from './GraphScripts';
</script>
