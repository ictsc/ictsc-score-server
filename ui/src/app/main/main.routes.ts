import { WebpackAsyncRoute } from '@angularclass/webpack-toolkit';
import { RouterConfig } from '@angular/router';

import * as Page from '../index';


import { DataResolver } from './main.resolver';
import { AuthGuard } from '../common/authguard';



let canActivate =  [AuthGuard];

import { Members, MembersList, MembersEdit } from "../members"

export const routes: RouterConfig = [
  { path: '', component: Page.Home, canActivate },
  { path: 'login', component: Page.Login },
  {
    path: 'members', component: Members,
    canActivate,
    children: [
      { path: 'edit/:id', component: MembersEdit },
      { path: '', component: MembersList },
    ]
  },
  { path: 'teams', component: Page.Teams, canActivate },
  { path: 'problems', component: Page.Problems, canActivate },
  { path: 'issue', component: Page.Issue, canActivate },
  { path: '**', component: Page.NoContent },
];


export const asyncRoutes: AsyncRoutes = {
};


export const prefetchRouteCallbacks: Array<IdleCallbacks> = [
];


// Es6PromiseLoader and AsyncRoutes interfaces are defined in custom-typings
