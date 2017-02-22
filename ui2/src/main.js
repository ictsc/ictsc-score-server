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


const router = new VueRouter({
  routes: [
    { path: '/', component: require('./pages/Dashboard'), name: 'dashboard' },
    { path: '/login', component: require('./pages/Login'), name: 'login' },
    { path: '/signup', component: require('./pages/Signup'), name: 'signup' },
    { path: '/teams', component: require('./pages/Teams'), name: 'teams' },
    { path: '/teams/:id', component: require('./pages/TeamDetail'), name: 'team-detail' },
    { path: '/problems', component: require('./pages/Problems'), name: 'problems' },
    { path: '/problems/:id', component: require('./pages/ProblemDetail'), name: 'problemDetail' },
    { path: '*', component: require('./pages/NotFound'), name: 'not-found' },
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
