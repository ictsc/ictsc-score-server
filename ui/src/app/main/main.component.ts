import { Router } from '@angular/router';
import { Component, ViewEncapsulation } from '@angular/core';
import { ApiService } from '../common';
import 'bootstrap/dist/css/bootstrap.css';
import { Observable } from "rxjs";

@Component({
  selector: 'main',
  encapsulation: ViewEncapsulation.None,
  styles: [
    require('../../../../design/src/scss/style.scss'),
    `body { font-family: "游ゴシック Medium", "メイリオ", meiryo, "Helvetica Neue", Helvetica, Arial, sans-serif; }`
  ],
  template: require("./main.template.jade")
})
export class Main {
  constructor(public router: Router, public api: ApiService) {}

  isAdmin = this.api.isAdmin();
  loginMember;

  ngOnInit() {
    this.api.getLoginMember()
      .concatMap(m => {
        if(!m.team_id) return Observable.of(m);
        return this.api.teams.item(m.team_id)
          .map(t => { m.team = t; return m; });
      })
      .subscribe(a => this.loginMember = a);
  }

  logout(){
    this.api.logout().subscribe(r => this.router.navigate(["login"]));
  }
}
