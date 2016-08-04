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
  private simplemde: any;
  @Input("body") text: string = "";
  @Input("bypass") bypass: boolean = false;

  ngOnInit() {
  }
  ngOnChanges(changes: SimpleChanges){
  }

  getEditorValue(){
    return this.simplemde.value();
  }
  updateEditorValue(str: string){
    this.simplemde.value(str);
  }

  get htmlText(){
    let html = new showdown.Converter().makeHtml(this.text);
    if(this.bypass)
      return this.sanitizer.bypassSecurityTrustHtml(html);
    return html;
  }
}
