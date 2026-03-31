'use client';

import { useEffect, useState } from 'react';
import { Box, Tooltip, UnstyledButton } from '@mantine/core';

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
      <UnstyledButton onClick={toggle} aria-label="Toggle Amiga mode">
        {/* Outer keycap base — beveled edges */}
        <Box
          style={{
            display: 'inline-flex',
            alignItems: 'center',
            justifyContent: 'center',
            width: 34,
            height: 34,
            borderRadius: 10,
            background: amigaMode
              ? 'linear-gradient(160deg, #303030 0%, #c8c4b8 40%, #ffffff 100%)'
              : 'linear-gradient(160deg, #ffffff 0%, #e4e2e2 40%, #303030 100%)',
            boxShadow: amigaMode
              ? '0 2px 4px rgba(0,0,0,0.4), inset 0 1px 0 rgba(255,255,255,0.6)'
              : '0 2px 4px rgba(0,0,0,0.5), inset 0 1px 0 rgba(255,255,255,0.15)',
            cursor: 'pointer',
            transition: 'all 0.15s ease',
          }}
        >
          {/* Inner keycap surface — raised center */}
          <Box
            style={{
              display: 'inline-flex',
              alignItems: 'center',
              justifyContent: 'center',
              width: 26,
              height: 26,
              borderRadius: 6,
              background: amigaMode
                ? 'linear-gradient(160deg, #e2e2e2 0%, #959393 100%)'
                : 'linear-gradient(160deg, #959393 0%, #e2e2e2 100%)',
              boxShadow: amigaMode
                ? 'inset 0 -1px 1px rgba(255, 255, 255, 1), 0 1px 0 rgba(255,255,255,0.4)'
                : 'inset 0 -1px 1px rgba(245, 243, 243, 0.2), 0 1px 0 rgba(255,255,255,0.08)',
            }}
          >
            <AmigaCheckIcon size={16} />
          </Box>
        </Box>
      </UnstyledButton>
    </Tooltip>
  );
}
