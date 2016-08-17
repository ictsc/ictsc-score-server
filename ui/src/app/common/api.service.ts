import { Injectable } from '@angular/core';
import { Http, Headers, Response } from '@angular/http';
import { Observable } from "rxjs";

@Injectable()
export class ApiService {
  constructor(private http: Http) {
  }

  private session = new RestResources("session", this.http, false);

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
  public issues = new RestResources("issues", this.http);


  public teamsDetail(){
    return Observable.combineLatest([
      this.teams.list(),
      this.problems.list(),
      this.answer.list(),
      this.scores.list(),
      this.members.list(),
    ]).map(res => {
      let [teams, problems, answers, scores, members] = res as any;
      let leftJoin = (left: Object[], leftKey, right: Object[], rightKey, keyName, multi = true) => {
        return left.map(l => {
          l = Object.assign(l, {});
          let funcName = multi?"filter":"find";
          l[keyName] = right[funcName](r => r[rightKey] == l[leftKey])
          return l;
        });
      }
      let ans = leftJoin(answers, "id", scores, "answer_id", "score", false);
      let prb = leftJoin(ans, "problem_id", problems, "id", "problem", false);
      let tam = leftJoin(teams, "id", prb, "team_id", "answers");
      let mem = leftJoin(tam, "id", members, "team_id", "members");

      let final = mem.map(m => {
        let sum = 0;
        for(let ans of (m as any).answers){
          if(ans.score && ans.score.point) sum += ans.score.point;
        }
        (m as any).sum = sum;
        return m;
      });

      return final;
    });
  }
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
    private http: Http,
    public cacheResponseDefault = true
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
  private httpGet(path: string, cacheResponse?: boolean){
    if(typeof cacheResponse == "undefined") cacheResponse = this.cacheResponseDefault;
    let getReq =  this.http.get(
      this.url(path),
      this.httpOption
    ).map(this.responseFilter).map(d=>{
      TempStorage.setIteam(path, d);
      return d;
    });
    let cache = TempStorage.getItem(path);

    if(!cacheResponse || !cache) return getReq;
    console.log("cache response", path, cache);
    return Observable.concat(Observable.of(TempStorage.getItem(path)), getReq);
  }
  private httpDelete(path: string){
    return this.http.delete(
      this.url(path),
      this.httpOption
    ).map(this.responseFilter);
  }

  list(cacheResponse?: boolean){
    return this.get(cacheResponse);
  }
  get(cacheResponse?: boolean){
    return this.httpGet(`${this.resourcesName}`, cacheResponse);
  }

  item(id: string, cacheResponse?: boolean){
    return this.httpGet(`${this.resourcesName}/${id}`, cacheResponse);
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


interface TempStorageDataSet {
  timestamp: number;
  data: any;
}
export class TempStorage {
  static expire = 1000 * 60 * 5; // 5m
  static storage: Storage = sessionStorage;

  static stringfy(data: any){
    return JSON.stringify(<TempStorageDataSet>{
      timestamp: new Date().valueOf(),
      data,
    });
  }
  static parse<T>(data: string, defaultValue: T): T{
    let obj = JSON.parse(data) as TempStorageDataSet;
    if(obj && obj.timestamp + this.expire > new Date().valueOf()) return obj.data;
    return defaultValue;
  }
  static setIteam(id, data: any){
    this.storage.setItem(id, this.stringfy(data));
  }
  static getItem<T>(id, defaultValue: T = undefined){
    return this.parse(this.storage.getItem(id), defaultValue);
  }
  static clear(){
    return
  }
}
