// デフォルトだとmomentに無効な値を与えると"Invalid Date"が返る
// 扱いづらいので代わりにnullを返す。 つもりが何故かundefinedになる

export default (ctx) => {
  ctx.$moment.updateLocale(ctx.$moment.locale(), { invalidDate: null })
}
