<template>
  <div>
    <delete-component
      :fetch="fetchProblems"
      :delete="deleteProblem"
      label="問題"
      item-value="code"
    />
    <delete-component
      :fetch="fetchCategories"
      :delete="deleteCategory"
      label="カテゴリ"
      item-value="code"
    />
  </div>
</template>
<script>
import orm from '~/orm'
import DeleteComponent from '~/components/settings/DeleteComponent'

export default {
  name: 'DeleteArea',
  components: {
    DeleteComponent
  },
  methods: {
    async fetchProblems() {
      await orm.Problem.eagerFetch({}, [])
      return this.sortByOrder(
        orm.Problem.query()
          .with('body')
          .all()
      )
    },
    async fetchCategories() {
      await orm.Category.eagerFetch({}, [])
      return this.sortByOrder(orm.Category.query().all())
    },
    async deleteCategory(code) {
      let result = false
      await orm.Category.deleteCategory({
        action: 'カテゴリ削除',
        resolve: () => (result = true),
        params: { code }
      })

      return result
    },
    async deleteProblem(code) {
      let result = false
      await orm.Problem.deleteProblem({
        action: '問題削除',
        resolve: () => (result = true),
        params: { code }
      })

      return result
    }
  }
}
</script>
