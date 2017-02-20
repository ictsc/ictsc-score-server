import Vue from 'vue'
require('babel-polyfill');
import VueRouter from 'vue-router'
Vue.use(VueRouter);

import Element from 'element-ui'
Vue.use(Element);
import 'element-ui/lib/theme-default/index.css'
import 'bootstrap/dist/css/bootstrap.css';
import 'font-awesome/css/font-awesome.css';

import { AsyncDataPlugin } from 'vue-async-data'
Vue.use(AsyncDataPlugin)

import App from './App'
import { DefaultStore as store } from './store'


import Hello from './pages/Hello'

const router = new VueRouter({
  routes: [
    { path: '/', component: Hello, name: 'home' },
  ]
})

/* eslint-disable no-new */
new Vue({
  el: '#app',
  template: '<App/>',
  components: { App },
  router,
  store,
})
