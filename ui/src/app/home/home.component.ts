import { Observable } from 'rxjs';
import { MiniList, ApiService } from '../common';
import { Component } from '@angular/core';

import { AppState } from '../main/main.service';

@Component({
  selector: 'home',
  styleUrls: [ './home.style.scss' ],
  template: require('./home.template.jade')
})
export class Home extends MiniList {
  localState = { value: '' };
  constructor(private api: ApiService) {
    super();
    this.list = [[],[],[]];
  }

  ngOnInit() {
    console.log('hello `Home` component');
    this.fetch();
  }

  get(){
    return Observable.combineLatest(
      Observable.of([]),
      this.api.problems.get(),
      this.api.issues.get()
    );
  }

  get problems(){
    return this.list[1]
      .filter(p => new Date(p.closed_at).valueOf() > new Date().valueOf()) // 未終了の問題
      .sort((a, b) => new Date(a.opend_at).valueOf() - new Date(b.opend_at).valueOf())
      .map(p => {
        p.isNew = new Date(p.opend_at).valueOf() > new Date().valueOf() - (1000 * 60 * 5);
        return p;
      });
  }
}
