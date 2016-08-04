import { Component } from '@angular/core';
import { ApiService } from "../common/api.service";
import { Signup } from "../login/signup.component";

@Component({
  styles: [ require('./teams.style.scss') ],
  template: require('./teams.template.jade'),
})
export class Teams {
  constructor(private api: ApiService) {}

  private list: Object[] = [];
  ngOnInit() {
    console.log("list", this.list);

    this.api.teams.get().subscribe(r => {
      console.log(r);

      this.list = r}
      );
  }
}
