import Vue from 'vue'

// elvis operator
// RubyのSafe Navigation Operator(&.)
// ネストされた値を安全に取得する
// 子が存在しない時点でundefinedを返す
export function elvis(parent, childrens) {
  for (const child of childrens.split('.')) {
    if (parent === null || parent === undefined) {
      break
    }

    parent = parent[child]
  }

  return parent
}

// template内で使えるようにする
Vue.mixin({
  // 引数を取るため、関数を戻り値にする
  computed: { elvis: () => elvis },
})

// Vueのコンテキストに注入する(this.$elvis, $nuxt.elvis)
export default ({ app }, inject) => inject('elvis', elvis)
