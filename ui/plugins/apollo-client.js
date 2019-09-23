import { ApolloClient } from 'apollo-client'
import { createHttpLink } from 'apollo-link-http'
import { onError } from 'apollo-link-error'
import { InMemoryCache } from 'apollo-cache-inmemory'
import { elvis } from '~/plugins/elvis'

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
              // eslint-disable-next-line no-undef
              $nuxt.$router.push('/login')
              break
            case 'UNEXPECTED_ERROR':
              // eslint-disable-next-line no-undef
              $nuxt.notifyError({
                message: `想定外のエラーが発生しました\n運営に問い合わせてください\nリクエストID\n${error.extensions.requestId}`,
                timeout: 0
              })
              break
            default:
              // 実装漏れ
              // eslint-disable-next-line no-undef
              $nuxt.notifyError({
                message: `想定外のエラーコードです\n運営に問い合わせてください\nリクエストID\n${error.extensions.requestId}`,
                timeout: 0
              })
          }
        }
      })

      // errorsをnullにしないと例外が発生するのでdata入れて無理やり回避
      // vuex-orm/plugin-graphqlが自動で発行するスキーマ取得はハンドルしない
      if (operation.operationName !== 'Introspection') {
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
    }

    // APIに疎通が無い, 200以外が返ってくるなど
    if (networkError) {
      console.warn('[Network error]', networkError)

      // eslint-disable-next-line no-undef
      $nuxt.notifyError({
        message: `APIから応答がありません\n運営に問い合わせてください\nコード ${networkError.statusCode}`,
        timeout: 0
      })
    }
  }
)

const httpLink = createHttpLink({ uri: '/api/graphql' })

export default new ApolloClient({
  defaultOptions: {
    watchQuery: {
      // fetch時にキャッシュしない
      // TODO: vuex-orm/plugin-graphql側で制御されているので効かない
      // fetchPolicy: 'no-cache',
      errorPolicy: 'all'
    }
  },
  link: errorLink.concat(httpLink),
  cache: new InMemoryCache()
})
