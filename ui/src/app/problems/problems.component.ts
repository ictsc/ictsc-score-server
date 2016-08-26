import { Component } from '@angular/core';
import { ApiService, MiniList } from "../common";
import { Time } from "../common";

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
    return this.api.problems.get().map(problems => {
      let res = [
        {title: "2日目 - 午後問題", items: []},
        {title: "2日目 - 午前問題", items: []},
        {title: "1日目 - 午後問題", items: []},
        {title: "1日目 - 午前問題", items: []},
      ];
      let push = (pos, problem) => {
        if(!res[pos].items.find(p => p.id == problem.id))
          res[pos].items.push(problem);
      }
      for(let problem of problems){
        let opened = new Date(problem.opened_at);
        let closed = new Date(problem.closed_at);
        for(let date of [opened, closed]){
          if(date.valueOf() < new Date("2016-08-27 12:30").valueOf())
            push(3, problem);
          else if(date.valueOf() < new Date("2016-08-27 23:59:59").valueOf())
            push(2, problem);
          else if(date.valueOf() < new Date("2016-08-28 12:30").valueOf())
            push(1, problem);
          else
            push(0, problem);
        }
      }
      return res;
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
