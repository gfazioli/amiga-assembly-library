'use client';

import { useEffect, useState } from 'react';
import { ActionIcon, Tooltip } from '@mantine/core';

const STORAGE_KEY = 'amiga-mode';

function AmigaCheckIcon({ size = 20 }: { size?: number }) {
  return (
    <svg
      clipRule="evenodd"
      fillRule="evenodd"
      height={size}
      viewBox="0 0 48 48"
      width={size}
      xmlns="http://www.w3.org/2000/svg"
    >
      <g clipRule="evenodd">
        <g fillRule="evenodd">
          <path d="m33.568 16h-5l4.216-6h5zm6 0h-5l4.216-6h5z" fill="#f36c00" />
          <path d="m29.351 22h-5l4.217-6h5zm6 0h-5l4.217-6h5z" fill="#ff9000" />
          <path d="m25.135 28h-5l4.216-6h5zm6 0h-5l4.216-6h5z" fill="#ffa100" />
          <path d="m12.143 36 2.857 4-4 1-3.667-5zm6 0 2.857 4-4 1-3.667-5z" fill="#237f2d" />
          <path d="m18.143 36h-4.81l-3.666-5h4.904z" fill="#008390" />
          <path d="m20.919 34h-5l4.216-6h5zm6 0h-5l4.216-6h5z" fill="#fdc200" />
          <path d="m16 41h-5l4.919-7h5zm6 0h-5l4.919-7h5z" fill="#feda0f" />
          <path d="m37.784 10h-5l4.216-6h5zm6 0h-5l4.216-6h5z" fill="#dc4100" />
          <path d="m12.143 36h-4.81l-3.666-5h4.904z" fill="#008390" />
          <path d="m8.571 31h-4.904l-3.667-5h5zm6 0h-4.904l-3.667-5h5z" fill="#0075c0" />
        </g>
      </g>
    </svg>
  );
}

export function AmigaModeToggle() {
  const [amigaMode, setAmigaMode] = useState(false);

  useEffect(() => {
    const saved = localStorage.getItem(STORAGE_KEY);
    if (saved === 'true') {
      setAmigaMode(true);
      document.documentElement.setAttribute('data-amiga-mode', '');
    }
  }, []);

  const toggle = () => {
    const next = !amigaMode;
    setAmigaMode(next);
    if (next) {
      document.documentElement.setAttribute('data-amiga-mode', '');
      localStorage.setItem(STORAGE_KEY, 'true');
    } else {
      document.documentElement.removeAttribute('data-amiga-mode');
      localStorage.setItem(STORAGE_KEY, 'false');
    }
  };

  return (
    <Tooltip label={amigaMode ? 'Switch to modern fonts' : 'Switch to Amiga mode'} withArrow>
      <ActionIcon
        variant={amigaMode ? 'filled' : 'subtle'}
        color={amigaMode ? 'orange' : 'gray'}
        onClick={toggle}
        size="lg"
        aria-label="Toggle Amiga mode"
      >
        <AmigaCheckIcon />
      </ActionIcon>
    </Tooltip>
  );
}
