import { Component } from '@angular/core';
import { ApiService, MiniList } from "../common";
import { Time } from "../common";

@Component({
  template: require('./issue.template.jade'),
})
export class Issue extends MiniList {
  constructor(private api: ApiService) {super()}

  ngOnInit() {
    this.fetch();
  }

  get(){
    return this.api.issues.get();
  }

  dateFormat(input: any){ return Time.dateFormat(input); }
}
