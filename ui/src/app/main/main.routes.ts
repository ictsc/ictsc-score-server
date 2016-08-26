import { WebpackAsyncRoute } from '@angularclass/webpack-toolkit';
import { RouterConfig } from '@angular/router';
import { AuthGuard } from '../common/authguard';
import * as Page from '../index';


let canActivate =  [AuthGuard];


export const routes: RouterConfig = [
  { path: '', component: Page.Home, canActivate },
  { path: 'login', component: Page.Login },
  { path: 'guide', component: Page.Guide},
  { path: 'members', component: Page.Members, canActivate },
  { path: 'members/:id', component: Page.Member, canActivate },
  { path: 'teams', component: Page.Teams, canActivate },
  { path: 'teams/:id', component: Page.TeamsDetail, canActivate },
  { path: 'problems/:id', component: Page.ProblemsDetail, canActivate },
  { path: 'problems', component: Page.Problems, canActivate },
  { path: 'issues', component: Page.Issues, canActivate },
  // { path: 'issues/:issue', component: Page.Issue, canActivate },
  { path: 'issues/:problem/:team', component: Page.Issue, canActivate },
  { path: 'issues/:problem/:team/:issue', component: Page.Issue, canActivate },
  { path: 'answers', component: Page.Answers, canActivate },
  { path: 'answers/:problem/:team', component: Page.Answer, canActivate },
  { path: '**', component: Page.NoContent },
];


export const asyncRoutes: AsyncRoutes = {
};


export const prefetchRouteCallbacks: Array<IdleCallbacks> = [
];
