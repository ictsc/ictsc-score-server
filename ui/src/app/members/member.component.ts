import { Observable } from 'rxjs';
import { MiniList, ApiService, Editable } from '../common';
import { Component, SimpleChanges } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { AppState } from '../main/main.service';

@Component({
  selector: Member.name.toLowerCase(),
  template: require('./member.template.jade'),
  directives: [ Editable ]
})
export class Member extends MiniList {
  constructor(private api: ApiService, private route: ActivatedRoute) {
    super();
    this.list = [[],[],[]];
  }

  isAdmin = false;
  teams = [];
  ngOnInit() {
    this.api.isAdmin().subscribe(r => this.isAdmin = r);
    this.route.params.subscribe(param => {
      this.id = param["id"];
      this.fetch()
    });
  }

  edit = false;

  ngOnChanges(changes: SimpleChanges){
  }
  id: any;
  get(){
    return Observable.combineLatest(
      this.api.members.item(this.id),
      this.api.teams.list()
    ).map(r => {
      let [member, teams] = r as any;
      this.teams = teams;
      member.team = teams.find(t => t.id == member.team_id);
      member.password = "";
      return member;
    }).do(d => console.log("get member", d));
  }

  getTeam(id){
    if(!this.teams) return undefined;
    return this.teams.find(r => r.id == id);
  }

  update(){
    let obj = Object.assign({}, this.list);
    if(!obj.password || obj.password == "")
      delete obj.password;
    this.api.members.modify(this.id, obj)
      .subscribe(r => {
        this.edit = false;
        this.fetch();
      }); 
  }
  cancel(){
    this.edit = false;
    this.fetch();
  }

  genpass(){
    (this.list as any).password = Math.random().toString(36).substr(2,12); 
  }
}
