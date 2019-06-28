import VuexORM, { Database } from '@vuex-orm/core'
import VuexORMGraphQL, { DefaultAdapter, ConnectionMode } from '@vuex-orm/plugin-graphql'
import orm from '~/orm'

class CustomAdapter extends DefaultAdapter {
  getConnectionMode() {
    return ConnectionMode.PLAIN
  }
}

const database = new Database()
Object.values(orm).forEach(model => database.register(model))

const options = {
  adapter: new CustomAdapter(),
  database,
  debug: process.env.NODE_ENV !== 'production',
  url: '/api/graphql'
}

VuexORM.use(VuexORMGraphQL, options)

export default ({ store }) => {
  VuexORM.install(database)(store)
}
