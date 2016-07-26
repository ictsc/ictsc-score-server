import { Component } from '@angular/core';
import { ActivatedRoute } from '@angular/router';

@Component({
  selector: 'login',
  template: require('./login.template.jade')
})
export class Login {
  localState;
  constructor(public route: ActivatedRoute) {

  }

  ngOnInit() {
  }

}
