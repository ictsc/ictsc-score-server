import { Observable } from 'rxjs';
import { MiniList, ApiService } from '../common';
import { Component, SimpleChanges } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { AppState } from '../main/main.service';

@Component({
  selector: Member.name.toLowerCase(),
  template: require('./member.template.jade')
})
export class Member extends MiniList {
  constructor(private api: ApiService, private route: ActivatedRoute) {
    super();
    this.list = [[],[],[]];
  }

  ngOnInit() {
  }

  ngOnChanges(changes: SimpleChanges){
    this.route.params.subscribe(param => {
      this.id = param["id"];
      this.fetch()
    });
  }
  id: any;
  get(){
    return this.api.members.item(this.id);
  }
}
