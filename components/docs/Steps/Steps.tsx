import { Box } from '@mantine/core';
import classes from './Steps.module.css';

/**
 * Numbered vertical steps. The numbering is pure CSS counters on the
 * `h3` headings nested inside (same authoring convention as Nextra/fumadocs).
 */
export function Steps({ children }: { children: React.ReactNode }) {
  return <Box className={classes.steps}>{children}</Box>;
}
