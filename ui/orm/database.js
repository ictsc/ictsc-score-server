import { Database } from '@vuex-orm/core'
import orm from '~/orm'

const database = new Database()
database.register(orm.Category)

export default database
