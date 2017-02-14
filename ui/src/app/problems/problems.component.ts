import { Component } from '@angular/core';
import { ApiService, MiniList } from "../common";
import { Time } from "../common";
import { Observable } from "rxjs";

@Component({
  selector: Problems.name,
  template: require('./problems.template.jade'),
})
export class Problems extends MiniList {
  constructor(private api: ApiService) {super()}

  ngOnInit() {
    this.fetch();
    this.api.isAdmin().subscribe(r => this.isAdmin = r);
  }

  isAdmin = false;

  get(){
    return Observable.combineLatest(
      this.api.problems.get(),
      this.api.problemGroups.get()
    ).map(p => {
      let [problems, problem_groups] = p as any;
      problem_groups.forEach(pg => pg.problems = []);

      let push = (group_id, problem) => {
        const pg = problem_groups.find(pg => pg.id == group_id);
        if(pg)
          pg.problems.push(problem);
      }

      for(let problem of problems){
        push(problem.problem_group_id, problem);
      }
      return problem_groups;
    });
  }

  compTime(compareDate, mode){
    let now = new Date().valueOf();
    let date = new Date(compareDate).valueOf()

    switch(mode){
      case 1:  // close
        return date < now + 10 * 60 * 1000 && date > now;  // 10分
      case 2:  // publish
        return date > now - 10 * 60 * 1000;  // 10分
      case 3:  // closed
        return date < now;
    }
  }

  get problems(){
    return this.list;
  }

  postErr = "";
  initObj = {
    title: "",
    text: "",
    opened_at: new Date().toISOString().substr(0,13) + ":00",
    closed_at: new Date().toISOString().substr(0,13) + ":00",
  }
  postObj = Object.assign({}, this.initObj);
  post(){
    this.postErr ="";
    this.api.problems.add(this.postObj)
      .subscribe(r => {
        Object.assign({}, this.initObj);
        this.fetch();
      }, err => {
        this.postErr = "投稿エラー" + err;
        this.fetch();
      })
  }
}
