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

export function maxBy (arr, key) {
  if (!arr || arr.length === 0) {
    return null;
  }

  return arr.reduce((p, n) => (Date.parse(p[key]) < Date.parse(n[key]) ? n : p));
}

export function minBy (arr, key) {
  if (!arr || arr.length === 0) {
    return null;
  }

  return arr.reduce((p, n) => (Date.parse(p[key]) > Date.parse(n[key]) ? n : p));
}

// 昇順
export function sortBy (arr, key, reverse = false) {
  const compare = !reverse ? (p1, p2) => (p1[key] - p2[key]) : (p1, p2) => (p2[key] - p1[key]);
  return arr.sort(compare);
}
