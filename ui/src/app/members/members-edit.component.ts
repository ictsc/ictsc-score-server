import { Response } from '@angular/http';
import { Component } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { ApiService, Miniform } from "../common";
import { Signup } from "../login/signup.component";

import { Observable } from "rxjs";

@Component({
  styles: [
    require('./members.style.scss'),
  ],
  template: require('./members-edit.template.jade'),
  directives: [Signup]
})
export class MembersEdit extends Miniform {
  constructor(private api: ApiService, private route: ActivatedRoute) {super();}

  // private list: any[] = [];
  // private team: any[] = [];
  // private text: string;

  // public form = {
  //   login: "",
  //   name: "",
  // }
  private id: string;

  ngOnInit() {
    this.route.params.subscribe(parms => {
      this.id = parms["id"];
    });
  }
  // private id: string;

  // ngOnInit() {
  //   let membersSource = this.api.members.get();
  //   let teamsSource = this.api.teams.get();
  //   let parmsSource = this.route.params;

  //   Observable
  //     .forkJoin(membersSource, teamsSource)
  //     .combineLatest(parmsSource)
  //     .subscribe(arg => {
  //       let [[members, teams], params] = arg as any;
  //       this.id = params["id"];
  //       this.list = members;
  //       this.team = teams;

  //       this.list.filter(m => m.id == this.id)
  //       console.log(members, teams, params);
  //     });
  // }

  // getTeam(id: number){
  //   if(!this.team)
  //     return undefined;
  //   return this.team.find(r => (r as any).id == id);
  // }

  // post(){
  //   return this.api.members.modify(this.id, Object.assign(this.form, {
  //   }));
  // }
  // success(response: any){
  //   console.log("OK");
  // }
  // error(response: Response){
  //   return "登録に失敗しました。" + response.json().login;
  // }
}

