import { ActivatedRoute } from '@angular/router';
import { Component, SimpleChanges, Input } from '@angular/core';
import { ApiService, MiniList } from "../common";
import { Time } from "../common";
import { Problem } from "./";

@Component({
  selector: ProblemsDetail.name.toLowerCase(),
  directives: [ Problem ],
  template: `<problem [id]="id"></problem>`
})
export class ProblemsDetail {
  constructor(private api: ApiService, private route: ActivatedRoute) {}
  id: string;
  test: string;

  ngOnInit() {
    this.route.params.subscribe(parms => {
      this.id = parms["id"];
    });
  }

}
