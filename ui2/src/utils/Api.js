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
  // session
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
    return RequestMiddleware(req.get('session?with=member-team'))
      .then(res => res.body)
  }
  static getNotices (req = superagent) {
    return RequestMiddleware(req.get('notices'))
      .then(res => res.body)
  }

  // notices
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

  // members
  static getMembers (req = superagent) {
    return RequestMiddleware(req.get('members'))
      .then(res => res.body)
  }
  static postMembers (login, name, password, registration_code, req = superagent) {
    return RequestMiddleware(
      req.post('members')
        .send(JSON.stringify({ login, name, password, registration_code }))
    ).then(res => res.body)
  }

  // teams
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
    return RequestMiddleware(req.get(`teams/${id}?with=members,answers-score`))
      .then(res => res.body)
  }

  // scoreboard
  static getScoreboard (req = superagent) {
    return RequestMiddleware(req.get(`scoreboard`))
      .then(res => res.body)
  }

  // problems
  static getProblemGroups (req = superagent) {
    return RequestMiddleware(req.get(`problem_groups`))
      .then(res => res.body)
  }
  static getProblemsWithScore (req = superagent) {
    return RequestMiddleware(req.get(`problems?with=answers-score`))
      .then(res => res.body)
  }
  static getProblems (req = superagent) {
    return RequestMiddleware(req.get(`problems`))
      .then(res => res.body)
  }
  static getProblem (id, req = superagent) {
    return RequestMiddleware(req.get(`problems/${id}?with=comments`))
      .then(res => res.body)
  }

  // issues
  static getIssues (req = superagent) {
    return RequestMiddleware(req.get(`issues?with=comments-member-team,team,problem`))
      .then(res => res.body)
  }
  static addIssues (problem_id, title, req = superagent) {
    return RequestMiddleware(
      req.post(`issues`)
        .send(JSON.stringify({ problem_id, title }))
    ).then(res => res.body)
  }
  static addIssueComment (issueId, text, req = superagent) {
    return RequestMiddleware(
      req.post(`issues/${issueId}/comments`)
        .send(JSON.stringify({ text }))
    ).then(res => res.body)
  }

  // answers
  static getAnswers (req = superagent) {
    return RequestMiddleware(req.get(`answers?with=comments`))
      .then(res => res.body)
  }
  static postAnswers (team, problem, req = superagent) {
    return RequestMiddleware(
      req.post(`answers`)
        .send(JSON.stringify({
          problem_id: +problem,
          team_id: +team,
        }))
    ).then(res => res.body)
  }
  static addAnswerComment (answerId, text, req = superagent) {
    return RequestMiddleware(
      req.post(`answers/${answerId}/comments`)
        .send(JSON.stringify({ text }))
    ).then(res => res.body)
  }
  static patchAnswers (id, obj, req = superagent) {
    return RequestMiddleware(req.patch(`answers/${id}`).send(JSON.stringify(obj)))
      .then(res => res.body)
  }

  // scores
  static getScores (req = superagent) {
    return RequestMiddleware(req.get(`scores`))
      .then(res => res.body)
  }
  static getScore (id, req = superagent) {
    return RequestMiddleware(req.get(`scores/${id}`))
      .then(res => res.body)
  }
  static postScore (answer_id, point, req = superagent) {
    return RequestMiddleware(
      req.post(`scores`)
        .send(JSON.stringify({
          answer_id,
          point,
        }))
    ).then(res => res.body)
  }
  static putScore (id, obj, req = superagent) {
    return RequestMiddleware(req.put(`scores/${id}`).send(JSON.stringify(obj)))
      .then(res => res.body)
  }
}
