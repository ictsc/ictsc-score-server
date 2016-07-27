import { Component } from '@angular/core';
import { Router } from '@angular/router';
import { ApiService } from '../common/api.service'
import { Observable } from "rxjs";

export class Miniform {
  constructor() {}
  public form: any;
  public disabled = false;
  public errorMessage: string;

  ngOnInit() {
  }

  success(response: any){
    console.log("OK");
  }
  error(response: any): string {
    console.log("NG");
    return "通信が失敗しました";
  }
  post(): Observable<any> {
    return Observable.from(null);
  }

  submit(){
    console.log(this.form);
    this.disabled = true;
    this.errorMessage = undefined;
    this.post().subscribe(res => {
      this.success(res);
    }, err => {
      this.disabled = false;
      this.errorMessage = this.error(err);
    });
  }
}
