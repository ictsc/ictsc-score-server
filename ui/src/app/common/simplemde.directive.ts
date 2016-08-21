import {  ElementRef, SimpleChanges, Output, EventEmitter, Directive, Input } from '@angular/core';
import "simplemde/dist/simplemde.min.css";
import "font-awesome/css/font-awesome.min.css";
let simplemde = require("simplemde/src/js/simplemde.js");

@Directive({
  selector: '[simplemde]',
})
export class SimpleMDE {
  constructor(el: ElementRef) {
    this.textAreaElem = el;
  }

  private textAreaElem: ElementRef;
  private simplemde: any;
  @Input("ngModel") model: any;
  @Output('ngModelChange') update = new EventEmitter();

  ngOnInit() {
    if(this.simplemde) return;
    this.simplemde = new simplemde({
      element: this.textAreaElem.nativeElement,
      spellChecker: false,
      autoDownloadFontAwesome: false,
      simplifiedAutoLink: true,
    });
    this.simplemde.codemirror.on("change", () => this.onTextChanges());
  }
  onTextChanges(){
    let text = this.getEditorValue();
    if(this.model == text) return;
    this.update.next(text);
  }
  ngOnChanges(changes: SimpleChanges){
    this.ngOnInit();
    let str = (typeof this.model == "undefined")?"":this.model.toString();
    if(this.model == this.getEditorValue()) return;
    this.updateEditorValue(str);
  }

  getEditorValue(){
    return this.simplemde.value();
  }
  updateEditorValue(str: string){
    this.simplemde.value(str);
  }
}
