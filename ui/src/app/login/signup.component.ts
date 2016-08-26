import { Observable } from 'rxjs/Observable';
import { Component , Input, SimpleChanges } from '@angular/core';
import { Router } from '@angular/router';
import { Response } from '@angular/http';
import { ApiService } from '../common/api.service'
import { MiniForm } from "../common"

let sha1 = require("sha1");

@Component({
  selector: 'signup',
  template: require('./signup.template.jade')
})
export class Signup extends MiniForm {
  @Input() redirect: boolean = true;

  constructor(
    protected route: Router,
    protected api: ApiService) {super()}
  form = {
    password: "",
    login: "",
    name: "",
    registration_code: "",
  }

  protected teamList: Array<any> = [];
  protected selectedTeamId: string;
  protected get selectedTeam(){
    return this.teamList.find(t => t.id == parseInt(this.selectedTeamId))
  }

  isAdmin;

  ngOnInit() {
    (window as any).login = this;
    this.api.teams.list().subscribe(r => {
      console.log("team list", r);
      this.teamList = (r as Array<any>);
    });
    this.api.isAdmin().subscribe(r => this.isAdmin = r);
  }

  private memberSource: Observable<any[]>;

  codeChange(){
    console.log()
    let find = this.teamList.find(r => r.hashed_registration_code == sha1(this.form.registration_code));
    if(find)
      this.selectedTeamId = find.id;
    else
      this.selectedTeamId = undefined;
    console.log("code change", this.form.registration_code, find);
  }

  post(){
    return this.api.members.add(Object.assign(this.form, {
      team_id: this.selectedTeamId
    }));
  }
  success(response: any){
    console.log("OK");
    if(this.redirect)
      this.api.login(this.form.login, this.form.password)
        .subscribe(r => this.route.navigate(["/"]));
    else
      this.form = {
        password: "",
        login: "",
        name: "",
        registration_code: "",
      }
  }
  error(response: Response){
    return "登録に失敗しました。" + response.json().login;
  }
}
