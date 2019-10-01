// ローカルストレージはそのまま使うと意図しない型変換を起こすため、全てJSONでやりとりする
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

  static hasKey(key) {
    // 該当するキーが無いとnullが返ってくる
    return localStorage.getItem(key) !== null
  }

  static get(key, defaultValue) {
    if (!this.hasKey(key)) {
      return defaultValue
    }

    return JSON.parse(localStorage.getItem(key))
  }

  static set(key, value) {
    // JSONにundefinedは存在しないため、該当keyを削除する
    if (value === undefined) {
      this.remove(key)
      return
    }

    localStorage.setItem(key, JSON.stringify(value))
  }

  static remove(key) {
    localStorage.removeItem(key)
  }
}

export default ({ app }, inject) => inject('jsonStorage', JsonStroage)
