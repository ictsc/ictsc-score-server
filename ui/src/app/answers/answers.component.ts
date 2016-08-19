import { Component } from '@angular/core';
import { ApiService, MiniList } from "../common";
import { Signup } from "../login/signup.component";

@Component({
  selector: Answers.name.toLowerCase(),
  template: require('./answers.template.jade'),
})
export class Answers extends MiniList {
  constructor(private api: ApiService) {super()}

  ngOnInit() {
    this.fetch();
  }

  get(){
    return this.api.problemAnswerDetail().map(a => {
      console.log(a);
      return a;
    });
  }

  state(team: any){
    if(!team.answer) return 0;
    else if(!team.answer.score) return 1;
    else return 2;
  }
}
