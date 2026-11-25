'use client';

import { useCallback, useEffect } from 'react';
import { usePathname } from 'next/navigation';
import { IconBrandDiscord, IconBrandGithub } from '@tabler/icons-react';
import { ActionIcon, AppShell, Group, NavLink, ScrollArea, Tooltip } from '@mantine/core';
import { useDisclosure, useHotkeys, useLocalStorage } from '@mantine/hooks';
import config from '@/config';
import { isDocsRoute, normalizeRoute } from '@/lib/docs/routes';
import {
  isStoredCollapsed,
  SIDEBAR_COLLAPSED_ATTRIBUTE,
  SIDEBAR_COLLAPSED_KEY,
} from '@/lib/docs/sidebar';
import { isMenu, type DocsNode, type TopNavEntry } from '@/lib/docs/types';
import { ColorSchemeControl } from '../../ColorSchemeControl/ColorSchemeControl';
import { MantineNavBar } from '../../MantineNavBar/MantineNavBar';
import { SidebarTree } from '../SidebarTree/SidebarTree';
import classes from './SiteShell.module.css';

export interface SiteShellProps {
  tree: DocsNode[];
  nav: TopNavEntry[];
  banner?: React.ReactNode;
  /** The footer under docs pages */
  docsFooter: React.ReactNode;
  /** The footer under every other page */
  siteFooter: React.ReactNode;
  children: React.ReactNode;
}

/** The header links, stacked, at the top of the mobile navigation. */
function MobileNav({ nav }: { nav: TopNavEntry[] }) {
  return (
    <>
      {nav.flatMap((entry) =>
        isMenu(entry)
          ? [
              <NavLink key={entry.key} label={entry.title} component="button" childrenOffset="sm">
                {entry.items.map((item) => (
                  <NavLink
                    key={item.key}
                    label={item.title}
                    href={item.href}
                    target={item.newWindow ? '_blank' : undefined}
                    rel={item.newWindow ? 'noopener noreferrer' : undefined}
                  />
                ))}
              </NavLink>,
            ]
          : [
              <NavLink
                key={entry.key}
                label={entry.title}
                href={entry.href}
                target={entry.newWindow ? '_blank' : undefined}
                rel={entry.newWindow ? 'noopener noreferrer' : undefined}
              />,
            ]
      )}
    </>
  );
}

/**
 * The page frame, on Mantine's `AppShell`:
 * - the header on every page, with the release banner above the navigation, always in view;
 * - the docs sidebar on `/docs` routes (on a phone, behind the header's menu button, on every page),
 *   which the header button or ⌘B / Ctrl+B collapses on desktop, remembered across visits;
 * - a compact footer under docs pages, the full site footer elsewhere.
 *
 * The table of contents is not an `AppShell.Aside`: it lives in the docs page, as a sticky column,
 * so the footer can run the whole width right of the sidebar, as on mantine.dev.
 */
export function SiteShell({ tree, nav, banner, docsFooter, siteFooter, children }: SiteShellProps) {
  const pathname = usePathname();
  const route = normalizeRoute(pathname);
  const isDocs = isDocsRoute(route);

  const [opened, { toggle, close }] = useDisclosure(false);
  useEffect(() => {
    close();
  }, [pathname, close]);

  const [sidebarCollapsed, setSidebarCollapsed] = useLocalStorage({
    key: SIDEBAR_COLLAPSED_KEY,
    defaultValue: false,
    getInitialValueInEffect: true,
  });
  // The pre-paint attribute (lib/docs/sidebar.ts) goes once the stored "collapsed" is committed,
  // when AppShell's own variables hold the sidebar closed, or once storage no longer says
  // "collapsed" (another tab expanded it between the script and this effect).
  useEffect(() => {
    if (sidebarCollapsed || !isStoredCollapsed()) {
      document.documentElement.removeAttribute(SIDEBAR_COLLAPSED_ATTRIBUTE);
    }
  }, [sidebarCollapsed]);

  const toggleSidebar = useCallback(
    () => setSidebarCollapsed((collapsed) => !collapsed),
    [setSidebarCollapsed]
  );
  useHotkeys(isDocs ? [['mod+B', toggleSidebar]] : []);

  const desktopCollapsed = !isDocs || sidebarCollapsed;

  return (
    <AppShell
      header={{ height: 60 }}
      navbar={{
        width: 280,
        breakpoint: 'md',
        collapsed: { mobile: !opened, desktop: desktopCollapsed },
      }}
      classNames={{ header: classes.header, navbar: classes.navbar }}
    >
      <AppShell.Header>
        {banner}
        <MantineNavBar
          nav={nav}
          burgerOpened={opened}
          onBurgerClick={toggle}
          sidebar={isDocs ? { collapsed: sidebarCollapsed, onToggle: toggleSidebar } : undefined}
        />
      </AppShell.Header>

      <AppShell.Navbar data-desktop-collapsed={desktopCollapsed || undefined}>
        <AppShell.Section hiddenFrom="md" className={classes.mobileNav}>
          <MobileNav nav={nav} />
        </AppShell.Section>
        <AppShell.Section grow component={ScrollArea} type="hover" className={classes.tree}>
          <SidebarTree
            tree={tree}
            defaultMenuCollapseLevel={config.docs.sidebar.defaultMenuCollapseLevel}
          />
        </AppShell.Section>
        <AppShell.Section className={classes.navbarFooter}>
          <Group justify="space-between">
            <Group gap={4}>
              <Tooltip label="GitHub">
                <ActionIcon
                  component="a"
                  href={`https://github.com/${config.gitHub.repo}`}
                  target="_blank"
                  rel="noopener noreferrer"
                  variant="subtle"
                  color="gray"
                  size="sm"
                  aria-label="GitHub repository"
                >
                  <IconBrandGithub size={16} stroke={1.5} />
                </ActionIcon>
              </Tooltip>
              <Tooltip label="Discord">
                <ActionIcon
                  component="a"
                  href={config.links.discord}
                  target="_blank"
                  rel="noopener noreferrer"
                  variant="subtle"
                  color="gray"
                  size="sm"
                  aria-label="Undolog Discord"
                >
                  <IconBrandDiscord size={16} stroke={1.5} />
                </ActionIcon>
              </Tooltip>
            </Group>
            <ColorSchemeControl />
          </Group>
        </AppShell.Section>
      </AppShell.Navbar>

      {/* `main-content`: the target of the skip link in app/layout.tsx */}
      <AppShell.Main id="main-content" className={classes.main}>
        {children}
        {isDocs ? docsFooter : siteFooter}
      </AppShell.Main>
    </AppShell>
  );
}
