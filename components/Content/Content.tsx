'use client';

import {
  IconBrain,
  IconCode,
  IconCpu,
  IconDatabase,
  IconFileText,
  IconMath,
  IconPalette,
  IconWindow,
} from '@tabler/icons-react';
import { Anchor, Card, Divider, SimpleGrid, Stack, Text, ThemeIcon, Title } from '@mantine/core';

const modules = [
  {
    icon: IconCpu,
    title: 'Exec',
    description: 'Memory management, linked lists, and node operations.',
    href: '/docs/exec',
    color: 'red',
  },
  {
    icon: IconFileText,
    title: 'DOS',
    description: 'File I/O, disk info, checksums, and line input.',
    href: '/docs/dos',
    color: 'blue',
  },
  {
    icon: IconPalette,
    title: 'Graphics',
    description: 'BitPlanes, RastPort, drawing, color maps, and formatted text.',
    href: '/docs/graphics',
    color: 'green',
  },
  {
    icon: IconDatabase,
    title: 'Libraries',
    description: 'String processing, character filtering, and IFF/AIFF support.',
    href: '/docs/libraries',
    color: 'violet',
  },
  {
    icon: IconMath,
    title: 'Math',
    description: 'Decimal, hexadecimal, and binary conversions.',
    href: '/docs/math',
    color: 'yellow',
  },
  {
    icon: IconWindow,
    title: 'Intuition & GadTools',
    description: 'UI gadgets, custom requesters, and interface management.',
    href: '/docs/intui-gadtools',
    color: 'cyan',
  },
  {
    icon: IconBrain,
    title: 'REI Interface',
    description: 'Custom windowing system with event-driven messaging.',
    href: '/docs/rei',
    color: 'orange',
  },
  {
    icon: IconCode,
    title: 'C Interface',
    description: 'Full C prototypes and pragma declarations for SAS/C.',
    href: '/docs/c-interface',
    color: 'gray',
  },
];

export const Content = () => {
  return (
    <>
      <Divider my="md" />
      <Stack align="center" my={32}>
        <Title order={2} ta="center">
          Library Modules
        </Title>

        <Text c="dimmed" ta="center" maw={500}>
          The Assembly Library is organized into specialized modules, each providing a focused set
          of functions.
        </Text>

        <SimpleGrid cols={{ base: 1, sm: 2, md: 4 }} spacing="lg" mt="md">
          {modules.map((mod) => (
            <Card
              key={mod.title}
              component="a"
              href={mod.href}
              shadow="sm"
              padding="lg"
              radius="md"
              withBorder
              style={{ textDecoration: 'none', cursor: 'pointer' }}
            >
              <ThemeIcon size={40} radius="md" color={mod.color} variant="light">
                <mod.icon size={24} />
              </ThemeIcon>
              <Text fw={600} mt="sm">
                {mod.title}
              </Text>
              <Text size="sm" c="dimmed" mt={4}>
                {mod.description}
              </Text>
            </Card>
          ))}
        </SimpleGrid>

        <Anchor href="/docs/getting-started" mt="md">
          Get started with the Assembly Library →
        </Anchor>
      </Stack>
    </>
  );
};
