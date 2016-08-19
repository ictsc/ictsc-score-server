import { ActivatedRoute } from '@angular/router';
import { Component, SimpleChanges, Input } from '@angular/core';
import { ApiService, MiniList ,Time } from "../common";
import { Problem } from "../";

// <problem id="1" [team=""] [issue=""] [show="issue|answer|all"] [mode="issue(default)|answer"]>
@Component({
  selector: Issue.name.toLowerCase(),
  directives: [ Problem ],
  template: `<problem [id]="problemId" [team]="team" [issue]="issue" mode="issue"></problem>`
})
export class Issue {
  constructor(private api: ApiService, private route: ActivatedRoute) {}
  problemId: string;
  team: string;
  issue: string;

  ngOnInit() {
    this.route.params.subscribe(parms => {
      this.problemId = parms["problem"];
      this.team = parms["team"];
      this.issue = parms["issue"];
      console.log("params", parms, this);
    });
  }

}
