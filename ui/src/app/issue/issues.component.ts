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
    this.fetch();;
  }

  get(){
    // return this.api.issues.get();
    return this.api.issueDetail().do(r => console.warn(r));
  }

  dateFormat(input: any){ return Time.dateFormat(input); }

  get filterd_list(){
    // tood list
    return this.list;
  }

  issueStatus(issue){
    if(issue.closed) return 0;  // 解決済み
    let req = this.getLastRequest(issue);
    let res = this.getLastResponse(issue);
    if((req?req.id:0) > (res?res.id:0))
      return 1;  // 未回答
    return 2;  // 対応中
  }

  private getSorted(issue){
    return issue.comments.sort((a,b) => b.id - a.id)
  }
  getLastRequest(issue){
    return this.getSorted(issue).filter(i => i.member.role_id == 4)[0];
  }
  getLastResponse(issue){
    return this.getSorted(issue).filter(i => i.member.role_id == 2 || i.member.role_id == 3)[0];
  }
}
