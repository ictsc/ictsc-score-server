// ローカル外レージはそのまま使うと、意図しない型返還を起こすため全てJSONでやりとりする
class JsonStroage {
  static get(key) {
    // getLocalStorage内でJSON.parseされる
    // eslint-disable-next-line no-undef
    return $nuxt.$storage.getLocalStorage(key)
  }

  static set(key, value) {
    const storeValue =
      value === null || value === undefined ? null : JSON.stringify(value)

    // eslint-disable-next-line no-undef
    $nuxt.$storage.setLocalStorage(key, storeValue)
  }
}

export default ({ app }, inject) => inject('jsonStorage', JsonStroage)
