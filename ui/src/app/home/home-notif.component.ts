import { Observable } from 'rxjs';
import { ApiService, Markdown, SimpleMDE, Editable } from '../common';
import { Component, Input, Output, EventEmitter } from '@angular/core';

import { AppState } from '../main/main.service';

@Component({
  selector: HomeNotif.name.toLowerCase(),
  template: require('./home-notif.template.jade'),
  directives: [ Markdown ,SimpleMDE, Editable ]
})
export class HomeNotif {
  constructor(private api: ApiService) {
  }

  @Input("model") notic: any;
  @Input() isAdmin: boolean = false;
  @Output("modelChange") emitter = new EventEmitter();

  edit = false;
  
  ngOnInit() {
  }

  change(){
    this.emitter.next(undefined);
  }
  update(){
    this.api.notices.modify(this.notic.id, this.notic)
      .subscribe(r => {
        this.edit = false;
        this.change();
      })
  }
  delete(){
    if(window.confirm("本当に削除しますか？"))
      this.api.notices.deleteItem(this.notic.id)
        .subscribe(r =>  this.change());
  }
}
