import { Observable } from 'rxjs';
import { MiniList, ApiService } from '../common';
import { Component } from '@angular/core';

import { AppState } from '../main/main.service';

@Component({
  selector: Guide.name.toLowerCase(),
  template: require('./guide.template.jade')
})
export class Guide {
}
