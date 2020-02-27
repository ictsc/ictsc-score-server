// CategoryModal, ProblemModal, TeaModalにmixinする
// ローカルストレージ周りが複雑なためmixinに切り出した

// mixinする側で実装するもの
// storageKeyPrefix()
// storageKeyUniqueField()
// fields()
// fieldKeys()
// fetchSelf()
// 各フィールドのwatch

export default {
  props: {
    item: {
      type: Object,
      default: null
    },
    isNew: {
      type: Boolean,
      default: false
    }
  },
  data() {
    return {
      ...this.loadFields(),
      conflictFields: []
    }
  },
  computed: {
    edited() {
      return this.fieldKeys().some(key => {
        // リアクティブにするために無理やり関連付け
        // eslint-disable-next-line no-unused-expressions
        this[key]
        return this.storageHasKey(key)
      })
    },
    conflicted() {
      // 別セッションで行った変更とコンフリクトしたか
      return !this.isNew && this.conflictFields.length !== 0
    }
  },
  watch: {
    item(value) {
      const conflictFields = []

      this.fieldKeys().forEach(key => {
        if (!this.storageHasKey(key)) {
          // keyが無いなら変更されてないので最新版を取り込む
          // VuexORMのバグか仕様でnullがundefinedになることがあるでのnullに揃える
          this[key] = value[key] === undefined ? null : value[key]
        } else if (this.isSame(value[key], this.getStorage(key))) {
          // 最新の値と編集中の値が一致したらストレージを削除
          this.removeStorage(key)
        } else if (!this.isSame(value[key], this.getStorageOld(key))) {
          // 最新の値が編集開始時の値と違うならコンフリクト
          conflictFields.push(key)

          // UIに表示するのは長文対応が面倒なのでコンソールに出す
          console.warn('conflict key:', key)
          console.warn('current:', JSON.stringify(this.getStorage(key)))
          console.warn('latest:', JSON.stringify(value[key]))
        }
      })

      this.conflictFields = conflictFields
    }
  },
  methods: {
    storageKey(field) {
      const key = this.isNew ? 'new' : this.item[this.storageKeyUniqueField()]
      return `${this.storageKeyPrefix()}-${key}-${field}`
    },
    storageKeyOld(field) {
      return this.storageKey(field + '-old')
    },
    storageHasKey(field) {
      return this.$jsonStorage.hasKey(this.storageKey(field))
    },
    storageHasKeyOld(field) {
      return this.$jsonStorage.hasKey(this.storageKeyOld(field))
    },
    getStorage(field, defaultValue) {
      return this.$jsonStorage.get(this.storageKey(field), defaultValue)
    },
    getStorageOld(field) {
      return this.$jsonStorage.get(this.storageKeyOld(field))
    },
    removeStorage(field) {
      this.$jsonStorage.set(this.storageKey(field), undefined)
      this.$jsonStorage.set(this.storageKeyOld(field), undefined)
    },
    setStorage(field, value) {
      const defaultValue = this.isNew ? this.fields()[field] : this.item[field]

      if (this.isSame(value, defaultValue)) {
        // デフォルト値か変更前の値と同じ値ならストレージから削除して終了
        this.removeStorage(field)
        return
      }

      // ストレージと同じなら更新しない
      if (this.isSame(value, this.getStorage(field))) {
        return
      }

      // 初回の変更時のみ元の値を記録する
      if (!this.isNew && !this.storageHasKeyOld(field)) {
        this.$jsonStorage.set(this.storageKeyOld(field), this.item[field])
      }

      this.$jsonStorage.set(this.storageKey(field), value)
    },
    buildFields() {
      if (this.isNew) {
        // 新規なら予め定義された初期値をcopyして展開
        return { ...this.fields() }
      } else {
        // 既存ならitem(主にVuexから取得した値)をcopy
        return this.fieldKeys().reduce((obj, key) => {
          obj[key] = this.item[key]

          // VuexORMのバグか仕様でnullがundefinedになることがあるでのnullに揃える
          if (obj[key] === undefined) {
            obj[key] = null
          }

          return obj
        }, {})
      }
    },
    // フィールドをローカルストレージから読み出す
    loadFields() {
      // デフォルト値
      const fields = this.buildFields()

      // ローカルストレージから値を取得する. なければデフォルト値
      Object.entries(fields).forEach(
        ([k, v]) => (fields[k] = this.getStorage(k, v))
      )

      return fields
    },
    reset() {
      Object.entries(this.buildFields()).forEach(([k, v]) => {
        this[k] = v
        this.removeStorage(k, undefined)
      })
      this.conflictFields = []
      this.$refs.form.resetValidation()
    }
  }
}
