import { Component, SimpleChanges, Input } from '@angular/core';
import { ApiService, MiniList, Markdown, SimpleMDE, Time, Editable, Roles } from "../common";
import { Observable } from "rxjs";
import { ProblemIssue } from "./problem-issue.component";

/**
 * <problem id="1" [team=""] [issue=""] [show="issue|answer|all"] [mode="issue|answer"]>
 */

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
  answer: any;
  members = [];
  teamData: any;

  private role: number;
  get isParticipant(){ return this.role == Roles.Participant }
  get isAdmin(){ return this.role == Roles.Admin || this.role == Roles.Writer }

  postTitle = "";
  postText = "";

  viewExpand = 0; // -1:problem  0:normal  1:issue/answer

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

  score: number;
  scoreEdit = false;
  scoreEditCancel(){
    this.ngOnChanges({team: {}} as any);
    this.scoreEdit = false;
  }

  ngOnInit() {
    this.api.getLoginMember().subscribe(mem => this.role = mem.role_id);
  }

  ngOnChanges(changes: SimpleChanges){
    let changeId = "id" in changes;
    let changeIssue = "issue" in changes;
    let changeTeam = "team" in changes;

    if(changeId){
      this.api.problems.item(this.id).subscribe(p => this.problemData = p);
      this.api.problemsComments(this.id).list().subscribe(c => this.problemComment = c);
    }

    if(changeTeam){
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

    if((changeTeam || changeId) && this.team){
      this.getCurrentProblemsAnswer().concatMap(ans => {
          if(!ans) return Observable.of(undefined);
          return this.api.answerComments(ans.id).list().map(ac => {ans.comments = ac; return ans});
        })
        .subscribe(r => this.answer = r);
      this.api.members.list().subscribe(m => this.members = m);
      this.api.teams.item(this.team).subscribe(t => this.teamData = t);
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

  postAnswerText = "";
  answerPostError = "";
  postAnswer(){
    console.log("post answer");
    this.answerPostError = "";
    this.api.problemsAnswer(this.id).add({})
      .catch(err => Observable.of([]))
      .concatMap(_ => this.getCurrentProblemsAnswer())
      .concatMap(ans => this.api.answersComments(ans.id).add({
        text: this.postAnswerText,
      }))
      .subscribe(r => {
        this.postAnswerText = "";
        this.ngOnChanges({team:{}} as any);
        console.log("post answer!!", r);
      }, err => {
        console.warn(err);
        this.answerPostError = "送信エラーが発生しました。";
      });
  }

  getCurrentProblemsAnswer(): Observable<any>{
    return this.api.problemsAnswer(this.id).get()
      .catch(err => {
        console.warn(err);
        if(err.status == 404) return Observable.of([]);
        throw err;
      })
      .map(m => m.find(m => m.team_id == this.team && m.problem_id == this.id));
  }

  get isProblemOnly(){
    return !this.team;
  }

  get isIssue(){
    return this.issue || this.mode == "issue";
  }

  get isAnswer(){
    return (!this.isProblemOnly) && (!this.isIssue);
  }

  get isSingleIssue(){
    return !!this.issue;
  }

  getMember(id){
    return this.members.find(m => m.id == id)
  }
}
