import Push from 'push.js'

// https://pushjs.org/docs/options
export default ({ app }, inject) => inject('push', Push)
