'use client';

import { useClipboard } from '@mantine/hooks';
import { FLOPPEEK_BREW } from './floppeek';
import classes from './Floppeek.module.css';

/** The Homebrew command at the Shell's prompt, with a button that copies it. */
export function BrewCommand() {
  const clipboard = useClipboard({ timeout: 2000 });
  return (
    <div className={classes.brew}>
      <code>{FLOPPEEK_BREW}</code>
      <button
        type="button"
        className={classes.copy}
        aria-label="Copy the Homebrew command"
        onClick={() => clipboard.copy(FLOPPEEK_BREW)}
      >
        {clipboard.copied ? 'Copied' : 'Copy'}
      </button>
    </div>
  );
}
