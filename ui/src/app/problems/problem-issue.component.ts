import { Router, ActivatedRoute } from '@angular/router';
import { Component, SimpleChanges, Input, Output, EventEmitter } from '@angular/core';
import { ApiService, MiniList, Markdown, Time, Editable, SimpleMDE } from "../common";
import { Observable } from "rxjs";


@Component({
  selector: "problem-issue",
  template: require('./problem-issue.template.jade'),
  // template: "hello!hello!hello!hello!hello!",
  directives: [Markdown, Editable, SimpleMDE]
})
export class ProblemIssue {
  constructor(private api: ApiService, private route: Router, private activatedRoute: ActivatedRoute) {}

  // todo tow way bindingにしたい
  @Input('issue') issue: any;
  @Input('isadmin') isAdmin: any;
	@Output('issueChange') emitter = new EventEmitter();

  ngOnInit() {
  }

  comment = "";

  ngOnChanges(changes: SimpleChanges){
  }

  postComment(){
    this.api.issueComments(this.issue.id).post({
      text: this.comment
    }).subscribe(res => {
      this.comment = "";
      this.issue.comments.push(res);
      this.emitter.emit(this.issue);
    }, err => {
      // todo
    });
  }

  delete(){
    if(window.confirm("本当に質問を削除しますか？")){
      this.api.issues.deleteItem(this.issue.id)
        .subscribe(res => this.emitter.emit({}));
    }
  }

  deleteComment(commentId){
    if(window.confirm("本当にコメントを削除しますか？")){
      this.api.issueComments(this.issue.id).deleteItem(commentId)
        .subscribe(res => this.emitter.emit({}));
    }
  }
}
