import * as moment from "moment";
moment.locale("ja");

export class Time {
  static dateFormat(datetime: Date | string){

    return moment(datetime).fromNow();
  }
}
