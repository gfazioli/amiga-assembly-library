'use client';

import {
  IconBrandGithubFilled,
  IconBrandMantine,
  IconBrandX,
  IconMailHeart,
} from '@tabler/icons-react';
import {
  ActionIcon,
  Anchor,
  Container,
  Divider,
  Grid,
  Group,
  Stack,
  Text,
  Title,
} from '@mantine/core';
import { Logo } from '@/components/Logo/Logo';
import { AnimateBadge } from './AnimateBadge';
import { ecosystem, highlights, resources } from './links';
import classes from './MantineFooter.module.css';

type VerticalLink = {
  key: string;
  title: string;
  href: string;
  newWindow?: boolean;
  new?: boolean;
};

const VerticalLinks = ({ list }: { list: VerticalLink[] }) => {
  return (
    <>
      {list.map((item) => (
        <Group key={item.key}>
          <Anchor
            className={classes.columnAnchor}
            href={item.href}
            target={item.newWindow ? '_blank' : undefined}
            rel={item.newWindow ? 'noopener noreferrer' : undefined}
          >
            {item.title}
          </Anchor>
          {item.new && <AnimateBadge />}
        </Group>
      ))}
    </>
  );
};

export const MantineFooter = () => {
  return (
    <div className={classes.contentFooter}>
      <Container className={classes.footer} size="lg">
        <Grid grow>
          <Grid.Col span={{ base: 12, sm: 4 }}>
            <Stack gap="xs">
              <Logo />
              <Text fz={13} mr={64}>
                The Amiga Assembly Library is a shared library for Commodore Amiga written in
                Motorola 68020 assembly language. Version 41.21, Public Domain Software. Compatible
                with KickStart 3.0+.
              </Text>
              <Group>
                <ActionIcon variant="subtle" component="a" href="https://github.com/gfazioli">
                  <IconBrandGithubFilled size={24} />
                </ActionIcon>
                <ActionIcon variant="subtle" component="a" href="https://twitter.com/gfazioli">
                  <IconBrandX size={24} />
                </ActionIcon>
                <ActionIcon variant="subtle" component="a" href="https://undolog.substack.com/">
                  <IconMailHeart size={24} />
                </ActionIcon>
              </Group>
            </Stack>
          </Grid.Col>
          <Grid.Col className={classes.column} span={2}>
            <Stack gap="xs">
              <Title className={classes.title} order={6}>
                DOCUMENTATION
              </Title>
              <VerticalLinks list={highlights} />
            </Stack>
          </Grid.Col>
          <Grid.Col className={classes.column} span={2}>
            <Stack gap="xs">
              <Title className={classes.title} order={6}>
                RESOURCES
              </Title>
              <VerticalLinks list={resources} />
            </Stack>
          </Grid.Col>
          <Grid.Col className={classes.column} span={2}>
            <Stack gap="xs">
              <Title className={classes.title} order={6}>
                MODULES
              </Title>
              <VerticalLinks list={ecosystem} />
            </Stack>
          </Grid.Col>
        </Grid>

        <Divider my={16} className={classes.lastDivider} />

        <Group justify="space-between">
          <Text fz={12} inline>
            Amiga Assembly Library v41.21 — Public Domain Software
          </Text>

          <Group justify="right">
            <Text fz={12} inline>
              Made with care by{' '}
              <Anchor fz={13} href="https://undolog.com/">
                Undolog
              </Anchor>
            </Text>
            <Divider orientation="vertical" />
            <Text fz={12} inline>
              <Group gap={4} component="span">
                Hosted on{' '}
                <Anchor fz={13} href="https://vercel.com/">
                  Vercel
                </Anchor>
              </Group>
            </Text>
            <Divider orientation="vertical" />
            <Text fz={12} inline>
              <Group gap={4} component="span">
                Built with{' '}
                <Anchor fz={13} href="https://mantine.dev/">
                  <Group gap={4} component="span">
                    <IconBrandMantine size={16} /> Mantine
                  </Group>
                </Anchor>
                {' + '}
                <Anchor fz={13} href="https://nextra.site/">
                  Nextra
                </Anchor>
              </Group>
            </Text>
            <Divider orientation="vertical" />
            <Text fz={12} inline>
              <Group gap={4} component="span">
                Source on{' '}
                <Anchor fz={13} href="https://github.com/gfazioli/amiga-assembly-library">
                  <Group gap={4} component="span">
                    <IconBrandGithubFilled size={16} /> GitHub
                  </Group>
                </Anchor>
              </Group>
            </Text>
          </Group>
        </Group>
      </Container>
    </div>
  );
};
