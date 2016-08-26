import { Observable } from 'rxjs';
import { MiniList, ApiService, Markdown } from '../common';
import { Component } from '@angular/core';

import { AppState } from '../main/main.service';

@Component({
  selector: Caution.name.toLowerCase(),
  template: `<markdown [body]="body"></markdown>`,
  directives: [ Markdown ],
})
export class Caution {
  body;
  constructor(private api: ApiService) {}
  ngOnInit() {
    this.api.http.get("/assets/caution.md").subscribe(r => this.body = r.text());
  }

}
