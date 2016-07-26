// App
export * from './main.component';
export * from './main.service';
export * from './main.routes';

import { AppState } from './main.service';

// Application wide providers
export const APP_PROVIDERS = [
  AppState
];
