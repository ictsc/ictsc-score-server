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
  fill: #111165;
}
.graph-container .axis-background.y {
  fill: #111165;
}
.graph-container .line {
  fill: none;
  stroke-width: 2px;
}
.graph-container {
  background-color: #111;
}
text {
  color: #ccc;
  font-size: 1rem;
}
</style>

<script>
export { default } from './GraphScripts';
</script>
