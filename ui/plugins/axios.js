export default function ({ $axios, redirect }) {
  // 全てのステータスコードで例外を発生させない
  $axios.defaults.validateStatus = null
}
