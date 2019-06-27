import VuexORM from '@vuex-orm/core'
import VuexORMGraphQL, {
  DefaultAdapter,
  ConnectionMode
} from '@vuex-orm/plugin-graphql'
import database from '~/orm/database'

class CustomAdapter extends DefaultAdapter {
  getConnectionMode() {
    return ConnectionMode.PLAIN
  }
}

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
