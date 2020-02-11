import { ApolloClient } from 'apollo-client'
import { createHttpLink } from 'apollo-link-http'
import { onError } from 'apollo-link-error'
import { InMemoryCache } from 'apollo-cache-inmemory'

const errorLink = onError(
  ({ operation, response, graphQLErrors, networkError, forward }) => {
    // 正規のGraphQLエラー
    if (graphQLErrors) {
      graphQLErrors.forEach(error => {
        console.warn('[GraphQL error]', error)

        // 未ログインなどを処理する
        if (error.extensions) {
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

    // APIに疎通が無い, 200以外が返ってくるなど
    if (networkError) {
      console.warn('[Network error]', networkError)

      $nuxt.notifyError({
        message: `APIから応答がありません\n運営に問い合わせてください\nコード ${networkError.statusCode}`
      })
    }

    // errorsをnullにしないと例外が発生するのでdata入れて回避
    // vuex-orm/plugin-graphqlが自動で発行するスキーマ取得はハンドルしない
    if (operation.operationName === 'Introspection') {
      return
    }

    const errors = response.errors
    delete response.errors

    // errorsが空でない配列ときのみdataに入れる
    if (Array.isArray(errors) && errors.length !== 0) {
      response.data.errors = errors
    }
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
