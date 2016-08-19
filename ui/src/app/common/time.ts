import * as moment from "moment";
import { Pipe, PipeTransform } from '@angular/core';
moment.locale("ja");

export class Time {
  static dateFormat(datetime: Date | string){
    let date = moment(datetime);

    let time = date.format('Do h:mm');
    let offset = date.fromNow();
    return `${time} (${offset})`;
  }
}

/*
 * Raise the value exponentially
 * Takes an exponent argument that defaults to 1.
 * Usage:
 *   value | exponentialStrength:exponent
 * Example:
 *   {{ 2 |  exponentialStrength:10}}
 *   formats to: 1024
*/
@Pipe({name: 'time'})
export class TimePipe implements PipeTransform {
  transform(value: string, exponent: string){
    if(typeof value == "undefined") return "NaN";
    return Time.dateFormat(value);
  }
}
