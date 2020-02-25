import { ApolloClient } from 'apollo-client'
import { createHttpLink } from 'apollo-link-http'
import { onError } from 'apollo-link-error'
import { InMemoryCache } from 'apollo-cache-inmemory'

const errorLink = onError(
  ({ operation, response, graphQLErrors, networkError, forward }) => {
    // APIに疎通が無い, 200以外が返ってくるなど
    if (networkError) {
      console.info('[Network error]', networkError)

      $nuxt.notifyError({
        message: `APIから応答がありません\n運営に問い合わせてください\nコード ${networkError.statusCode}`
      })

      return
    }

    // 正規のGraphQLエラー
    if (graphQLErrors) {
      graphQLErrors.forEach(error => {
        console.info('[GraphQL error]', error)

        // 未ログインなどを処理する
        if (error.extensions && error.extensions.code) {
          switch (error.extensions.code) {
            case 'UNAUTHORIZED':
              $nuxt.$router.push('/login')
              break
            case 'UNEXPECTED_ERROR':
              $nuxt.notifyError({
                message: `想定外のエラーが発生しました\n運営に問い合わせてください\nリクエストID\n${error.extensions.requestId}`
              })
              break
            default:
              // 実装漏れ
              $nuxt.notifyError({
                message: `想定外のエラーコードです\n運営に問い合わせてください\nリクエストID\n${error.extensions.requestId}`
              })
          }
        }
      })
    }

    // response.errorsがあると、そのメッセージを持った例外を発生させる
  }
)

const httpLink = createHttpLink({ uri: '/api/graphql' })

export default new ApolloClient({
  defaultOptions: {
    watchQuery: {
      errorPolicy: 'all'
      // vuex-orm/plugin-graphql側で制御されているので効かない
      // fetch時にキャッシュしない
      // fetchPolicy: 'no-cache',
    }
  },
  link: errorLink.concat(httpLink),
  cache: new InMemoryCache()
})
