import { Component , Input } from '@angular/core';
import { Router } from '@angular/router';
import { Response } from '@angular/http';
import { ApiService } from '../common/api.service'
import { Miniform } from "../common/miniform.component"

@Component({
  selector: 'signup',
  template: require('./signup.template.jade')
})
export class Signup extends Miniform {
  @Input() redirect: boolean = true;

  constructor(
    protected route: Router,
    protected api: ApiService) {super()}
  form = {
    password: "",
    login: "",
    name: "",
  }

  protected teamList: Array<any> = [];
  protected selectedTeamId: string;
  protected get selectedTeam(){
    return this.teamList.find(t => t.id == parseInt(this.selectedTeamId))
  }

  ngOnInit() {
    (window as any).login = this;
    this.api.teams.list().subscribe(r => {
      console.log("team list", r);
      this.teamList = (r as Array<any>);
    });
  }

  post(){
    return this.api.members.add(Object.assign(this.form, {
      team_id: this.selectedTeamId
    }));
  }
  success(response: any){
    console.log("OK");
    if(this.redirect)
      this.route.navigate(["/"]);
  }
  error(response: Response){
    return "登録に失敗しました。" + response.json().login;
  }
}
