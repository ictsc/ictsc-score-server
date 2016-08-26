import { Response } from '@angular/http';
import { Component } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { ApiService, MiniForm, Editable } from "../common";
import { Signup } from "../login/signup.component";

import { Observable } from "rxjs";

@Component({
  selector: TeamsDetail.name,
  template: require('./teams-detail.template.jade'),
  directives: [ Editable ]
})
export class TeamsDetail extends MiniForm {
  constructor(private api: ApiService, private route: ActivatedRoute) {super();}
  public form = {
    login: "",
    name: "",
  }
  private teamId: string;
  private teamsDetail = [];

  edit = false;

  ngOnInit() {
    this.route.params.subscribe(parms => {
      this.teamId = parms["id"];
    });
    this.fetch();
  }

  fetch(){
    this.api.teamsDetail().subscribe(d => {
      console.log("details", d)
      this.teamsDetail = d;
      this.team = this.teamsDetail.find(t => t.id == this.teamId)
    });
  }

  team;
  getPointStr(answer_id: string){
    // let point = this.getPoint(answer_id);
    // if(point) return `${point} 点`;
    // else return "未採点";
    return
  }

  update(){
    this.api.teams.modify(this.team.id, {
      organization: this.team.organization,
      name: this.team.name
    }).subscribe(r => this.cancel());
  }

  cancel(){
    this.edit = false;
    this.fetch();
  }
}

