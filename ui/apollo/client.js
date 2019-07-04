import { ApolloClient } from 'apollo-client'
import { createHttpLink } from 'apollo-link-http'
import { onError } from 'apollo-link-error'
import { InMemoryCache } from 'apollo-cache-inmemory'

const errorLink = onError(
  ({ operation, response, graphQLErrors, networkError, forward }) => {
    if (graphQLErrors) {
      graphQLErrors.map(({ message, locations, path }) =>
        // TODO: エラー通知
        console.log(
          `[GraphQL error]: Message: ${message}, Location: ${locations}, Path: ${path}`
        )
      )
    }

    if (networkError) {
      console.log(`[Network error]`, networkError)

      if (networkError.statusCode === 401) {
        console.log('Unauthorized!!')
        // TODO: 未ログインで再度該当ページに行っても再度/loginに遷移しない
        // エラーがキャッチできないのでloginに遷移
        // eslint-disable-next-line no-undef
        $nuxt.$router.push('/login')
      } else {
        // TODO: エラー通知
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
      // TODO: 効かない
      // errorPolicy: 'ignore'
    }
  },
  link: errorLink.concat(httpLink),
  // link: httpLink.concat(errorLink),
  cache: new InMemoryCache()
})
