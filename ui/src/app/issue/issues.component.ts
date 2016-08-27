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
    return this.api.issueDetail().do(r => console.warn(r)).map(i => i.sort((a,b) => a.id < b.id));
  }

  dateFormat(input: any){ return Time.dateFormat(input); }

  get filterd_list(){
    return this.list.filter(r => 
      this.filter.all || 
      (this.filter.noRes && this.issueStatus(r) == 1) ||
      (this.filter.progress && this.issueStatus(r) == 2) ||
      (this.filter.success && this.issueStatus(r) == 0)
    );
  }

  issueStatus(issue){
    if(issue.closed) return 0;  // 解決済み
    let req = this.getLastRequest(issue);
    let res = this.getLastResponse(issue);
    if((req?req.id:0) > (res?res.id:0))
      return 1;  // 未回答
    return 2;  // 対応中
  }

  getLastRequest(issue){
    let res = issue.comments.filter(i => i.member.role_id == 4);
    return res[res.length - 1];
  }
  getLastResponse(issue){
    let res = issue.comments.filter(i => i.member.role_id == 2 || i.member.role_id == 3)
    return res[res.length - 1];
  }

  filter = {
    all: true,  // 1
    noRes: false,  // 2
    progress: false,  // 3
    success: false,  // 4
  }

  setFilter(pos){
    this.filter.all = false;
    switch(pos){
      case 1:
        this.filter.all = true;
        this.filter.noRes = false;
        this.filter.progress = false;
        this.filter.success = false;
        break;
      case 2:
        this.filter.noRes = !this.filter.noRes;
        break;
      case 3:
        this.filter.progress = !this.filter.progress;
        break;
      case 4:
        this.filter.success = !this.filter.success;
        break;
    }
    if((!this.filter.noRes) && (!this.filter.progress) && (!this.filter.success))
      this.filter.all = true;
  }
}
