import BaseModel from '~/orm/BaseModel'

export default class Config extends BaseModel {
  static entity = 'configs'
  static primaryKey = 'key'

  static fields() {
    return {
      key: this.string(),
      value: this.string(),
      valueType: this.string(),
    }
  }

  get parsedValue() {
    return JSON.parse(this.value)
  }

  get displayValue() {
    if (this.valueTypeIsDate) {
      // e.g. 2112-09-03 12:00+09:00
      return $nuxt.$moment(this.parsedValue).format('YYYY-MM-DD HH:mmZ')
    } else {
      return this.value
    }
  }

  get valueTypeIsBoolean() {
    return this.valueType === 'boolean'
  }

  get valueTypeIsInteger() {
    return this.valueType === 'integer'
  }

  get valueTypeIsString() {
    return this.valueType === 'string'
  }

  get valueTypeIsDate() {
    return this.valueType === 'date'
  }
}
