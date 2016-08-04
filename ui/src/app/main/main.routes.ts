import { WebpackAsyncRoute } from '@angularclass/webpack-toolkit';
import { RouterConfig } from '@angular/router';

import { Home } from '../home';
import { Teams } from '../teams';
import { Login } from '../login';
import { NoContent } from '../no-content';

import { DataResolver } from './main.resolver';
import { AuthGuard } from '../common/authguard';



let canActivate =  [AuthGuard];

import { Members, MembersList, MembersEdit } from "../members"

export const routes: RouterConfig = [
  { path: '', component: Home, canActivate },
  { path: 'login', component: Login },
  {
    path: 'members', component: Members,
    canActivate,
    children: [
      { path: 'edit/:id', component: MembersEdit },
      { path: '', component: MembersList },
    ]
  },
  { path: 'teams', component: Teams },
  { path: '**', component: NoContent },
];


export const asyncRoutes: AsyncRoutes = {
  // we have to use the alternative syntax for es6-promise-loader to grab the routes
  // 'About': require('es6-promise-loader!../about'),
  // 'Detail': require('es6-promise-loader!../+detail'),
  // 'Index': require('es6-promise-loader!../+detail'),
  // 'Login': require('es6-promise-loader!../login'),
  // 'Members': require('es6-promise-loader!../+members'),
  // 'EditMembers': require('es6-promise-loader!../members'),
  // 'Teams': require('es6-promise-loader!../teams'),
};


// Optimizations for initial loads
// An array of callbacks to be invoked after bootstrap to prefetch async routes
export const prefetchRouteCallbacks: Array<IdleCallbacks> = [
  // asyncRoutes['About'],
  // asyncRoutes['Detail'],
  // asyncRoutes['Login'],
   // es6-promise-loader returns a function
];


// Es6PromiseLoader and AsyncRoutes interfaces are defined in custom-typings
