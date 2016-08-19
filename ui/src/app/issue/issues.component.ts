import { Component } from '@angular/core';
import { ApiService, MiniList } from "../common";
import { Time } from "../common";

@Component({
  selector: Issues.name.toLowerCase(),
  template: require('./issues.template.jade'),
})
export class Issues extends MiniList {
  constructor(private api: ApiService) {super()}

  ngOnInit() {
    this.fetch();
  }

  get(){
    return this.api.issues.get();
  }

  dateFormat(input: any){ return Time.dateFormat(input); }

  get filterd_list(){
    // tood list
    return this.list;
  }
}
