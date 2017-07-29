<template>
  <div>
    <div class="notif-container">
      <transition-group name="list">
        <div v-for="notif in notifs" class="outer" :key="notif.id">
          <div class="item d-flex align-items-center" :class="{ ['item-' + notif.type]: true, }">
            <div class="icon">
              <i class="fa" :class="{ ['fa-' + notif.icon]: true, }"></i>
            </div>
            <div class="body">
              <h5>{{ notif.title }}</h5>
              <p>{{ notif.detail }}</p>
            </div>
            <div class="x" v-on:click="hide(notif.id)">
              <i class="fa fa-times" aria-hidden="true"></i>
            </div>
          </div>
        </div>
      </transition-group>
    </div>
  </div>
</template>

<style scoped>
.item, .item.item-success {
  background: #07D8E0;
}
.item, .item.item-warn {
  background: #F8B500;
}
.item, .item.item-error {
  background: #E83929;
}


.notif-container {
  position: fixed;
  bottom: 2rem;
  right: 2rem;
  color: white;
  z-index: 1500;
  width: 30rem;
}
.item {
  height: 8rem;
  opacity: .8;
  border-radius: 10px;
  transition: opacity 300ms ease;
  position: relative;
  margin-top: 1rem;
}
.item:hover {
  opacity: 1;
}
.icon {
  font-size: 5rem;
  padding: 0 2rem;
  text-align: center;
}
.body {
  padding-right: 2rem;
}
.body h5 {
  font-size: 1rem;
}
.body p {
  margin: 0;
  font-size: .8rem;
}
.x {
  position: absolute;
  top: 0rem;
  right: 0rem;
  font-size: 1.6rem;
  padding: 0.6rem;
  cursor: pointer;
  line-height: 1;
}


.outer, .list-move {
  transition: all 500ms;
  position: relative;
}
.outer.list-enter, .outer.list-leave-to {
  opacity: 0;
  transform: translateX(10rem);
}
.outer.list-leave-to {
  height: 0;
}
.outer.list-enter-to, .outer.list-leave {
  height: 8rem;
}
.outer.list-leave-active .item {
  position: absolute;
  bottom: 0rem;
}
</style>

<script>
/*
Notifコンポーネントは、EventBusからイベントを受け取り、通知の表示を行います。

通知の表示を行うサンプルは以下のとおりです。

```js
import { Emit, PUSH_NOTIF } from '../utils/EventBus'
Emit(PUSH_NOTIF, {
  type: 'error',  // success/warn/error
  icon: 'warning',  // fontawsomeのアイコン名
  title: '設定の更新に失敗しました。',  // タイトル
  detail: 'ドメインチェックが失敗したため、サイトを有効にできません。',  // エラー文など
  key: 'setting', // 削除等を行う時の基準キー
  autoClose: false,  // 自動的に表示を消す
});
```

`autoClose` がtrueの場合、 `this.timeout` ミリ秒で通知を消します。
指定がない場合は、 `type` がerror,warnの際はfalse・successの場合はtrueがデフォルトで指定されます。

通知を消すサンプルは以下のとおりです。

```js
import { Emit, PUSH_NOTIF, REMOVE_NOTIF } from '../utils/EventBus'
Emit(REMOVE_NOTIF, msg => msg.key === 'setting');
```

REMOVE_NOTIFイベントでは、通知のインデックス番号・message => boolな関数を引数に指定できます。
ここでは、上に指定したkeyを持つ通知のみ消しています。

*/


import { Subscribe, PUSH_NOTIF, REMOVE_NOTIF } from '../utils/EventBus'

export default {
  name: '',
  data () {
    return {
      notifs: [
      ],
      incr: 1,
      pushSubscriber: Subscribe(PUSH_NOTIF, opt => { this.append(opt) }),
      removeSubscriber: Subscribe(REMOVE_NOTIF, fn => { this.hide(fn) }),
      refreshInterval: setInterval(_ => this.refresh(), 500),
      timeout: 3000, // autoclose ms
    }
  },
  asyncData: {
  },
  computed: {
  },
  watch: {
  },
  mounted () {
  },
  beforeDestroy () {
    this.pushSubscriber.off();
    this.removeSubscriber.off();
    clearInterval(this.refreshInterval);
  },
  destroyed () {
  },
  methods: {
    append (message) {
      var autoClose;
      var icon;
      switch (message.type) {
        case 'error':
        case 'warn':
          icon = 'warning';
          autoClose = false;
          break;
        default:
        case 'success':
          icon = 'check';
          autoClose = true;
          break;
      }

      var includeIdMessage = Object.assign({
        id: this.incr++,
        timestamp: Date.now(),
        autoClose,
        icon,
      }, message)
      this.notifs.push(includeIdMessage);
    },
    hide (cond) {
      var fn;
      if (typeof cond === 'number') {
        fn = n => n.id === cond;
      } else if (typeof cond === 'function') {
        fn = cond
      } else {
        console.warn('[Notif] hide cond must number/function');
        return;
      }
      this.notifs = this.notifs.filter(s => !fn(s));
    },
    refresh () {
      this.hide(msg => msg.autoClose && (msg.timestamp + this.timeout < Date.now()));
    },
  },
}
</script>

