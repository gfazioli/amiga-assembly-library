'use client';

import { useEffect, useRef } from 'react';
import { useLocalStorage } from '@mantine/hooks';
import { AMIGA_MODE_ATTRIBUTE, AMIGA_MODE_KEY } from '@/lib/amiga-mode';

/**
 * Amiga Mode, shared by every control that switches it (the header keycap, the home page switch):
 * Mantine's `useLocalStorage` keeps all of them in step, in this tab and in the others, and the
 * attribute on `<html>` follows the value.
 *
 * The first render is skipped: the hook starts at `false` until it has read storage, and on load
 * the attribute is already right, set by `AMIGA_MODE_SCRIPT` before the first paint. Syncing that
 * first `false` would take Topaz away for a frame.
 */
export function useAmigaMode() {
  const [amigaMode, setAmigaMode] = useLocalStorage<boolean>({
    key: AMIGA_MODE_KEY,
    defaultValue: false,
  });
  const mounted = useRef(false);

  useEffect(() => {
    if (!mounted.current) {
      mounted.current = true;
      return;
    }
    document.documentElement.toggleAttribute(AMIGA_MODE_ATTRIBUTE, amigaMode);
  }, [amigaMode]);

  return [amigaMode, setAmigaMode] as const;
}
