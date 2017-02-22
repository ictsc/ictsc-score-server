import * as superagent from 'superagent';
import { Emit, AUTH_ERROR } from '../utils/EventBus'

async function RequestMiddleware (request, ignoreAuthError = false) {
  if (request.url[0] !== '/' || request.url.startsWith('http')) {
    request.url = '/api/' + request.url;
  }
  request.set('Content-Type', 'application/json');

  try {
    return await request;
  } catch (err) {
    if ((err.status === 401 || err.status === 403) && !ignoreAuthError) {
      Emit(AUTH_ERROR, err);
    }
    throw err;
  }
}

export class API {
  static login (login, password, req = superagent) {
    return RequestMiddleware(req
      .post('session')
      .send(JSON.stringify({
        login,
        password,
      })), true
    )
  }
  static logout (req = superagent) {
    return RequestMiddleware(req.del('session'))
  }
  static getSession (req = superagent) {
    return RequestMiddleware(req.get('session'))
      .then(res => res.body)
  }
  static getNotices (req = superagent) {
    return RequestMiddleware(req.get('notices'))
      .then(res => res.body)
  }
  static postNotices (title, text, pinned = false, req = superagent) {
    return RequestMiddleware(
      req.post('notices')
        .send(JSON.stringify({
          title,
          text,
          pinned,
          body: '',
        }))
    ).then(res => res.body)
  }
  static deleteNotices (id, req = superagent) {
    return RequestMiddleware(req.del(`notices/${id}`))
      .then(res => res.body)
  }
  static getNotifications (req = superagent) {
    return RequestMiddleware(req.get('notifications'))
      .then(res => res.body)
  }
  static getTeams (req = superagent) {
    return RequestMiddleware(req.get('teams'))
      .then(res => res.body)
  }
  static addTeams (name, organization, regCode, req = superagent) {
    return RequestMiddleware(
      req.post('teams')
        .send(JSON.stringify({
          name,
          organization,
          registration_code: regCode,
        }))
    ).then(res => res.body)
  }
  static getTeam (id, req = superagent) {
    return RequestMiddleware(req.get(`teams/${id}`))
      .then(res => res.body)
  }
  static getScoreboard (req = superagent) {
    return RequestMiddleware(req.get(`scoreboard`))
      .then(res => res.body)
  }

  static getProblemGroups (req = superagent) {
    return RequestMiddleware(req.get(`problem_groups`))
      .then(res => res.body)
  }
  static getProblem (id, req = superagent) {
    return RequestMiddleware(req.get(`problems/${id}`))
      .then(res => res.body)
  }
  static getIssues (req = superagent) {
    return RequestMiddleware(req.get(`issues`))
      .then(res => res.body)
  }
  static addIssueComment (issueId, text, req = superagent) {
    return RequestMiddleware(
      req.post(`issues/${issueId}/comments`)
        .send(JSON.stringify({
          text,
        }))
    ).then(res => res.body)
  }

}
