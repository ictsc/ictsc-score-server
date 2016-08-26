import { Component, ElementRef, SimpleChanges, Output, Input } from '@angular/core';
import { DomSanitizationService } from '@angular/platform-browser';
import * as showdown from "showdown";

@Component({
  selector: 'markdown',
  template: `<div [innerHTML]="htmlText"></div>`,
})
export class Markdown {
  constructor(private sanitizer: DomSanitizationService) {
    let conv =  new showdown.Converter();
    conv.setOption("tables", "true");
    conv.setOption("tablesHeaderId", "true");
    conv.setOption("tasklists", "true");
    conv.setOption("parseImgDimensions", "true");
    conv.setOption("headerLevelStart", "2");
    this.converter = conv;
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

  converter;
  private get gethtmlText(){
    let html = this.converter.makeHtml(this.body);
    if(this.bypass)
      return this.sanitizer.bypassSecurityTrustHtml(html);
    return html;
  }
}
