import { Component, Directive, ElementRef, SimpleChanges, Output, Input, EventEmitter } from '@angular/core';
import { DomSanitizationService } from '@angular/platform-browser';
import * as showdown from "showdown";

@Directive({
  selector: "[editableModel]",
  // template: `<span contenteditable="true"
    //  [textContent]="model" (input)="model=$event.target.textContent; update.next(model)"></span>`,
// template: 'aa'
	host: {
		'(input)': 'onBlur()'
	}
})
export class Editable {
  constructor(private elRef: ElementRef) {
  }
  @Input("editable") editable: boolean = true;
  @Input("editableModel") model: any;
	@Output('editableModelChange') update = new EventEmitter();

  ngOnInit() {
  }

	private lastViewModel: any;

	ngOnChanges(changes) {
		// if (isPropertyUpdated(changes, this.lastViewModel)) {
			this.lastViewModel = this.model
			this.refreshView();
		// }
	}

	onBlur() {
		var value = this.elRef.nativeElement.innerText
		this.lastViewModel = value
		this.update.emit(value)
	}

	private refreshView() {
		this.elRef.nativeElement.innerText = this.model;
    this.elRef.nativeElement.setAttribute("contenteditable", this.editable?"true":"false");
	}
}
