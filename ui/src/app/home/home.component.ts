import { Observable } from 'rxjs';
import { MiniList, ApiService } from '../common';
import { Component } from '@angular/core';

import { AppState } from '../main/main.service';

@Component({
  selector: Home.name.toLowerCase(),
  styleUrls: [ './home.style.scss' ],
  template: require('./home.template.jade')
})
export class Home extends MiniList {
  constructor(private api: ApiService) {
    super();
    this.list = [[],[],[]];
  }

  ngOnInit() {
    this.fetch();
  }

  get(){
    return Observable.combineLatest(
      this.api.problems.list(),
      this.api.notifications.list(),
      this.api.issues.list()
    );
  }

  get problems(){
    return this.list[0]
      .filter(p => new Date(p.closed_at).valueOf() > new Date().valueOf()) // 未終了の問題
      .sort((a, b) => new Date(a.opend_at).valueOf() - new Date(b.opend_at).valueOf())
      .map(p => {
        p.isNew = new Date(p.opend_at).valueOf() > new Date().valueOf() - (1000 * 60 * 5);
        return p;
      });
  }
  get notifications(){
    // ToDo: 問題のタイトル表示
    return this.list[1]
      .map(n => {
        let notif = Object.assign({}, n);
        switch(notif.type){
          case "problem_opened":
          case "problem_updated":
            notif.link = ["problems", notif.resource_id];
            break;
          case "new_comment_to_problem":
          case "updated_comment_to_problem":
            notif.link = ["problems", notif.resource_id];
            break;
          case "created_comment_to_issue":
          case "updated_comment_to_issue":
            let issue = this.list[2].find(i => i.id == notif.sub_resource_id);
            if(issue)
              notif.link = ["issues", issue.problem_id, issue.team_id, issue.id];
            else
              notif.link = [];
            break;
        }
        return notif;
      });
  }

}
