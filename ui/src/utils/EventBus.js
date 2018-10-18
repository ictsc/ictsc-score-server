import Vue from 'vue';

// サイト追加時など、コンポーネントを超えてイベントを発行する

let EventBus = new Vue();
export let Subscribe = function (event, callback) {
  EventBus.$on(event, callback);
  return {
    off: () => EventBus.$off(event, callback),
  }
}
export let Emit = function (event, ...args) {
  EventBus.$emit(event, ...args)
}

// サイドバーのサイト一覧を更新する 引数なし
export const NEED_REFRESH_SITE_LIST = 'NEED_REFRESH_SITE_LIST';

// 認証エラー時に発行 引数なし
export const AUTH_ERROR = 'AUTH_ERROR';

// プッシュ通知を行う `components/Notif.vue`で購読中 引数:Object
export const PUSH_NOTIF = 'PUSH_NOTIF';

// プッシュ通知を行う `components/Notif.vue`で購読中 引数:(msgObj: Object) => Boolean
export const REMOVE_NOTIF = 'REMOVE_NOTIF';
