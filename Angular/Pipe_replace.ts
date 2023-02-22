import { Pipe, PipeTransform } from '@angular/core';

@Pipe({ name: 'replace' })
export class Pipe_replace implements PipeTransform {
    transform(value: string, strRegExp: string, replaceValue: string): string | null {
        if (value == null) { return null; }
        return value.replace(new RegExp(strRegExp, 'g'), replaceValue);
    }
}
