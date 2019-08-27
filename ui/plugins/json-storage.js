// ローカル外レージはそのまま使うと、意図しない型返還を起こすため全てJSONでやりとりする
export class JsonStroage {
  constructor(key, defaultValue) {
    this.key = key
    this.defaultValue = defaultValue
  }

  get() {
    return JsonStroage.get(this.key, this.defaultValue)
  }

  set(value) {
    JsonStroage.set(this.key, value)
  }

  // Vueにmixinするとリアクティブにローカルストレージを扱える
  static accessor(preifx, key, defaultValue) {
    const storage = new JsonStroage(`${preifx}-${key}`, defaultValue)

    return {
      data() {
        return {
          [key]: storage.get()
        }
      },
      watch: {
        [key](value) {
          storage.set(value)
        }
      }
    }
  }

  static get(key, defaultValue) {
    // getLocalStorage内でJSON.parseされる
    // eslint-disable-next-line no-undef
    const value = $nuxt.$storage.getLocalStorage(key)
    return (value === null || value === undefined) && defaultValue !== undefined
      ? defaultValue
      : value
  }

  static set(key, value) {
    // JSONにundefinedは存在しないため、該当keyを削除する
    // ストレージがない場合getの戻り地はundefinedになる
    if (value === undefined) {
      // eslint-disable-next-line no-undef
      $nuxt.$storage.removeLocalStorage(key)
      return
    }

    // eslint-disable-next-line no-undef
    $nuxt.$storage.setLocalStorage(key, JSON.stringify(value))
  }
}

export default ({ app }, inject) => inject('jsonStorage', JsonStroage)
