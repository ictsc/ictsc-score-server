import { Component, SimpleChanges, Input } from '@angular/core';
import { ApiService, MiniList, Markdown, SimpleMDE, Time, Editable, Roles } from "../common";
import { Observable } from "rxjs";
import { ProblemIssue } from "./problem-issue.component";

/**
 * <problem id="1" [team=""] [issue=""] [show="issue|answer|all"] [mode="issue|answer"]>
 */
console.warn("ProblemIssue", ProblemIssue);

@Component({
  selector: Problem.name.toLowerCase(),
  template: require('./problem.template.jade'),
  directives: [Markdown, Editable, ProblemIssue, SimpleMDE]
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
  problemComment: any;

  private role: number;
  get isParticipant(){ return this.role == Roles.Participant }
  get isAdmin(){ return this.role == Roles.Admin || this.role == Roles.Writer }

  postTitle = "";
  postText = "";

  problemEdit = false;
  problemEditCancel(){
    this.problemEdit = false;
    this.ngOnChanges({id: {}} as any);
  }
  problemEditPost(){
    this.api.problems.modify(this.id, {
      text: this.problemData.text,
      title: this.problemData.title,
      closed_at: this.problemData.closed_at,
      opened_at: this.problemData.opened_at
    }).subscribe(res => {
        this.problemEditCancel();
      }, err => {
        // todo
      });
  }

  ngOnInit() {
    this.api.getLoginMember().subscribe(mem => this.role = mem.role_id);
  }

  ngOnChanges(changes: SimpleChanges){
    if("id" in changes){
      this.api.problems.item(this.id).subscribe(p => this.problemData = p);
      this.api.problemsComments(this.id).list().subscribe(c => this.problemComment = c);
    }

    if("issue" in changes){
      let src = this.isSingleIssue?
        this.api.issues.item(this.issue).map(a => [a])
        :this.api.issues.list();

      Observable.combineLatest(
        src,
        this.api.members.list(),
        this.api.teams.list()
      ).subscribe(p => {
        let [issues, members, temas] = p as any;
        for(let a of issues){
          this.api.issueComments(a.id).list()
            .subscribe(ics => {
              a.comments = ics.map(ic => {
                ic.member = members.find(m => m.id == ic.member_id);
                ic.member.team = temas.find(t => t.id == ic.member.team_id);
                return ic;
              });
            });
        }
        this.issues = issues;
        console.log("Done fetch issue", issues);
      });
    }
  }

  postIssue(){
    this.api.issues
      .add({title: this.postTitle, problem_id: this.id})
      .concatMap(res => {
        console.log("post issue done");
        return this.api.issueComments(res.id).add({text: this.postText});
      })
      .subscribe(res => {
        this.ngOnChanges({issue: {}} as any);
        this.postText = "";
        this.postTitle = "";
      }, err => {
        // todo
      });
  }

  get isProblemOnly(){
    return !this.team;
  }

  get isIssue(){
    return this.issues || this.mode == "issue";
  }

  get isAnswer(){
    return (!this.isProblemOnly) && (!this.isIssue);
  }

  get isSingleIssue(){
    return !!this.issue;
  }
}
