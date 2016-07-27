import { Injectable } from '@angular/core';
import { Http, Headers, Response } from '@angular/http';
import { Observable } from "rxjs";

@Injectable()
export class ApiService {
  constructor(private http: Http) {
  }

  private session = new RestResources("session", this.http);

  login(user: string, password: string){
    return this.session.post({
      login: user,
      password: password
    });
  }
  private cachedLoginStatus: LoginStatus;
  private lastCacheTime: Date = new Date(0);
  getLoginStatus(cache = false): Observable<LoginStatus> {
    if(cache && new Date().valueOf() - this.lastCacheTime.valueOf() < 60 * 1000)
      return Observable.of(this.cachedLoginStatus);
    else
      return this.session.get().map(r => {
        let status = new LoginStatus();
        status.member_id = r.member_id;
        status.status = r.status;
        this.cachedLoginStatus = status;
        return status;
      });
  }

  public scores = new RestResources("scores", this.http);
  public answer = new RestResources("answers", this.http);
  public members = new RestResources("members", this.http);
  public teams = new RestResources("teams", this.http);
  public problems = new RestResources("problems", this.http);
}


export class LoginStatus {
  status: string;
  member_id: number;
  get isLogin(){
    return this.status == "logged_in";
  }
}


// enum RestPermission {
//   getList,
//   post,
//   getItem,
//   addItem,
//   modifyItem,
//   deleteItem,
// }

class RestResources<T1> {
  constructor(
    private resourcesName: string,
    private http: Http
    // private permission: Array<RestPermission> = []
  ){}

  get httpOption(){
    var headers = new Headers();
    headers.append('Content-Type', 'application/json');
    return { headers };
  }
  url(path: string){
    return `/api/${path}`;
  }
  responseFilter(response: Response){
    return response.json();
  }

  private httpPost(path: string, body: Object){
    return this.http.post(
      this.url(path),
      JSON.stringify(body),
      this.httpOption
    ).map(this.responseFilter);
  }
  private httpPut(path: string, body: Object){
    return this.http.put(
      this.url(path),
      JSON.stringify(body),
      this.httpOption
    ).map(this.responseFilter);
  }
  private httpGet(path: string){
    return this.http.get(
      this.url(path),
      this.httpOption
    ).map(this.responseFilter);
  }
  private httpDelete(path: string){
    return this.http.delete(
      this.url(path),
      this.httpOption
    ).map(this.responseFilter);
  }

  list(){
    return this.get();
  }
  get(){
    return this.httpGet(`${this.resourcesName}`);
  }

  item(id: string){
    return this.httpGet(`${this.resourcesName}/${id}`);
  }

  add(content: T1){  // todo: type
    return this.post(content);
  }
  post(content: T1){
    return this.httpPost(`${this.resourcesName}`, content);
  }

  modify(id: string, content: T1){  // todo: type
    return this.httpPut(`${this.resourcesName}/${id}`, content);
  }

}
