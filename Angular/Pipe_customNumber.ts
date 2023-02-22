import { DecimalPipe } from '@angular/common';
import { Pipe, PipeTransform } from '@angular/core';

@Pipe({ name: 'customNumber' })
export class Pipe_customNumber extends DecimalPipe implements PipeTransform {
    transform(value: any, args?: any): any {
        if (value == null) { return 'N/A'; }
        if (value < 0) {
            return '\u2212' + super.transform(-value, args);
        } else {
            return super.transform(value, args);
        }
    }
}
