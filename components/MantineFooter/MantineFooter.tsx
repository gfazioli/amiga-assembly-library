import {
  IconBrandDiscordFilled,
  IconBrandGithubFilled,
  IconBrandX,
  IconCoffee,
  IconHeartFilled,
  IconMailHeart,
  IconPlus,
} from '@tabler/icons-react';
import { Anchor, Avatar, Button, Container, Group, Stack, Text } from '@mantine/core';
import { Logo } from '@/components/Logo/Logo';
import config from '@/config';
import { AnimateBadge } from './AnimateBadge';
import { FooterWordmark } from './FooterWordmark';
import { ecosystem, highlights, resources, sponsors } from './links';
import classes from './MantineFooter.module.css';

type FooterLink = {
  key: string;
  title: string;
  href: string;
  newWindow?: boolean;
  new?: boolean;
};

const SPONSOR_URL = 'https://github.com/sponsors/gfazioli';
const REPOSITORY_URL = `https://github.com/${config.gitHub.repo}`;

const SOCIAL = [
  { label: 'GitHub', href: 'https://github.com/gfazioli', icon: IconBrandGithubFilled },
  { label: 'X', href: 'https://twitter.com/gfazioli', icon: IconBrandX },
  { label: 'Undolog Discord', href: config.links.discord, icon: IconBrandDiscordFilled },
  { label: 'Undolog', href: 'https://undolog.com/', icon: IconMailHeart },
];

function LinkColumn({ title, list }: { title: string; list: FooterLink[] }) {
  return (
    <nav aria-label={title}>
      <h2 className={classes.columnTitle}>{title}</h2>
      <ul className={classes.columnList}>
        {list.map((item) => (
          <li key={item.key}>
            <a
              className={classes.columnLink}
              href={item.href}
              target={item.newWindow ? '_blank' : undefined}
              rel={item.newWindow ? 'noopener noreferrer' : undefined}
            >
              {item.title}
            </a>
            {item.new && <AnimateBadge />}
          </li>
        ))}
      </ul>
    </nav>
  );
}

/**
 * The site footer, under every page: what the library is, the link columns, the sponsors wall
 * (`#sponsors`, the target of the header's heart), the credits with the font's, the trademark
 * notice, and the wordmark the page closes on.
 */
export const MantineFooter = () => {
  return (
    <footer className={classes.root}>
      <Container className={classes.inner} size="lg">
        <div className={classes.top}>
          <div className={classes.about}>
            <div className={classes.brand}>
              <Logo size={32} />
              <span className={classes.brandName}>Amiga Assembly Library</span>
            </div>
            <p className={classes.aboutText}>
              A shared library for Commodore Amiga written in Motorola 68020 assembly language.
              Version 41.21, Public Domain Software. Compatible with KickStart 3.0+.
            </p>
            {/* Plain links: a Tabler icon handed to a client component as a child, from a list
                rendered on the server, trips React's key warning in development */}
            <div className={classes.social}>
              {SOCIAL.map((item) => (
                <a key={item.label} href={item.href} aria-label={item.label}>
                  <item.icon size={20} aria-hidden />
                </a>
              ))}
            </div>
          </div>

          <LinkColumn title="Documentation" list={highlights} />
          <LinkColumn title="Modules" list={ecosystem} />
          <LinkColumn title="Resources" list={resources} />
        </div>

        {/* Sponsors wall: the same on every site of the author's, so its pink stays pink here */}
        <Stack gap="md" align="center" id="sponsors" className={classes.sponsors}>
          <h2 className={classes.sponsorsTitle}>
            <Text
              inherit
              component="span"
              variant="gradient"
              gradient={{ from: 'pink', to: 'grape' }}
            >
              Sponsors
            </Text>
          </h2>
          <Text fz={15} c="dimmed" ta="center" maw={560}>
            If my open-source work saves you or your team time, consider sponsoring its development.
            Sponsors get their name or logo featured here and across all my projects' documentation
            sites.
          </Text>
          <Group justify="center" gap="xl">
            {sponsors.map((sponsor) => (
              <Anchor
                key={sponsor.key}
                href={sponsor.href ?? `https://github.com/${sponsor.github}`}
                target="_blank"
                rel="noopener noreferrer"
                underline="never"
              >
                <Stack gap={4} align="center">
                  <Avatar
                    src={`https://github.com/${sponsor.github}.png`}
                    alt={sponsor.name}
                    size="lg"
                    radius={999}
                    // Lazy: without it React preloads both avatars, from github.com, in the
                    // head of every page, for a wall at the very bottom
                    imageProps={{ loading: 'lazy' }}
                  />
                  <Text fz={12} c="dimmed">
                    {sponsor.name}
                  </Text>
                </Stack>
              </Anchor>
            ))}
            <Anchor href={SPONSOR_URL} target="_blank" rel="noopener noreferrer" underline="never">
              <Stack gap={4} align="center">
                <Avatar size="lg" radius={999} className={classes.sponsorSlot}>
                  <IconPlus size={20} />
                </Avatar>
                <Text fz={12} c="dimmed">
                  Your logo here
                </Text>
              </Stack>
            </Anchor>
          </Group>
          <Group gap="sm" justify="center">
            <Button
              component="a"
              href={SPONSOR_URL}
              target="_blank"
              rel="noopener noreferrer"
              variant="gradient"
              gradient={{ from: 'pink', to: 'grape' }}
              className={classes.sponsorButton}
              leftSection={<IconHeartFilled size={16} />}
              radius={999}
            >
              Become a sponsor
            </Button>
            <Button
              component="a"
              href={config.links.coffee}
              target="_blank"
              rel="noopener noreferrer"
              variant="filled"
              color="yellow"
              leftSection={<IconCoffee size={16} />}
              radius={999}
            >
              Buy me a coffee
            </Button>
          </Group>
        </Stack>

        <div className={classes.credits}>
          <p>Amiga Assembly Library v41.21 — Public Domain Software</p>
          <p>
            Made by <a href="https://gfazioli.github.io/">Undolog</a>
            {' · '}
            Built with <a href="https://mantine.dev/">Mantine</a> and{' '}
            <a href="https://nextjs.org/">Next.js</a>
            {' · '}
            Hosted on <a href="https://vercel.com/">Vercel</a>
            {' · '}
            Source on <a href={REPOSITORY_URL}>GitHub</a>
          </p>
        </div>

        <div className={classes.legal}>
          <p>
            Amiga, AmigaOS and Commodore are trademarks of their respective owners. This is an
            independent project, not affiliated with or endorsed by them.
          </p>
          <p>
            The pixel font is Topaz a600a1200a4000, from{' '}
            <a href="https://github.com/rewtnull/amigafonts">Multi Platform Amiga Fonts</a>: the
            TrueType version is © 2009 dMG of TrueSchool and Divine Stylers, released under the GPL
            with the font exception; Topaz itself is © Amiga Inc. Details in the{' '}
            <a href={`${REPOSITORY_URL}/blob/main/NOTICE.md`}>notices</a>.
          </p>
        </div>
      </Container>

      <FooterWordmark name="Assembly Library" />
    </footer>
  );
};
