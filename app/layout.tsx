import '@mantine/core/styles.css';
// !! The order of these imports is important !!
import '@mantine/code-highlight/styles.css';
import '@mantine/spotlight/styles.css';
// The site's look on top of Mantine: tokens, the pixel font, the docs engine restyled, Amiga Mode
import '@/theme/global.css';

import type { Viewport } from 'next';
import { Analytics } from '@vercel/analytics/react';
import { Box, ColorSchemeScript, mantineHtmlProps, MantineProvider } from '@mantine/core';
// !! End of important imports !!

import { MantineFooter } from '@/components/MantineFooter/MantineFooter';
import { Banner } from '@/components/shell/Banner/Banner';
import { DocsSearch } from '@/components/shell/DocsSearch/DocsSearch';
import { SiteShell } from '@/components/shell/SiteShell/SiteShell';
import config from '@/config';
import { AMIGA_MODE_SCRIPT } from '@/lib/amiga-mode';
import { getDocs } from '@/lib/docs/content';
import { SIDEBAR_COLLAPSED_SCRIPT } from '@/lib/docs/sidebar';
import { getTopNav } from '@/lib/docs/top-nav';
import { theme } from '../theme';

export const metadata = config.metadata;

// The mobile browser's bar, in each scheme's page colour (gray.0 and dark.9 of theme.ts).
export const viewport: Viewport = {
  themeColor: [
    { media: '(prefers-color-scheme: light)', color: '#faf9f6' },
    { media: '(prefers-color-scheme: dark)', color: '#090d19' },
  ],
};

export default async function RootLayout({ children }: { children: React.ReactNode }) {
  const { tree } = await getDocs();
  const { head } = config;
  // One element for both slots: the footer is rendered on the server, and the shell, a client
  // component, would otherwise be sent it twice.
  const footer = <MantineFooter />;

  return (
    <html lang="en" dir="ltr" {...mantineHtmlProps}>
      <head>
        <ColorSchemeScript
          nonce={head.mantine.nonce}
          defaultColorScheme={head.mantine.defaultColorScheme}
        />
        <link rel="shortcut icon" href="/favicon.svg" />
        {/* Topaz sets the title of every page, the home page's above all: fetched with the
            stylesheet, its 6 KB are there for the first paint, and nothing swaps after it.
            (React also lists the preload among its own hints: one request all the same.) */}
        <link
          rel="preload"
          href="/fonts/Topaz_a1200_v1.0.woff2"
          as="font"
          type="font/woff2"
          crossOrigin="anonymous"
        />
        <script dangerouslySetInnerHTML={{ __html: SIDEBAR_COLLAPSED_SCRIPT }} />
        <script dangerouslySetInnerHTML={{ __html: AMIGA_MODE_SCRIPT }} />
      </head>
      <body>
        <MantineProvider theme={theme} defaultColorScheme={head.mantine.defaultColorScheme}>
          <SiteShell
            tree={tree}
            nav={getTopNav()}
            docsFooter={footer}
            siteFooter={footer}
            banner={
              // A new key per announcement, so readers who closed the last one see this one
              <Banner storageKey="floppeek-0.1.0">
                {/* One line, cut with an ellipsis: phones get the short form whole */}
                <Box component="span" visibleFrom="md">
                  New: <a href="https://gfazioli.github.io/floppeek/">Floppeek</a>, Quick Look for
                  Amiga disk images on the Mac. Press Space on an .adf in the Finder
                </Box>
                <Box component="span" hiddenFrom="md">
                  New: <a href="https://gfazioli.github.io/floppeek/">Floppeek</a>, .adf on the Mac
                </Box>
              </Banner>
            }
          >
            {children}
          </SiteShell>
          <DocsSearch />
        </MantineProvider>
        <Analytics />
      </body>
    </html>
  );
}
