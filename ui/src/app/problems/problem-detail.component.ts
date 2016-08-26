import { ActivatedRoute, Router } from '@angular/router';
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
  constructor(private api: ApiService, private route: Router, private activatedRoute: ActivatedRoute) {}
  id: string;
  test: string;

  ngOnInit() {
    this.activatedRoute.params.subscribe(parms => {
      this.id = parms["id"];
    });
    this.api.getLoginMember()
      .subscribe(mem => {
        if(mem.team_id)
          this.route.navigate(['/issues', this.id, mem.team_id]);
      })
  }

}
