import { Observable } from 'rxjs';
import { MiniList, ApiService } from '../common';
import { Component, SimpleChanges } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { AppState } from '../main/main.service';

@Component({
  selector: Member.name.toLowerCase(),
  template: require('./member.template.jade')
})
export class Member extends MiniList {
  constructor(private api: ApiService, private route: ActivatedRoute) {
    super();
    this.list = [[],[],[]];
  }

  ngOnInit() {
    this.route.params.subscribe(param => {
      this.id = param["id"];
      this.fetch()
    });
  }

  ngOnChanges(changes: SimpleChanges){
  }
  id: any;
  get(){
    return Observable.combineLatest(
      this.api.members.item(this.id),
      this.api.teams.list()
    ).map(r => {
      let [member, teams] = r as any;
      member.team = teams.find(t => t.id == member.team_id);
      return member;
    }).do(d => console.log("get member", d));
  }
}
