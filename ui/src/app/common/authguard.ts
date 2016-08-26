import { Injectable } from '@angular/core';
import { Router, CanActivate } from '@angular/router';
import { ApiService } from "./api.service";

@Injectable()
export class AuthGuard implements CanActivate {
  constructor(private router: Router, private api: ApiService) {}

  canActivate() {
    return this.api.getLoginStatus(true).map(r => {
      if(!r.isLogin)
        this.router.navigate(['/login']);
      return r.isLogin;
    });
  }
}
