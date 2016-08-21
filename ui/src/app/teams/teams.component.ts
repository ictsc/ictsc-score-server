import { Component } from '@angular/core';
import { ApiService, MiniList } from "../common";
import { Signup } from "../login/signup.component";

@Component({
  template: require('./teams.template.jade'),
})
export class Teams extends MiniList {
  constructor(private api: ApiService) {super()}

  ngOnInit() {
    this.fetch();
  }

  get(){
    return this.api.teamsDetail();
  }

  teamNo: number;
  teamName = "";
  teamOrg = "";

  post(){
    return this.api.teams.add({
      id: this.teamNo,
      name: this.teamName,
      organization: this.teamOrg,
    }).subscribe(r => {
      this.teamName = "";
      this.teamOrg = "";
      this.teamNo = undefined;
      this.fetch();
    });
  }
}
