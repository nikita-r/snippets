import { Pipe, PipeTransform } from '@angular/core';

@Pipe({
  name: 'callback',
  pure: false
})
export class CallbackPipe implements PipeTransform {
  transform(items: any[]
      , callback: (item: any) => boolean
      , transfigure?: (item: any) => any
      ): any[] {
    if (!transfigure) {
      transfigure = item => item;
    }
    return items.filter(callback).map(transfigure);
  }
}

