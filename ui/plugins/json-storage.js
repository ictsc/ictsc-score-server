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
  static accessor(key, defaultValue) {
    const storage = new JsonStroage(key, defaultValue)

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
    return value === null && defaultValue !== undefined ? defaultValue : value
  }

  static set(key, value) {
    const storeValue =
      value === null || value === undefined ? null : JSON.stringify(value)

    // eslint-disable-next-line no-undef
    $nuxt.$storage.setLocalStorage(key, storeValue)
  }
}

export default ({ app }, inject) => inject('jsonStorage', JsonStroage)
