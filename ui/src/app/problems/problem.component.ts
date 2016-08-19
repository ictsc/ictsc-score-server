import { Component, SimpleChanges, Input } from '@angular/core';
import { ApiService, MiniList, Markdown, Time } from "../common";

/**
 * <problem id="1" [team=""] [issue=""] [show="issue|answer|all"] [mode="issue|answer"]>
 */

@Component({
  selector: Problem.name.toLowerCase(),
  template: require('./problem.template.jade'),
  directives: [Markdown]
})
export class Problem {
  constructor(private api: ApiService) {}

  @Input() id: string;
  @Input() team: string;
  @Input() issue: string;
  @Input() show: string;
  @Input() mode: string;

  problemData: any;
  issues: any;

  ngOnInit() {
    console.log("Problem", this);
  }

  ngOnChanges(changes: SimpleChanges){
    console.log("Problem Changes",changes);

    if("id" in changes)
      this.api.problems.item(this.id).subscribe(p => this.problemData = p);

    if("issue" in changes){
      let src = this.isSingleIssue?
        this.api.issues.item(this.issue).map(a => [a])
        :this.api.issues.list();
      src.subscribe(p => {
        for(let a of p){
          this.api.issueComments(a.id).list()
            .subscribe(i => a.comments = i);
        }
        this.issues = p;
        console.log("Done fetch issue", p);
      });
    }
  }

  get isProblemOnly(){
    return !this.team;
  }

  get isIssue(){
    return this.issues || this.mode == "issue";
  }

  get isAnswer(){
    console.log(this.isProblemOnly, this.isIssue);
    return (!this.isProblemOnly) && (!this.isIssue);
  }

  get isSingleIssue(){
    return !!this.issue;
  }
}
