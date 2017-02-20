# vue-sandbox

```
npm install

npm run dev  # ローカル開発用
npm run build  # プロダクション向けにビルド
```

## 独自の文化

### vue-data-sync

- Ajax中のローディング・エラーハンドリング・dataへの代入を担当してくれるプラグイン
- 自作

https://github.com/kamijin-fanta/vue-async-data

### src/utils/EventBus

- グローバルなイベントバスを提供します
- 公開APIは `Emit` `Subscribe` です

### src/components/Notif.vue

通知の表示を行います。

詳しくは、該当ソースのコメントを参照。
