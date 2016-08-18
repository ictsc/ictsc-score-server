import { WebpackAsyncRoute } from '@angularclass/webpack-toolkit';
import { RouterConfig } from '@angular/router';
import { AuthGuard } from '../common/authguard';
import * as Page from '../index';


let canActivate =  [AuthGuard];


export const routes: RouterConfig = [
  { path: '', component: Page.Home, canActivate },
  { path: 'login', component: Page.Login },
  {
    path: 'members', component: Page.Members,
    canActivate,
    children: [
      { path: 'edit/:id', component: Page.MembersEdit },
      { path: '', component: Page.MembersList },
    ]
  },
  { path: 'teams/:id', component: Page.TeamsDetail, canActivate },
  { path: 'teams', component: Page.Teams, canActivate },
  { path: 'problems/:id', component: Page.ProblemsDetail, canActivate },
  { path: 'problems', component: Page.Problems, canActivate },
  { path: 'issues', component: Page.Issues, canActivate },
  { path: 'issues/:problem/:team', component: Page.IssueDetail, canActivate },
  { path: 'issues/:problem/:team/:issue', component: Page.IssueDetail, canActivate },
  { path: '**', component: Page.NoContent },
];


export const asyncRoutes: AsyncRoutes = {
};


export const prefetchRouteCallbacks: Array<IdleCallbacks> = [
];
