// App
export * from './main.component';
export * from './main.service';
export * from './main.routes';
export * from './main-clock.component';

import { AppState } from './main.service';
import { ApiService } from '../common/api.service';
import { AuthGuard } from '../common/authguard';

// Application wide providers
export const APP_PROVIDERS = [
  AppState,
  ApiService,
  AuthGuard,
];
