import { Component } from '@angular/core';

import { AppState } from '../main/main.service';

@Component({
  selector: 'home',
  styleUrls: [ './home.style.scss' ],
  template: require('./home.template.jade')
})
export class Home {
  // Set our default values
  localState = { value: '' };
  // TypeScript public modifiers
  constructor(public appState: AppState) {

  }

  ngOnInit() {
    console.log('hello `Home` component');
    // this.title.getData().subscribe(data => this.data = data);
  }

  submitState(value) {
    console.log('submitState', value);
    this.appState.set('value', value);
    this.localState.value = '';
  }

}
