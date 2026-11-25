'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import {
  IconBrandDiscord,
  IconBrandGithub,
  IconChevronDown,
  IconCoffee,
  IconExternalLink,
  IconHeartFilled,
} from '@tabler/icons-react';
import {
  ActionIcon,
  Anchor,
  Burger,
  Group,
  Menu,
  Text,
  Tooltip,
  UnstyledButton,
} from '@mantine/core';
import config from '@/config';
import { isMenu, type TopNavEntry } from '@/lib/docs/types';
import { SearchTrigger } from '../shell/SearchTrigger/SearchTrigger';
import { SidebarToggle, type SidebarToggleProps } from '../shell/SidebarToggle/SidebarToggle';
import { AmigaModeToggle } from '../AmigaModeToggle/AmigaModeToggle';
import { ColorSchemeControl } from '../ColorSchemeControl/ColorSchemeControl';
import { HeaderControl } from '../ColorSchemeControl/HeaderControl';
import { Logo } from '../Logo/Logo';
import classes from './MantineNavBar.module.css';

export interface MantineNavBarProps {
  /** The header links, from `app/_meta.tsx` */
  nav: TopNavEntry[];
  /** The mobile menu button, which opens the sidebar */
  burgerOpened: boolean;
  onBurgerClick: () => void;
  /** The desktop sidebar toggle, on docs routes */
  sidebar?: SidebarToggleProps;
}

function TopNav({ nav }: { nav: TopNavEntry[] }) {
  const pathname = usePathname();

  return (
    <Group gap={4} wrap="nowrap" visibleFrom="md">
      {nav.map((entry) =>
        isMenu(entry) ? (
          <Menu key={entry.key} trigger="click-hover" position="bottom-start" withinPortal>
            <Menu.Target>
              <UnstyledButton className={classes.navLink}>
                <Group gap={4} wrap="nowrap">
                  {entry.title}
                  <IconChevronDown size={14} stroke={1.5} />
                </Group>
              </UnstyledButton>
            </Menu.Target>
            <Menu.Dropdown>
              {entry.items.map((item) => (
                <Menu.Item
                  key={item.key}
                  component="a"
                  href={item.href}
                  target={item.newWindow ? '_blank' : undefined}
                  rel={item.newWindow ? 'noopener noreferrer' : undefined}
                  rightSection={
                    item.newWindow ? <IconExternalLink size={12} stroke={1.5} /> : undefined
                  }
                >
                  {item.title}
                </Menu.Item>
              ))}
            </Menu.Dropdown>
          </Menu>
        ) : (
          <Anchor
            key={entry.key}
            component={Link}
            href={entry.href}
            target={entry.newWindow ? '_blank' : undefined}
            rel={entry.newWindow ? 'noopener noreferrer' : undefined}
            className={classes.navLink}
            data-active={
              !entry.newWindow && (pathname === entry.href || pathname.startsWith(`${entry.href}/`))
                ? true
                : undefined
            }
            underline="never"
          >
            {entry.title}
          </Anchor>
        )
      )}
    </Group>
  );
}

/**
 * The site header, on Mantine's `AppShell.Header`: logo, the `app/_meta.tsx` links, search,
 * community links, colour scheme and the sponsor controls.
 */
export function MantineNavBar({ nav, burgerOpened, onBurgerClick, sidebar }: MantineNavBarProps) {
  return (
    <Group h={60} px="md" justify="space-between" wrap="nowrap" className={classes.inner}>
      <Group gap="xs" wrap="nowrap">
        <Burger
          opened={burgerOpened}
          onClick={onBurgerClick}
          hiddenFrom="md"
          size="sm"
          aria-label={burgerOpened ? 'Close navigation' : 'Open navigation'}
        />
        {sidebar && <SidebarToggle {...sidebar} />}
        <Anchor component={Link} href="/" underline="never" aria-label="Home">
          <Group align="center" gap={10} wrap="nowrap">
            <Logo />
            {/* The site's name in the pixel font, as a title bar would set it */}
            <Text ff="var(--aal-font-pixel)" fz="md" fw={400} lh={1} c="orange" visibleFrom="xl">
              Amiga Assembly Library
            </Text>
          </Group>
        </Anchor>
      </Group>

      <Group gap="xs" wrap="nowrap">
        <TopNav nav={nav} />

        <SearchTrigger />

        <Tooltip label={config.links.discordLabel}>
          <ActionIcon
            component="a"
            href={config.links.discord}
            target="_blank"
            rel="noopener noreferrer"
            variant="subtle"
            color="gray"
            aria-label={config.links.discordLabel}
            visibleFrom="sm"
          >
            <IconBrandDiscord size={20} stroke={1.5} />
          </ActionIcon>
        </Tooltip>

        <Tooltip label="GitHub">
          <ActionIcon
            component="a"
            href={config.links.github}
            target="_blank"
            rel="noopener noreferrer"
            variant="subtle"
            color="gray"
            aria-label="GitHub repository"
          >
            <IconBrandGithub size={20} stroke={1.5} />
          </ActionIcon>
        </Tooltip>

        <AmigaModeToggle />

        <ColorSchemeControl />

        {/* Same square controls as the colour-scheme toggle (mantine.dev's header style), with
            the icon carrying the colour: Mantine red and orange. The sponsors wall is in the
            footer, on every page, hence the in-page `#sponsors`. */}
        <HeaderControl component="a" href="#sponsors" tooltip="Sponsor" visibleFrom="sm">
          <IconHeartFilled size={18} color="var(--mantine-color-red-6)" />
        </HeaderControl>
        <HeaderControl
          component="a"
          href={config.links.coffee}
          target="_blank"
          rel="noopener noreferrer"
          tooltip="Buy me a coffee"
          visibleFrom="sm"
        >
          <IconCoffee size={18} stroke={1.8} color="var(--mantine-color-orange-6)" />
        </HeaderControl>
      </Group>
    </Group>
  );
}
