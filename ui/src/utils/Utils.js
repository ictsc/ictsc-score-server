// Inspired by Ruby's Safe Navigation Operator
// ネストされた値を安全に取得する
// 子が存在しない時点でundefinedを返す
export function nestedValue (parent, ...children) {
  for (const child of children) {
    if (parent === null || parent === undefined) {
      return parent;
    }

    parent = parent[child];
  }

  return parent;
}
