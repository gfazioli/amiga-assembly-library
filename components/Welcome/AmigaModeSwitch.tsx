'use client';

import { Switch } from '@mantine/core';
import { AmigaCheckmark } from '@/components/AmigaCheckmark/AmigaCheckmark';
import { useAmigaMode } from '@/components/AmigaModeToggle/use-amiga-mode';
import classes from './Welcome.module.css';

/** The home page's Amiga Mode switch: the same state as the header's keycap. */
export function AmigaModeSwitch() {
  const [amigaMode, setAmigaMode] = useAmigaMode();

  return (
    <Switch
      className={classes.amigaMode}
      checked={amigaMode}
      onChange={(event) => setAmigaMode(event.currentTarget.checked)}
      label="Amiga Mode"
      description="The whole site in Topaz, the Amiga's system font"
      size="lg"
      thumbIcon={<AmigaCheckmark size={16} />}
      onLabel="ON"
      offLabel="OFF"
    />
  );
}
