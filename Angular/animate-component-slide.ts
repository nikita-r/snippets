/* animate-component-slide.ts */

@Component({
   /*...*/
   template: `'<div [@trigShowHide]="toShow ? 'show' : 'hide'">
<!--...-->
</div>
`,
   animations: [
      trigger('trigShowHide', [
         state('show', style({
            height: '*',
            opacity: 1,
         })),
         state('hide', style({
            height: '0',
            opacity: 0,
         })),
         transition('show => hide', [
            animate('200ms ease-in'),
         ]),
         transition('hide => show', [
            animate('200ms ease-out'),
         ]),
      ]),
   ],
})
export class MyComponent {
   @Input()
   toShow: boolean;
}

