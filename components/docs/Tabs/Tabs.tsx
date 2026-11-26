import { Children } from 'react';
import { Tabs as MantineTabs, TabsList, TabsPanel, TabsTab } from '@mantine/core';

export interface TabsProps {
  /** The tab labels, one per `<Tabs.Tab>` */
  items: React.ReactNode[];
  /** Index of the tab open at first @default 0 */
  defaultIndex?: number;
  children: React.ReactNode;
}

function TabsBase({ items, defaultIndex = 0, children }: TabsProps) {
  const panels = Children.toArray(children);

  // keepMountedMode 'display-none': every panel is in the served HTML, hidden with CSS. Mantine's
  // default mode wraps a closed panel in React's Activity, which a server render leaves out, so
  // the text, code blocks and headings of the other tabs were invisible to crawlers, to Pagefind
  // and to a page read without JavaScript. The Collapse of the sidebar has the same setting.
  return (
    <MantineTabs
      defaultValue={String(defaultIndex)}
      keepMountedMode="display-none"
      my="md"
      variant="outline"
      radius="md"
    >
      <TabsList>
        {items.map((item, index) => (
          <TabsTab key={index} value={String(index)}>
            {item}
          </TabsTab>
        ))}
      </TabsList>
      {panels.map((panel, index) => (
        <TabsPanel key={index} value={String(index)} pt="sm">
          {panel}
        </TabsPanel>
      ))}
    </MantineTabs>
  );
}

function Tab({ children }: { children: React.ReactNode }) {
  return <>{children}</>;
}

/**
 * Mantine's `Tabs` with Nextra's API:
 *
 * ```mdx
 * <Tabs items={['npm', 'yarn']}>
 *   <Tabs.Tab>npm install</Tabs.Tab>
 *   <Tabs.Tab>yarn add</Tabs.Tab>
 * </Tabs>
 * ```
 *
 * Mantine's sub-components are imported by name (`TabsList`, not `Tabs.List`): this is a server
 * module, and a client component's statics do not cross the RSC boundary.
 */
export const Tabs = Object.assign(TabsBase, { Tab });
