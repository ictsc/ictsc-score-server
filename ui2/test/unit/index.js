// Polyfill fn.bind() for PhantomJS
/* eslint-disable no-extend-native */
Function.prototype.bind = require('function-bind')

// require all src files except main.js for coverage.
// you can also change this to match only the subset of files that
// you want coverage for.
// const srcContext = require.context('../../src', true, /^\.\/(?!main(\.js)?$)/)
const srcContext = require.context('../../src', true, /^\.\/((?!main\.js$)(?=.*\.(js|vue)$))/)
srcContext.keys().forEach(srcContext)


const testsContextInSrc = require.context('../../src', true, /\.spec$/)
testsContextInSrc.keys().forEach(testsContextInSrc);
