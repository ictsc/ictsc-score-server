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
  }

  get(){
    return this.api.problems.get();
  }

  problem(section: any){
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
