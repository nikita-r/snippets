import * as moment from 'moment';

export class BasedUtil {

    static keys<T extends object>(obj: T) {
        return Object.keys(obj) as Array<keyof T>;
    }

    static momentTryDateStr(str: string | moment.Moment): string {
        if (str == null) { return '\u2014'; }
        const mom = moment(str); // moment(undefined) returns Now
        if (mom.isValid()) {
            return mom.format('YYYY-MM-DD');
        }
        if (typeof str === 'string') {
            return str;
        }
        return mom.toString(); // "Invalid date"
    }
}
