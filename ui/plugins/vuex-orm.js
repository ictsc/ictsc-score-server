import VuexORM, { Database } from '@vuex-orm/core'
import VuexORMGraphQLPlugin, {
  DefaultAdapter,
  ConnectionMode,
} from '@vuex-orm/plugin-graphql'
import orm from '~/orm'
import apolloClient from '~/plugins/apollo-client'

class CustomAdapter extends DefaultAdapter {
  getConnectionMode() {
    return ConnectionMode.PLAIN
  }
}

const database = new Database()
Object.values(orm)
  .filter((model) => !!model.entity)
  .forEach((model) => database.register(model))

const options = {
  adapter: new CustomAdapter(),
  apolloClient,
  database,
  debug: process.env.NODE_ENV !== 'production',
}

VuexORM.use(VuexORMGraphQLPlugin, options)

export default ({ store }, inject) => {
  VuexORM.install(database)(store)

  // 主にデバッグ用
  inject('orm', orm)
}
