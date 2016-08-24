import { Router } from '@angular/router';
import { Component, ViewEncapsulation } from '@angular/core';
import { ApiService } from '../common';
import 'bootstrap/dist/css/bootstrap.css';
import { Observable } from "rxjs";
import { MainClock } from "./main-clock.component";

@Component({
  selector: 'main',
  encapsulation: ViewEncapsulation.None,
  styles: [
    require('../../../../design/src/scss/style.scss'),
    require('./main.style.scss'),
    `body { font-family: "游ゴシック Medium", "メイリオ", meiryo, "Helvetica Neue", Helvetica, Arial, sans-serif; }`
  ],
  template: require("./main.template.jade"),
  directives: [ MainClock ],
})
export class Main {
  constructor(public router: Router, public api: ApiService) {}

  isAdmin = false;
  loginMember;

  datetime = {date: "", time: ""};

  ngOnInit() {
    this.api.changeUser.subscribe(r => {
      console.warn("change user", r);
      this.api.isAdmin().subscribe(r => this.isAdmin = r);

      this.api.getLoginMember()
        .concatMap(m => {
          if(!m.team_id) return Observable.of(m);
          return this.api.teams.item(m.team_id)
            .map(t => { m.team = t; return m; });
        })
        .subscribe(a => this.loginMember = a);
    });
    // Observable.timer(0, 1000)
    //   .subscribe(_ => {
    //     let d = new Date();
    //     this.datetime.date = `${d.getMonth()+1}/${d.getDate()}`;
    //     this.datetime.time = `${d.getHours()}:${d.getMinutes()}:${d.getSeconds()}`;
    //   });
  }

  logout(){
    this.api.logout().subscribe(r => this.router.navigate(["login"]));
  }
}
