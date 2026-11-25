'use client';

import { Tooltip, UnstyledButton } from '@mantine/core';
import { AmigaCheckmark } from '@/components/AmigaCheckmark/AmigaCheckmark';
import { useAmigaMode } from './use-amiga-mode';
import classes from './AmigaModeToggle.module.css';

/** The header's Amiga Mode control: a keycap that stays down while the mode is on. */
export function AmigaModeToggle() {
  const [amigaMode, setAmigaMode] = useAmigaMode();

  return (
    <Tooltip label={amigaMode ? 'Switch to modern fonts' : 'Switch to Amiga mode'} withArrow>
      <UnstyledButton
        className={classes.key}
        onClick={() => setAmigaMode(!amigaMode)}
        aria-label="Amiga mode"
        aria-pressed={amigaMode}
      >
        <span className={classes.cap}>
          <AmigaCheckmark size={16} />
        </span>
      </UnstyledButton>
    </Tooltip>
  );
}
