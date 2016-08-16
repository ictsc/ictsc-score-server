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
}
