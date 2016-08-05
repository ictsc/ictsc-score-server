import { Component } from '@angular/core';
import { Router } from '@angular/router';
import { ApiService } from '../common/api.service'
import { Observable } from "rxjs";

export class MiniList {
  constructor() {}
  public errorMessage: string;
  public list: any[] = [];
  public isLoading: boolean;

  fetch() {
    this.get()
      .retry(2)
      .subscribe(d => {
        this.isLoading = false;
        this.list = d;
        this.success(d);
      }, e => {
        this.isLoading = false;
        this.error(e)
      });
  }

  success(response: any){
    console.log("OK");
  }
  error(response: any) {
    console.log("NG");
    this.errorMessage = "通信が失敗しました";
  }
  get(): Observable<any> {
    return Observable.from([]);
  }
}
