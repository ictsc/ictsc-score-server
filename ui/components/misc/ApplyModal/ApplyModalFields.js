// CategoryModal, ProblemModalにmixinする
// ローカルストレージ周りが複雑なためmixinに切り出した

// mixinする側で実装するもの
// item()
// storageKeyPrefix()
// fields()
// fieldKeys()
// 各フィールドのwatch

export default {
  props: {
    isNew: {
      type: Boolean,
      default: false
    }
  },
  data() {
    return {
      ...this.loadFields()
    }
  },

  computed: {
    edited() {
      const fields = this.buildFields()
      return Object.entries(fields).some(([k, v]) => this[k] !== v)
    }
  },
  methods: {
    storageKey(field) {
      const key = this.isNew ? 'new' : this.item()[this.storageKeyUniqueField()]
      return `${this.storageKeyPrefix()}-${key}-${field}`
    },
    getStorage(field, defaultValue) {
      return this.$jsonStorage.get(this.storageKey(field), defaultValue)
    },
    setStorage(field, value) {
      if (!this.isNew) {
        if (this.item()[field] === value) {
          // ストアと同じ値ならストレージから削除
          this.$jsonStorage.set(this.storageKey(field), undefined)
          return
        } else if (!this.storageHasUpdatedAt()) {
          // いずれかのフィールドが編集を初めたらupdatedAtを記録する
          this.setStorageUpdatedAt(this.item().updatedAt)
        }
      }

      // ストレージと同じなら更新しない
      if (this.getStorage(field) === value) {
        return
      }

      this.$jsonStorage.set(this.storageKey(field), value)
    },
    setStorageUpdatedAt(value) {
      this.$jsonStorage.set(this.storageKey('updatedAt'), value)
    },
    buildFields() {
      if (this.isNew) {
        return { ...this.fields() }
      } else {
        return this.fieldKeys().reduce((obj, key) => {
          obj[key] = this.item()[key]
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
    storageHasUpdatedAt() {
      // リアクティブでないためmethodでなければ動作しない
      const updatedAt = this.getStorage('updatedAt')
      return updatedAt !== null && updatedAt !== undefined
    },
    // 別セッションでに変更があったか
    originDataChanged() {
      if (
        this.isNew ||
        !this.storageHasUpdatedAt() ||
        this.getStorage('updatedAt') === this.item().updatedAt
      ) {
        return false
      }

      if (this.edited) {
        return true
      }

      // 一応updatedAtを消しておく
      this.setStorageUpdatedAt(undefined)
      return false
    },
    reset() {
      Object.entries(this.buildFields()).forEach(([k, v]) => {
        this[k] = v
        this.setStorage(k, undefined)
      })
      this.setStorageUpdatedAt(undefined)
      this.$refs.form.resetValidation()
    }
  }
}
