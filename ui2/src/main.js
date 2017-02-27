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
    { path: '/problems/:id', component: require('./pages/ProblemDetail'), name: 'problem-detail' },
    { path: '/problems/:id/:team/issues/:issue?', component: require('./pages/ProblemIssues'), name: 'problem-issues' },
    { path: '/problems/:id/:team/answers', component: require('./pages/ProblemAnswers'), name: 'problem-answers' },
    { path: '/issues', component: require('./pages/Issues'), name: 'issues' },
    { path: '/answers', component: require('./pages/Answers'), name: 'answers' },
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
