import { Observable } from 'rxjs/Observable';
import { Component , Input, SimpleChanges } from '@angular/core';
import { Router } from '@angular/router';
import { Response } from '@angular/http';
import { ApiService } from '../common/api.service'
import { MiniForm } from "../common"

@Component({
  selector: 'signup',
  template: require('./signup.template.jade')
})
export class Signup extends MiniForm {
  @Input() redirect: boolean = true;
  @Input() edit: number = undefined;

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

  private memberSource: Observable<any[]>;

  get isEdit(){
    return typeof this.edit !== "undefined"
  }
  ngOnChanges(changes: SimpleChanges){
    // 編集時の処理
    if(!this.isEdit) return;
    if(!this.memberSource) this.memberSource = this.api.members.list();

    this.memberSource.combineLatest(Observable.of(this.edit))
      .subscribe(r => {
        let [members, id] = r;
        let member = members.find(m => m.id == id);
        console.log("editmode", members, id);

        if(!member) return this.errorMessage = "メンバーが見つかりません。";
        else this.errorMessage = undefined;

        this.selectedTeamId = member.team_id;
        this.form.login = member.login;
        this.form.name = member.name;
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
      this.api.login(this.form.login, this.form.password)
        .subscribe(r => this.route.navigate(["/"]));
  }
  error(response: Response){
    return "登録に失敗しました。" + response.json().login;
  }
}
