import { Component, ElementRef, SimpleChanges, Output, Input } from '@angular/core';
import { DomSanitizationService } from '@angular/platform-browser';
import * as showdown from "showdown";

@Component({
  selector: 'markdown',
  template: `<div [innerHTML]="htmlText"></div>`,
})
export class Markdown {
  constructor(private sanitizer: DomSanitizationService) {
  }

  private textAreaElem: ElementRef;
  private htmlText: any;
  @Input() body: string = "";
  @Input() bypass: boolean = false;

  ngOnInit() {
  }
  ngOnChanges(changes: SimpleChanges){
    this.htmlText = this.gethtmlText;
  }

  private get gethtmlText(){
    let html = new showdown.Converter().makeHtml(this.body);
    if(this.bypass)
      return this.sanitizer.bypassSecurityTrustHtml(html);
    return html;
  }
}
