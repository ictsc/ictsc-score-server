import { ApolloClient } from 'apollo-client'
import { createHttpLink } from 'apollo-link-http'
import { onError } from 'apollo-link-error'
import { InMemoryCache } from 'apollo-cache-inmemory'
import { elvis } from '~/plugins/elvis'

const errorLink = onError(
  ({ operation, response, graphQLErrors, networkError, forward }) => {
    if (graphQLErrors) {
      graphQLErrors.map(({ message, locations, path }) =>
        console.log(
          `[GraphQL error]: Message: ${message}, Location: ${JSON.stringify(
            locations
          )}, Path: ${path}`
        )
      )

      // errorsをnullにしないと例外を発生させるためdataに無理やりerrorを入れて回避する
      response.data.errors = response.errors
      response.data.errorMessages = response.errors
        .map(o => o.message)
        .join('\n')
      response.errors = null
    }

    // errorsが空ならキーを削除することで、フロントでのエラー処理を簡易化
    if (elvis(response, 'data.errors.length') === 0) {
      delete response.data.errors
    }

    if (networkError) {
      console.log(`[Network error]`, networkError)

      if (networkError.statusCode === 401) {
        // エラーがキャッチできないのでloginに遷移
        // locationを直接使うことで強制リロード
        // ストアもリセットされる
        window.location = '/login'
      } else {
        // TODO: 想定外
      }
    }
  }
)

const httpLink = createHttpLink({ uri: '/api/graphql' })

export default new ApolloClient({
  defaultOptions: {
    watchQuery: {
      // fetch時にキャッシュしない
      // TODO: plugin-graphql側で制御されているので効かない
      // fetchPolicy: 'no-cache',
      errorPolicy: 'all'
    }
  },
  link: errorLink.concat(httpLink),
  // link: httpLink.concat(errorLink),
  cache: new InMemoryCache()
})
