<template>
  <div class="steps d-flex">
    <div class="item">
      <h4>各カテゴリから問題を選んで解答</h4>
      <p>解放されている問題を選択し、解答を行ってください。</p>
    </div>
    <div class="item">
      <!-- TODO: 20分 を切り出す -->
      <h4>運営が採点 (20分間)</h4>
      <p>運営が採点中はその問題を解けません。</p>
    </div>
    <div class="item">
      <h4>採点結果を確認</h4>
      <p>満点でない場合は、高得点を目指して追加の解答も可能です。</p>
    </div>
  </div>
</template>

<style scoped>
.steps {
  margin: 2rem 0;
}
.steps .item {
  flex-grow: 1;
  min-width: 5rem;
  padding: 1rem;
  padding-right: 4rem;
  background: #efefef;
  position: relative;
  background-image: url('~assets/arrow.svg');
  background-repeat: repeat-y;
  background-position: right center;
}
.steps .item:last-child {
  background-image: none;
  padding-right: 1rem;
}
.steps .item p {
  margin: 0;
}
</style>

<script>
export default {
}
</script>
