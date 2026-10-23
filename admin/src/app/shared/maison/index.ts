export { applyBrand, onColor, luminance } from './brand';
export { RevealDirective } from './reveal.directive';
export { CountUpDirective } from './count-up.directive';
export { BumpDirective } from './bump.directive';

import { BumpDirective } from './bump.directive';
import { CountUpDirective } from './count-up.directive';
import { RevealDirective } from './reveal.directive';

/** Import into a standalone component's `imports` to get every Maison directive. */
export const MAISON = [RevealDirective, CountUpDirective, BumpDirective] as const;
