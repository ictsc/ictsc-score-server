import { Injectable } from '@angular/core';
import { Http, Headers, Response } from '@angular/http';
import { Observable, Subscriber } from "rxjs";

@Injectable()
export class ApiService {
  constructor(public http: Http) {
  }

  private session = new RestResources("session", this.http, false);

  // todo ログインユーザが変わった時にmainの画面更新掛ける
  private changeUserObserver;
  public changeUser: Observable<any> = Observable.create((observer: Subscriber<any>) => {
    this.changeUserObserver = observer;
    // Observable.interval(1000).subscribe(r => observer.next())
  });
  private lastUser = null;
  private changeUserNext(user){
    let memberid = user && user.member_id;
    if(this.changeUserObserver && this.lastUser !== memberid){
      console.log("user changed");
      this.lastUser = memberid;
      if(memberid)
        this.members.item(memberid)
          .catch(r => Observable.of(undefined))
          .subscribe(r => this.changeUserObserver.next(r));
      else
        this.changeUserObserver.next(undefined);
    }
  }

  login(user: string, password: string){
    return this.session.post({
      login: user,
      password: password
    }).map(m => {
      if(m.status == "failed") throw "ログインが失敗しました";
      this.cachedLoginStatus = undefined;
      return m;
    });
  }
  logout(){
    console.log("logout!!!!!!!!!!");
    TempStorage.clear();
    return this.session.delete().map(r => {
      this.changeUserNext(undefined);
      return r;
    });
  }
  private cachedLoginStatus: LoginStatus;
  private lastCacheTime: Date = new Date(0);
  getLoginStatus(cache = false): Observable<LoginStatus> {
    if(cache && this.cachedLoginStatus && new Date().valueOf() - this.lastCacheTime.valueOf() < 30 * 1000)
      return Observable.of(this.cachedLoginStatus);
    else
      return this.session.get().map(r => {
        let status = new LoginStatus();
        status.member = r.member;
        status.status = r.status;
        this.cachedLoginStatus = status;
        this.changeUserNext(status);
        return status;
      }).catch(err => Observable.of(undefined));
  }
  getLoginMember(cache = true){
    return this.getLoginStatus(cache)
      .concatMap(r => {
        if(!r.isLogin) return Observable.throw("not logined");
        return this.members.item(r.member.id.toString(), cache);
      }).map(u => {
        return u;
      });
  }

  private isRole = (cache: boolean, role: Roles) => {
    return this.getLoginMember(cache).catch(r => Observable.of({} as any)).map(m => m.role_id == role)
  };

  isAdmin(cache = true){
    return this.getLoginMember(cache).map(m => m.role_id == Roles.Admin || m.role_id == Roles.Writer);
  }
  isParticipant(cache = true){
    return this.isRole(cache, Roles.Participant);
  }

  public scores = new RestResources("scores", this.http);
  public scoreboard = new RestResources("scoreboard", this.http);
  public answer = new RestResources("answers", this.http);
  public answerComments = (id: String) => new RestResources(`answers/${id}/comments`, this.http);
  public members = new RestResources("members", this.http);
  public teams = new RestResources("teams", this.http);
  public problems = new RestResources("problems", this.http);
  public problemGroups = new RestResources("problem_groups", this.http);
  public problemsComments = (id: String) => new RestResources(`problems/${id}/comments`, this.http);
  public issues = new RestResources("issues", this.http);
  public issueComments = (id: String) => new RestResources(`issues/${id}/comments`, this.http);
  public notifications = new RestResources("notifications", this.http);
  public notices = new RestResources("notices", this.http);
  public problemsAnswer = (problem: String) => new RestResources(`problems/${problem}/answers`, this.http);
  public answersComments = (id: String) => new RestResources(`answers/${id}/comments`, this.http);
  public answersScore = (id: String) => new RestResources(`answers/${id}/score`, this.http);

  private leftJoin = (left: Object[], leftKey, right: Object[], rightKey, keyName, multi = true) => {
    return left.map(l => {
      l = Object.assign({}, l);
      let funcName = multi?"filter":"find";
      l[keyName] = right[funcName](r => r[rightKey] == l[leftKey]);
      return l;
    });
  }

  public teamsDetail(){
    return Observable.combineLatest([
      this.teams.list(),
      this.problems.list(),
      this.answer.list(),
      this.scores.list(),
      this.members.list(),
    ]).map(res => {
      let [teams, problems, answers, scores, members] = res as any;

      let ans = this.leftJoin(answers, "id", scores, "answer_id", "score", false);
      let prb = this.leftJoin(ans, "problem_id", problems, "id", "problem", false);
      let tam = this.leftJoin(teams, "id", prb, "team_id", "answers");
      let mem = this.leftJoin(tam, "id", members, "team_id", "members");

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

  public problemAnswerDetail(){
    return Observable.combineLatest([
      this.teams.list(),
      this.problems.list(),
      this.answer.list(),
      this.scores.list(),
    ]).map(res => {
      let [teams, problems, answers, scores] = res as any;

      let ans = this.leftJoin(answers, "id", scores, "answer_id", "score", false);
      let tem = () => this.leftJoin(teams, "id", ans, "team_id", "answer");
      let prob = problems
        .map(p => {p.teams = tem(); return p;})
        .map(p => {
          p.teams = p.teams.map(t => {
            t.answer = t.answer && t.answer.find(a => a.problem_id == p.id)
            return t;
          });
          return p;
        });
      return prob;
    });
  }

  public issueDetail(cacheCount?: number, nonCacheCount = 5){
    return Observable.combineLatest(
      this.issues.list(),
      this.problems.list(),
      this.members.list(),
      this.teams.list()
    ).concatMap(r => {
      let [issues, problems, members, teams] = r as any;

      let allowCache = (id: number, closed) => {
        // return true;
        console.log("AllowCache", cacheCount, nonCacheCount, id, (cacheCount + id) % nonCacheCount == 0, closed);
        if(typeof cacheCount == 'undefined')
          return false;
        return ((cacheCount + id) % nonCacheCount * (close?2:1)) != 0;
      }

      issues.map(issue => {
        issue.comments.map(ic => {
          ic.member = members.find(m => m.id == ic.member_id);
          return ic;
        });
        issue.problem = problems.find(p => p.id == issue.problem_id);
        issue.team = teams.find(p => p.id == issue.team_id);
        return issue;
      })

      return [issues];
    });
  }
}


export class LoginStatus {
  status: string;
  member: any;
  get isLogin(){
    return this.status == "logged_in";
  }
}

export enum Roles {
    Admin = 2,
    Writer,
    Participant,
    Viewer,
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
  private httpPath(path: string, body: Object){
    return this.http.patch(
      this.url(path),
      JSON.stringify(body),
      this.httpOption
    ).map(this.responseFilter);
  }
  private httpGet(path: string, cacheResponse?: boolean, cacheOnly = false){
    if(typeof cacheResponse == "undefined") cacheResponse = this.cacheResponseDefault;
    let getReq = (cacheContent?) => this.http.get(
      this.url(path),
      this.httpOption
    ).map(this.responseFilter).concatMap(d=>{
      if(cacheContent && JSON.stringify(d) == JSON.stringify(cacheContent)){
        return Observable.never();
      }
      TempStorage.setIteam(path, d);
      return Observable.of(d);
    });
    let cache = TempStorage.getItem(path);

    if(!cacheResponse || !cache) return getReq();
    console.log("cache response", path, cache);
    if(cache && cacheOnly)
      return Observable.concat(Observable.of(cache));
    else
      return Observable.concat(Observable.of(cache), getReq(cache));
  }
  private httpDelete(path: string){
    return this.http.delete(
      this.url(path),
      this.httpOption
    );
  }

  list(cacheResponse?: boolean, cacheOnly = false){
    return this.get(cacheResponse, cacheOnly);
  }
  get(cacheResponse?: boolean, cacheOnly = false){
    return this.httpGet(`${this.resourcesName}`, cacheResponse, cacheOnly);
  }

  item(id: string, cacheResponse?: boolean, cacheOnly = false){
    return this.httpGet(`${this.resourcesName}/${id}`, cacheResponse, cacheOnly);
  }

  add(content: T1){  // todo: type
    return this.post(content);
  }
  post(content: T1){
    return this.httpPost(`${this.resourcesName}`, content);
  }

  put(id: string, content: T1){  // todo: type
    return this.httpPut(`${this.resourcesName}/${id}`, content);
  }
  modify(id: string, content: T1){  // todo: type
    return this.httpPath(`${this.resourcesName}/${id}`, content);
  }
  delete(){
    return this.httpDelete(`${this.resourcesName}`);
  }
  deleteItem(id: string){
    return this.httpDelete(`${this.resourcesName}/${id}`);
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
