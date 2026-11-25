'use client';

import { createTheme, type MantineColorsTuple } from '@mantine/core';

/**
 * The site's palette is Workbench 1.3's, after dark: its blue (#0055AA) taken down to a
 * night-blue ground, its orange (#FF8800) as the one accent, white and black for the type.
 *
 * `orange` replaces Mantine's: index 5 is the Workbench orange, lightened a touch for the dark
 * scheme's fills; 6 fills in the light scheme; 8 is the darkest a link can go and still read as
 * orange, and the first that passes WCAG AA on the light scheme's paper (see theme/global.css,
 * which points the light scheme's orange text at it).
 */
const orange: MantineColorsTuple = [
  '#fff5e6',
  '#ffe8c7',
  '#ffd399',
  '#ffbb66',
  '#ffa53d',
  '#ff8f1a',
  '#f57c00',
  '#d16500',
  '#a84f00',
  '#7d3a00',
];

/** The dark scheme's greys, tinted with the Workbench blue: 9 is the page, 6 a raised surface. */
const dark: MantineColorsTuple = [
  '#e6e9f2',
  '#c5cbdb',
  '#9aa5be',
  '#6d7994',
  '#36425f',
  '#283350',
  '#1b243a',
  '#131a2d',
  '#0e1424',
  '#090d19',
];

/**
 * The light scheme's greys, warm like a manual's paper. 6 is darker than Mantine's: it is the
 * dimmed text colour, and Mantine's own (#868e96) fails AA on white.
 */
const gray: MantineColorsTuple = [
  '#faf9f6',
  '#f3f1eb',
  '#e8e5dd',
  '#dad6cc',
  '#c6c1b5',
  '#a8a295',
  '#6f695e',
  '#57524a',
  '#3b3833',
  '#23211e',
];

export const theme = createTheme({
  primaryColor: 'orange',
  primaryShade: { light: 6, dark: 5 },
  colors: { orange, dark, gray },
  black: '#1a1917',
  // Black type on the orange fills: white on #f57c00 is 2.8:1, black is 7:1.
  autoContrast: true,
  // Squarer than Mantine's: gadgets, not pills.
  radius: { xs: '2px', sm: '3px', md: '4px', lg: '6px', xl: '10px' },
  defaultRadius: 'md',
  // Mantine gives its interactive components the default arrow cursor, links rendered by them
  // included (NavLink, Anchor, the table of contents): a docs site wants the hand on every link.
  cursorType: 'pointer',
  // Code in the system monospace stack. Topaz is asked for by name where it belongs, through
  // `--aal-font-pixel` (theme/global.css): the display type, the window chrome and Amiga Mode.
  fontFamilyMonospace:
    'ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", "Courier New", monospace',
  headings: { fontWeight: '700' },
});
