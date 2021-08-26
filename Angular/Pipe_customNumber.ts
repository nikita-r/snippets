import { DecimalPipe } from '@angular/common';
import { Pipe, PipeTransform } from '@angular/core';

@Pipe({ name: 'customNumber' })
export class Pipe_customNumber extends DecimalPipe implements PipeTransform {
    transform(value: any, args?: any): any {
        let result = super.transform(value, args);
        if (value < 0) {
            result = '\u2212' + result.slice(1);
        }
        return result;
    }
}
