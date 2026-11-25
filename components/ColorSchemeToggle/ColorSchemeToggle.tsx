'use client';

import { IconDeviceDesktop, IconMoon, IconSun } from '@tabler/icons-react';
import { Button, useMantineColorScheme } from '@mantine/core';

/** Light, dark or the system's: the three ways Mantine's colour scheme can be set. */
export function ColorSchemeToggle() {
  const { setColorScheme } = useMantineColorScheme();

  return (
    <Button.Group mt="md">
      <Button
        variant="default"
        size="xs"
        leftSection={<IconSun size={14} aria-hidden="true" />}
        onClick={() => setColorScheme('light')}
      >
        Light
      </Button>
      <Button
        variant="default"
        size="xs"
        leftSection={<IconMoon size={14} aria-hidden="true" />}
        onClick={() => setColorScheme('dark')}
      >
        Dark
      </Button>
      <Button
        variant="default"
        size="xs"
        leftSection={<IconDeviceDesktop size={14} aria-hidden="true" />}
        onClick={() => setColorScheme('auto')}
      >
        Auto
      </Button>
    </Button.Group>
  );
}
