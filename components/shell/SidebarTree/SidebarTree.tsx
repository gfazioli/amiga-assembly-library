'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import cx from 'clsx';
import { IconExternalLink } from '@tabler/icons-react';
import { Divider, NavLink, Text } from '@mantine/core';
import { normalizeRoute } from '@/lib/docs/routes';
import type { DocsNode } from '@/lib/docs/types';
import classes from './SidebarTree.module.css';

function contains(node: DocsNode, route: string): boolean {
  if (node.kind === 'page') {
    return node.route === route;
  }
  if (node.kind === 'folder') {
    return node.children.some((child) => contains(child, route));
  }
  return false;
}

interface TreeNodeProps {
  node: DocsNode;
  route: string;
  level: number;
  collapseLevel: number;
}

function TreeNode({ node, route, level, collapseLevel }: TreeNodeProps) {
  if (node.kind === 'separator') {
    return node.title ? (
      <Text className={classes.label} mt="lg" mb={6} px="sm">
        {node.title}
      </Text>
    ) : (
      <Divider my="sm" mx="sm" />
    );
  }

  if (node.kind === 'link') {
    return (
      <NavLink
        href={node.href}
        target={node.newWindow ? '_blank' : undefined}
        rel={node.newWindow ? 'noopener noreferrer' : undefined}
        label={node.title}
        rightSection={node.newWindow ? <IconExternalLink size={14} stroke={1.5} /> : undefined}
        className={classes.link}
      />
    );
  }

  if (node.kind === 'folder') {
    const active = contains(node, route);
    return (
      <NavLink
        // Re-mounted when the active page moves in or out, so a folder opens on its own when
        // search or a link lands on one of its pages.
        key={String(active)}
        // A folder only opens and closes: a button, not a link without an href, which crawlers
        // cannot follow (Lighthouse crawlable-anchors).
        component="button"
        label={node.title}
        defaultOpened={active || level < collapseLevel}
        classNames={{
          root: cx(classes.link, classes.folder, active && classes.folderActive),
          children: classes.children,
        }}
      >
        {node.children.map((child) => (
          <TreeNode
            key={child.key}
            node={child}
            route={route}
            level={level + 1}
            collapseLevel={collapseLevel}
          />
        ))}
      </NavLink>
    );
  }

  return (
    <NavLink
      component={Link}
      href={node.route}
      label={node.title}
      active={node.route === route}
      variant="light"
      className={classes.link}
    />
  );
}

export interface SidebarTreeProps {
  tree: DocsNode[];
  /** Folders deeper than this open only when they hold the current page @default 1 */
  defaultMenuCollapseLevel?: number;
}

/**
 * The docs sidebar: the `content/` tree on Mantine's `NavLink`.
 */
export function SidebarTree({ tree, defaultMenuCollapseLevel = 1 }: SidebarTreeProps) {
  const route = normalizeRoute(usePathname());

  return (
    <nav aria-label="Docs navigation">
      {tree.map((node) => (
        <TreeNode
          key={node.key}
          node={node}
          route={route}
          level={1}
          collapseLevel={defaultMenuCollapseLevel}
        />
      ))}
    </nav>
  );
}
