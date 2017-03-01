<template>
  <div>
    <div class="row justify-content-center">
      <div class="col-4">
        <h1>サインアップ</h1>
          <div class="form-group">
            <label for="input-name">氏名</label>
            <input type="text" class="form-control form-control-lg" id="input-name">
          </div>
          <div class="form-group">
            <label for="input-register-code">登録コード</label>
            <input type="text" class="form-control form-control-lg" id="input-register-code">
          </div>
          <div class="form-group">
            <label for="input-org">所属とチーム</label>
            <input type="text" class="form-control form-control-lg" id="input-org" readonly>
          </div>
          <div class="form-group">
            <label for="input-member-id">メンバーID</label>
            <input type="text" class="form-control form-control-lg" id="input-member-id">
          </div>
          <div class="form-group">
            <label for="input-password">パスワード</label>
            <input type="password" class="form-control form-control-lg" id="input-password">
          </div>
          <div class="form-group">
            <button type="button" class="btn btn-success btn-lg btn-block">サインアップ</button>
          </div>
          <p class="text-center"><a href="">サインアップはこちら</a></p>
      </div>
    </div>
  </div>
</template>

<style>

</style>

<script>
import { SET_TITLE } from '../store/'

export default {
  name: 'empty',
  data () {
    return {
    }
  },
  asyncData: {
  },
  computed: {
  },
  watch: {
  },
  mounted () {
    this.$store.dispatch(SET_TITLE, 'サイト一覧');
  },
  destroyed () {
  },
  methods: {
  },
}
</script>

