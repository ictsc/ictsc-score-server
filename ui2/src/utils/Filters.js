import dateformat from 'dateformat';
import * as d3 from 'd3';

export function fullDateFilter (value) {
  var fmtStr = 'yyyy/mm/dd HH:MM'
  try {
    if (value === 0 || value === undefined) {
      return '----/--/-- --:--';
    } else if (typeof value === 'number') {
      return dateformat(new Date(value), fmtStr)
    } else {
      return dateformat(new Date(value), fmtStr)
    }
  } catch (e) {
    console.error('Filters/fullDate', e, value);
    return '----/--/-- --:--';
  }
}

export function countFilter (value) {
  return d3.format(',')(value);
}
export function prefixCountFilter (value) {
  if (value < 1) {
    return d3.format('.2')(value)
  } else {
    return d3.format(',.2s')(value);
  }
}
export function percentageFilter (value) {
  return d3.format('.2f')(value) + '%';  // like: 100.00%
}
