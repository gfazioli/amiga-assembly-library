'use client';

import { createTheme } from '@mantine/core';

export const theme = createTheme({
  primaryColor: 'orange',
  // Mantine gives its interactive components the default arrow cursor, links rendered by them
  // included (NavLink, Anchor, the table of contents): a docs site wants the hand on every link.
  cursorType: 'pointer',
  // Code in the system monospace stack, as the Nextra site showed it. Topaz is asked for by name
  // where it belongs: Amiga Mode (theme/global.css) and the home page's terminal.
  fontFamilyMonospace:
    'ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", "Courier New", monospace',
});
