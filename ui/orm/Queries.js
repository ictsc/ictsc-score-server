import orm from '~/orm'

// TODO: body, comments, teamは常時ロード対象にして省略したい
export default class Queries {
  static category(id) {
    return orm.Category.eagerFetch(id, [])
  }

  static categories() {
    return orm.Category.eagerFetch({}, [])
  }

  static categoriesProblems() {
    return orm.Category.eagerFetch({}, ['problems', 'problems.body'])
  }

  static configs() {
    return orm.Config.eagerFetch({}, [])
  }

  static noticesTeam() {
    return orm.Notice.eagerFetch({}, ['targetTeam'])
  }

  static problemAnswersTeam(id) {
    return orm.Problem.eagerFetch(id, ['body', 'answers', 'answers.team'])
  }

  static problemCategory(id) {
    // previousProblemもでは?
    return orm.Problem.eagerFetch(id, ['body', 'category'])
  }

  static problemProblemEnvironments(id) {
    return orm.Problem.eagerFetch(id, ['environments'])
  }

  static problemEnvironment(id) {
    return orm.ProblemEnvironment.eagerFetch(id, [])
  }

  static problemEnvironments() {
    return orm.ProblemEnvironment.eagerFetch({}, [])
  }

  static problemPenaltiesTeam(id) {
    return orm.Problem.eagerFetch(id, ['body', 'penalties', 'penalties.team'])
  }

  static problemIssuesTeam(id) {
    return orm.Problem.eagerFetch(id, ['body', 'issues', 'issues.team'])
  }

  static problemMisc(id) {
    return orm.Problem.eagerFetch(id, [
      'body',
      'environments',
      'supplements',
      'answers',
      'issues',
      'penalties'
    ])
  }

  static problemSupplements(id) {
    return orm.Problem.eagerFetch(id[('body', 'supplements')])
  }

  static problems() {
    return orm.Problem.eagerFetch({}, ['body'])
  }

  static problemsAnswers() {
    return orm.Problem.eagerFetch({}, ['body', 'answers'])
  }

  static problemsAnswersTeam() {
    return orm.Problem.eagerFetch({}, ['body', 'answers', 'answers.team'])
  }

  static problemsCategory() {
    // previousProblemもでは?
    return orm.Problem.eagerFetch({}, ['body', 'category'])
  }

  static problemsIssuesTeam() {
    return orm.Problem.eagerFetch({}, ['body', 'issues', 'issues.team'])
  }

  static scoreboardsTeam() {
    // 順位変更があるとVuexにある古い値が表示されるので全削除
    orm.Scoreboard.deleteAll()
    return orm.Scoreboard.eagerFetch({}, ['team'])
  }

  static sessionsTeam() {
    orm.Session.deleteAll()
    return orm.Session.eagerFetch({}, ['team'])
  }

  static team(id) {
    return orm.Team.eagerFetch(id, [])
  }

  static teams() {
    return orm.Team.eagerFetch({}, [])
  }

  static reloadRecords(path, mutation, problemId) {
    const top = /^\/$/
    const teams = /^\/teams\/?$/
    const answers = /^\/answers\/?$/
    const issues = /^\/issues\/?$/
    const problems = /^\/problems\/?$/
    const problemAll = /^\/problems\/.+$/
    const problem = new RegExp(`^/problems/${problemId}/?$`)

    switch (mutation) {
      case 'AddAnswer':
        if (answers.test(path)) {
          orm.Queries.problemsAnswersTeam()
        } else if (problem.test(path)) {
          orm.Queries.problemAnswersTeam(problemId)
        }
        break
      case 'AddIssueComment':
        if (issues.test(path)) {
          orm.Queries.problemsIssuesTeam()
        } else if (problem.test(path)) {
          orm.Queries.problemIssuesTeam(problemId)
        }
        break
      case 'AddNotice':
        if (top.test(path)) {
          orm.Queries.noticesTeam()
        }
        break
      case 'AddPenalty':
        if (top.test(path)) {
          orm.Queries.scoreboardsTeam()
        } else if (problem.test(path)) {
          orm.Queries.problemPenaltiesTeam(problemId)
        }
        break
      case 'AddProblemSupplement':
        if (problem.test(path)) {
          orm.Queries.problemSupplements(problemId)
        }
        break
      case 'ApplyCategory':
        if (problems.test(path)) {
          orm.Queries.categories()
        }
        break
      case 'ApplyProblem':
        if (problems.test(path) || answers.test(path)) {
          orm.Queries.problemsAnswersTeam()
        } else if (problem.test(path)) {
          orm.Queries.problemAnswersTeam(problemId)
        }
        break
      case 'ApplyProblemEnvironment':
        if (problem.test(path)) {
          orm.Queries.problemProblemEnvironments(problemId)
        }
        break
      case 'ApplyScore':
        if (problems.test(path) || answers.test(path)) {
          orm.Queries.problemsAnswersTeam()
        } else if (problem.test(path)) {
          orm.Queries.problemAnswersTeam(problemId)
        } else if (top.test(path)) {
          orm.Queries.scoreboardsTeam()
        }
        break
      case 'ApplyTeam':
        if (teams.test(path)) {
          orm.Queries.teams()
        }
        break
      case 'ConfirmingAnswer':
        if (answers.test(path)) {
          orm.Queries.problemsAnswersTeam()
        } else if (problem.test(path)) {
          orm.Queries.problemAnswersTeam(problemId)
        }
        break

      // case 'DeleteAttachment':
      // case 'DeleteCategory':
      // case 'DeleteIssueComment':
      // case 'DeleteNotice':
      // case 'DeleteProblem':
      // case 'DeleteProblemEnvironment':
      // case 'DeleteProblemSupplement':
      // case 'DeleteSession':

      case 'PinNotice':
        if (top.test(path)) {
          orm.Queries.noticesTeam()
        }
        break
      case 'RegradeAnswers':
        if (
          answers.test(path) ||
          problems.test(path) ||
          problemAll.test(path)
        ) {
          orm.Queries.problemsAnswersTeam()
        }
        break
      case 'StartIssue':
        if (problem.test(path)) {
          orm.Queries.problemIssuesTeam(problemId)
        }
        break
      case 'TransitionIssueState':
        if (issues.test(path)) {
          orm.Queries.problemsIssuesTeam()
        } else if (problem.test(path)) {
          orm.Queries.problemIssuesTeam(problemId)
        }
        break
      case 'UpdateConfig':
        $nuxt.$store.dispatch('contestInfo/fetchContestInfo')
        break
      default:
        $nuxt.notifyError({ message: `unhandled mutation ${mutation}` })
        console.error(`unhandled mutation ${mutation}`)
    }
  }
}
