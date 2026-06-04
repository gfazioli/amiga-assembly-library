'use client';

import { Navbar } from 'nextra-theme-docs';
import { Button, Group, Text } from '@mantine/core';
import { IconHeartFilled } from '@tabler/icons-react';
import { AmigaModeToggle } from '../AmigaModeToggle/AmigaModeToggle';
import { ColorSchemeControl } from '../ColorSchemeControl/ColorSchemeControl';
import { Logo } from '../Logo/Logo';
import { MantineNextraThemeObserver } from '../MantineNextraThemeObserver/MantineNextraThemeObserver';

export const MantineNavBar = () => {
  return (
    <>
      <MantineNextraThemeObserver />
      <Navbar
        logo={
          <Group align="center" gap={4}>
            <Logo />
            <Text size="lg" fw={600} c="orange" visibleFrom="xl">
              Amiga Assembly Library
            </Text>
          </Group>
        }
        chatLink="https://eab.abime.net/"
        projectLink="https://github.com/gfazioli/amiga-assembly-library"
      >
        <AmigaModeToggle />
        <ColorSchemeControl />
        <Button
          component="a"
          href="#sponsors"
          size="sm"
          radius="xl"
          variant="gradient"
          gradient={{ from: 'pink', to: 'grape' }}
          leftSection={<IconHeartFilled size={14} />}
        >
          Sponsor
        </Button>
      </Navbar>
    </>
  );
};
