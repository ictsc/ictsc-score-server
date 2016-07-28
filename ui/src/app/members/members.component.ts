import { Component } from '@angular/core';
import { ApiService } from "../common/api.service";
import { Signup } from "../login/signup.component";

@Component({
  styles: [ require('./members.style.scss') ],
  template: require('./members.template.jade'),
  directives: [Signup]
})
export class Members {
  localState = { value: '' };
  constructor(private api: ApiService) {}

  private list: Object[] = [];
  private team: Object[] = [];
  ngOnInit() {
    this.api.members.get().subscribe(r => this.list = r);
    this.api.teams.get().subscribe(r => this.team = r);
  }

  getTeam(id: number){
    if(!this.team)
      return undefined;
    return this.team.find(r => (r as any).id == id);
  }

  private roleName = {
    2: "Admin",
    3: "Writer",
    4: "Participant",
    5: "Viewer"
  }
}
