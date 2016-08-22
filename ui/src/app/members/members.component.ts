import { Observable } from 'rxjs/Observable';
import { Component } from '@angular/core';
import { ApiService, MiniList } from "../common";
import { Signup } from "../login/signup.component";

@Component({
  template: require('./members.template.jade'),
  directives: [Signup]
})
export class Members extends MiniList {
  constructor(private api: ApiService) {
    super();
    this.list = [[],[]];
  }

  ngOnInit() {
    this.fetch();
  }

  get(){
    return Observable.combineLatest(
      this.api.members.get(),
      this.api.teams.get()
    );
  }

  getTeam(id: number){
    if(!this.list[1])
      return undefined;
    return this.list[1].find(r => (r as any).id == id);
  }

  private roleName = {
    2: "Admin",
    3: "Writer",
    4: "Participant",
    5: "Viewer"
  }

  get participants(){
    return this.list[0].filter(m => m.role_id == 4);
  }
  get others(){
    return this.list[0].filter(m => m.role_id != 4);
  }
}
