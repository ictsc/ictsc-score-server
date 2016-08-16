import { Response } from '@angular/http';
import { Component } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { ApiService, MiniForm } from "../common";
import { Signup } from "../login/signup.component";

import { Observable } from "rxjs";

@Component({
  selector: TeamsDetail.name,
  template: require('./teams-detail.template.jade'),
  directives: []
})
export class TeamsDetail extends MiniForm {
  constructor(private api: ApiService, private route: ActivatedRoute) {super();}
  public form = {
    login: "",
    name: "",
  }
  private teamId: string;
  private teamsDetail = [];

  ngOnInit() {
    this.route.params.subscribe(parms => {
      this.teamId = parms["id"];
    });
    this.api.teamsDetail().subscribe(d => {
      console.log("details", d)
      this.teamsDetail = d;
    });
  }

  get team(){
    return this.teamsDetail.find(t => t.id == this.teamId);
  }
  getPointStr(answer_id: string){
    // let point = this.getPoint(answer_id);
    // if(point) return `${point} 点`;
    // else return "未採点";
    return
  }
}

